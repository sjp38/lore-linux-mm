Received: from petasus.fm.intel.com (petasus.fm.intel.com [10.1.192.37])
	by hermes.fm.intel.com (8.11.6/8.11.6/d: outer.mc,v 1.51 2002/09/23 20:43:23 dmccart Exp $) with ESMTP id h1832c925900
	for <linux-mm@kvack.org>; Sat, 8 Feb 2003 03:02:38 GMT
Received: from fmsmsxvs042.fm.intel.com (fmsmsxvs042.fm.intel.com [132.233.42.128])
	by petasus.fm.intel.com (8.11.6/8.11.6/d: inner.mc,v 1.28 2003/01/13 19:44:39 dmccart Exp $) with SMTP id h1830Ms05269
	for <linux-mm@kvack.org>; Sat, 8 Feb 2003 03:00:22 GMT
content-class: urn:content-classes:message
Subject: RE: hugepage patches
Date: Fri, 7 Feb 2003 19:05:32 -0800
Message-ID: <6315617889C99D4BA7C14687DEC8DB4E023D2E70@fmsmsx402.fm.intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----_=_NextPart_001_01C2CF1E.F153677E"
From: "Seth, Rohit" <rohit.seth@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, "Seth, Rohit" <rohit.seth@intel.com>
Cc: davem@redhat.com, davidm@napali.hpl.hp.com, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.

------_=_NextPart_001_01C2CF1E.F153677E
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

> OK, but it needs some changes.
>=20
> - is_valid_hugepage_range() will not compile.  `addrp' vs `addr'
>=20
> - We should not pass in a flag variable which alters a=20
> function's behaviour
>   in this manner.  Especially when it has the wonderful name=20
> "flag", and no
>   supporting commentary!
>=20
>   Please split this into two separate (and documented) functions.


Attached is the updated patch based on your comments. =20

>=20
> - A name like "is_valid_hugepage_range" implies that this function is
>   purely a predicate.  Yet it is capable of altering part of=20
> the caller's
>   environment.  Can we have a more appropriate name?
>=20
> - I've been trying to keep ia64/sparc64/x86_64 as uptodate as I can
>   throughout this.  I think we can safely copy the ia32=20
> implementation over
>   into there as well, can't we?

For ia64, there is a separate kernel patch that David Mosberger
maintains.  Linus's tree won't work as is on ia64. Not sure about
x86_64/sparc64.

>=20
>   If there's any doubt then probably it's best to just leave=20
> the symbol
>   undefined, let the arch maintainers curse us ;)

>=20
> Are you working against Linus's current tree?  A lot has=20
> changed in there.=20
> I'd like to hear if hugetlbfs is working correctly in a=20
> non-ia32 kernel.

Yeah, I am working on Linus's 2.5.59 tree. Will download your mm9 to get
my tree updated.  Is there any other patch that you want me to apply
before sending you any more updates.

As far as non-ia32 kernel is concerned, hugetlbfs on ia64 should be
working fine. Though I've not yet tried the 2.5.59 on ia64. 2.5.59 ia64
patch that David maintains has the same level of hugetlb support as i386
tree.=20


>=20

------_=_NextPart_001_01C2CF1E.F153677E
Content-Type: application/octet-stream;
	name="patch.750"
Content-Transfer-Encoding: base64
Content-Description: patch.750
Content-Disposition: attachment;
	filename="patch.750"

