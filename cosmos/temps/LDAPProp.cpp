#include "cppmicroservices/LDAPProp.h"

#include <stdexcept>

namespace cppmicroservices {

LDAPPropExpr::LDAPPropExpr()
  : m_ldapExpr()
{}

LDAPPropExpr::LDAPPropExpr(const std::string& expr)
  : m_ldapExpr(expr)
{}

LDAPPropExpr& LDAPPropExpr::operator!()
{
  if (m_ldapExpr.empty())
    return *this;

  m_ldapExpr = "(!" + m_ldapExpr + ")";
  return *this;
}

LDAPPropExpr::operator std::string() const
{
  return m_ldapExpr;
}

bool LDAPPropExpr::IsNull() const
{
  return m_ldapExpr.empty();
}

LDAPPropExpr& LDAPPropExpr::operator=(const LDAPPropExpr& expr) = default;

LDAPPropExpr& LDAPPropExpr::operator|=(const LDAPPropExpr& right)
{
  m_ldapExpr = (*this || right).m_ldapExpr;
  return *this;
}

LDAPPropExpr& LDAPPropExpr::operator&=(const LDAPPropExpr& right)
{
  m_ldapExpr = (*this && right).m_ldapExpr;
  return *this;
}

LDAPProp::LDAPProp(const std::string& property)
  : m_property(property)
{
  if (m_property.empty())
    throw std::invalid_argument("property must not be empty");
}

LDAPPropExpr LDAPProp::operator==(const std::string& s) const
{
  if (s.empty())
    return LDAPPropExpr(s);
  return LDAPPropExpr("(" + m_property + "=" + s + ")");
}

LDAPPropExpr LDAPProp::operator==(const cppmicroservices::Any& any) const
{
  return operator==(any.ToString());
}

LDAPPropExpr LDAPProp::operator==(bool b) const
{
  return operator==(b ? std::string("true") : std::string("false"));
}

LDAPProp::operator LDAPPropExpr() const
{
  return LDAPPropExpr("(" + m_property + "=*)");
}

LDAPPropExpr LDAPProp::operator!() const
{
  return LDAPPropExpr("(!(" + m_property + "=*))");
}

LDAPPropExpr LDAPProp::operator!=(const std::string& s) const
{
  if (s.empty())
    return LDAPPropExpr(s);
  return LDAPPropExpr("(!(" + m_property + "=" + s + "))");
}

LDAPPropExpr LDAPProp::operator!=(const cppmicroservices::Any& any) const
{
  return operator!=(any.ToString());
}

LDAPPropExpr LDAPProp::operator>=(const std::string& s) const
{
  if (s.empty())
    return LDAPPropExpr(s);
  return LDAPPropExpr("(" + m_property + ">=" + s + ")");
}

LDAPPropExpr LDAPProp::operator>=(const cppmicroservices::Any& any) const
{
  return operator>=(any.ToString());
}

LDAPPropExpr LDAPProp::operator<=(const std::string& s) const
{
  if (s.empty())
    return LDAPPropExpr(s);
  return LDAPPropExpr("(" + m_property + "<=" + s + ")");
}

LDAPPropExpr LDAPProp::operator<=(const cppmicroservices::Any& any) const
{
  return operator<=(any.ToString());
}

LDAPPropExpr LDAPProp::Approx(const std::string& s) const
{
  if (s.empty())
    return LDAPPropExpr(s);
  return LDAPPropExpr("(" + m_property + "~=" + s + ")");
}

LDAPPropExpr LDAPProp::Approx(const cppmicroservices::Any& any) const
{
  return Approx(any.ToString());
}
}

cppmicroservices::LDAPPropExpr operator&&(
  const cppmicroservices::LDAPPropExpr& left,
  const cppmicroservices::LDAPPropExpr& right)
{
  if (left.IsNull())
    return right;
  if (right.IsNull())
    return left;
  return cppmicroservices::LDAPPropExpr("(&" + static_cast<std::string>(left) +
                                        static_cast<std::string>(right) + ")");
}

cppmicroservices::LDAPPropExpr operator||(
  const cppmicroservices::LDAPPropExpr& left,
  const cppmicroservices::LDAPPropExpr& right)
{
  if (left.IsNull())
    return right;
  if (right.IsNull())
    return left;
  return cppmicroservices::LDAPPropExpr("(|" + static_cast<std::string>(left) +
                                        static_cast<std::string>(right) + ")");
}