LS0tIG1tL21tYXAuYy43NTAJRnJpIEZlYiAgNyAxODo1MDoyNyAyMDAzCisrKyBtbS9tbWFwLmMJ
RnJpIEZlYiAgNyAxODo1MDo1NSAyMDAzCkBAIC02ODIsNyArNjgyLDcgQEAKIAkJCXJldHVybiAt
RU5PTUVNOwogCQlpZiAoYWRkciAmIH5QQUdFX01BU0spCiAJCQlyZXR1cm4gLUVJTlZBTDsKLQkJ
aWYgKGlzX2ZpbGVfaHVnZXBhZ2VzKGZpbGUpICYmIChyZXQgPSBpc192YWxpZF9odWdlcGFnZV9y
YW5nZSgmYWRkciwgbGVuLCAxKSkpCisJCWlmIChpc19maWxlX2h1Z2VwYWdlcyhmaWxlKSAmJiAo
cmV0ID0gaXNfYWxpZ25faHVnZXBhZ2VfcmFuZ2UoYWRkciwgbGVuKSkpCiAJCQlyZXR1cm4gcmV0
OwogCQlyZXR1cm4gYWRkcjsKIAl9Ci0tLSBpbmNsdWRlL2xpbnV4L2h1Z2V0bGIuaC43NTAJRnJp
IEZlYiAgNyAxODo1NTozNyAyMDAzCisrKyBpbmNsdWRlL2xpbnV4L2h1Z2V0bGIuaAlGcmkgRmVi
ICA3IDE4OjQ5OjI0IDIwMDMKQEAgLTIxLDcgKzIxLDggQEAKIHZvaWQgaHVnZXRsYl9yZWxlYXNl
X2tleShzdHJ1Y3QgaHVnZXRsYl9rZXkgKik7CiBpbnQgaHVnZXRsYl9yZXBvcnRfbWVtaW5mbyhj
aGFyICopOwogaW50IGlzX2h1Z2VwYWdlX21lbV9lbm91Z2goc2l6ZV90KTsKLXVuc2lnbmVkIGxv
bmcgaXNfdmFsaWRfaHVnZXBhZ2VfcmFuZ2UodW5zaWduZWQgbG9uZyAqLCB1bnNpZ25lZCBsb25n
LCBpbnQpOwordW5zaWduZWQgbG9uZyBjaGtfYWxpZ25fYW5kX2ZpeF9hZGRyKHVuc2lnbmVkIGxv
bmcgKiwgdW5zaWduZWQgbG9uZyk7Cit1bnNpZ25lZCBsb25nIGlzX2FsaWduX2h1Z2VwYWdlX3Jh
bmdlKHVuc2lnbmVkIGxvbmcsIHVuc2lnbmVkIGxvbmcpOwogCiBleHRlcm4gaW50IGh0bGJwYWdl
X21heDsKIApAQCAtMzksNyArNDAsNyBAQAogI2RlZmluZSBodWdlX3BhZ2VfcmVsZWFzZShwYWdl
KQkJCUJVRygpCiAjZGVmaW5lIGlzX2h1Z2VwYWdlX21lbV9lbm91Z2goc2l6ZSkJCTAKICNkZWZp
bmUgaHVnZXRsYl9yZXBvcnRfbWVtaW5mbyhidWYpCQkwCi0jZGVmaW5lIGlzX3ZhbGlkX2h1Z2Vw
YWdlX3JhbmdlKGFkZHIsIGxlbiwgZmxnKQkJMAorI2RlZmluZSBpc19hbGlnbl9odWdlcGFnZV9y
YW5nZShhZGRyLCBsZW4pCTAKIAogI2VuZGlmIC8qICFDT05GSUdfSFVHRVRMQl9QQUdFICovCiAK
LS0tIGFyY2gvaTM4Ni9tbS9odWdldGxicGFnZS5jLjc1MAlGcmkgRmViICA3IDE4OjQwOjU0IDIw
MDMKKysrIGFyY2gvaTM4Ni9tbS9odWdldGxicGFnZS5jCUZyaSBGZWIgIDcgMTg6NTk6MTcgMjAw
MwpAQCAtODgsMTcgKzg4LDI0IEBACiAJc2V0X3B0ZShwYWdlX3RhYmxlLCBlbnRyeSk7CiB9CiAK
LXVuc2lnbmVkIGxvbmcgaXNfdmFsaWRfaHVnZXBhZ2VfcmFuZ2UodW5zaWduZWQgbG9uZyAqYWRk
cnAsIHVuc2lnbmVkIGxvbmcgbGVuLCBpbnQgZmxhZykKKy8qIFRoaXMgZnVuY3Rpb24gY2hlY2tz
IGZvciBwcm9wZXIgYWxpZ25tZW50IGZvciBsZW4uICBJdCB1cGRhdGVzIHRoZSBpbnB1dCBhZGRy
cCBwYXJhbWV0ZXIgc28gdGhhdAorICogaXQgcG9pbnRzIHRvIHZhbGlkKGFuZCBhbGlnbmVkKSBo
dWdlcGFnZSBhZGRyZXNzIHJhbmdlIChGb3IgaTM4NiBpdCBpcyBqdXN0IHByb3BlciBhbGlnbm1l
bnQpLgorICovCit1bnNpZ25lZCBsb25nIGNoa19hbGlnbl9hbmRfZml4X2FkZHIodW5zaWduZWQg
bG9uZyAqYWRkcnAsIHVuc2lnbmVkIGxvbmcgbGVuKQogewogCWlmIChsZW4gJiB+SFBBR0VfTUFT
SykKIAkJcmV0dXJuIC1FSU5WQUw7Ci0JaWYgKGZsYWcpIHsKLQkJaWYgKCphZGRyICYgfkhQQUdF
X01BU0spCi0JCQlyZXR1cm4gLUVJTlZBTDsKLQkJcmV0dXJuIDA7Ci0JfQotCWlmIChsZW4gPiBU
QVNLX1NJWkUpCi0JCXJldHVybiAtRU5PTUVNOworCSphZGRycCA9IEFMSUdOKCphZGRycCwgSFBB
R0VfU0laRSk7CisJcmV0dXJuIDA7Cit9CisvKiBUaGlzIGZ1bmN0aW9uIGNoZWNrcyBmb3IgcHJv
cGVyIGFsaWduZW1lbnQgb2YgaW5wdXQgYWRkciBhbmQgbGVuIHBhcmFtZXRlcnMuCisgKi8KK3Vu
c2lnbmVkIGxvbmcgaXNfYWxpZ25faHVnZXBhZ2VfcmFuZ2UodW5zaWduZWQgbG9uZyBhZGRyLCB1
bnNpZ25lZCBsb25nIGxlbikKK3sKKwlpZiAobGVuICYgfkhQQUdFX01BU0spCisJCXJldHVybiAt
RUlOVkFMOworCWlmIChhZGRyICYgfkhQQUdFX01BU0spCisJCXJldHVybiAtRUlOVkFMOwogCXJl
dHVybiAwOwogfQogCi0tLSBmcy9odWdldGxiZnMvaW5vZGUuYy43NTAJRnJpIEZlYiAgNyAxODoz
ODozMSAyMDAzCisrKyBmcy9odWdldGxiZnMvaW5vZGUuYwlGcmkgRmViICA3IDE4OjQ2OjA0IDIw
MDMKQEAgLTg5LDExICs4OSwxMCBAQAogCXN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqdm1hOwogCXVu
c2lnbmVkIGxvbmcgcmV0ID0gMDsKIAotCWlmIChyZXQgPSBpc192YWxpZF9odWdlcGFnZV9yYW5n
ZSgmYWRkciwgbGVuLCAwKSkKKwlpZiAocmV0ID0gY2hrX2FsaWduX2FuZF9maXhfYWRkcigmYWRk
ciwgbGVuKSkKIAkJcmV0dXJuIHJldDsKIAogCWlmIChhZGRyKSB7Ci0JCWFkZHIgPSBBTElHTihh
ZGRyLCBIUEFHRV9TSVpFKTsKIAkJdm1hID0gZmluZF92bWEobW0sIGFkZHIpOwogCQlpZiAoVEFT
S19TSVpFIC0gbGVuID49IGFkZHIgJiYKIAkJICAgICghdm1hIHx8IGFkZHIgKyBsZW4gPD0gdm1h
LT52bV9zdGFydCkpCg==

------_=_NextPart_001_01C2CF1E.F153677E--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
