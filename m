Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id AF86A8E0089
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 09:25:57 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id v4so2337635edm.18
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 06:25:57 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ca11si3245358ejb.216.2019.01.24.06.25.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 06:25:56 -0800 (PST)
Date: Thu, 24 Jan 2019 15:25:53 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
In-Reply-To: <20190124124501.GA18012@nautica>
Message-ID: <nycvar.YFH.7.76.1901241523500.6626@cbobk.fhfr.pm>
References: <nycvar.YFH.7.76.1901240009560.6626@cbobk.fhfr.pm> <CAHk-=wg+C65FJHB=Jx1OvuJP4kvpWdw+5G=XOXB6X_KB2XuofA@mail.gmail.com> <20190124002455.GA23181@nautica> <20190124124501.GA18012@nautica>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="1678380546-789356226-1548339955=:6626"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dominique Martinet <asmadeus@codewreck.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Josh Snyder <joshs@netflix.com>, Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--1678380546-789356226-1548339955=:6626
Content-Type: text/plain; charset=US-ASCII

On Thu, 24 Jan 2019, Dominique Martinet wrote:

> Jiri, you've offered resubmitting the last two patches properly, can you 
> incorporate this change or should I just send this directly? (I'd take 
> most of your commit message and add your name somewhere)

I've been running some basic smoke testing with the kernel from

	https://git.kernel.org/pub/scm/linux/kernel/git/jikos/jikos.git/log/?h=pagecache-sidechannel-v2

(attaching the respective two patches to apply on top of latest Linus' 
tree to this mail as well), and everything looks good so far.

Thanks,

-- 
Jiri Kosina
SUSE Labs

--1678380546-789356226-1548339955=:6626
Content-Type: text/x-patch; name=0001-mm-mincore-make-mincore-more-conservative.patch
Content-Transfer-Encoding: BASE64
Content-ID: <nycvar.YFH.7.76.1901241525530.6626@cbobk.fhfr.pm>
Content-Description: 
Content-Disposition: attachment; filename=0001-mm-mincore-make-mincore-more-conservative.patch

RnJvbSA5ODEwNTY1ZjFkNWY5NjZhODQ5MDBjZGNiODVlMzNhYTc1NzFhZmJl
IE1vbiBTZXAgMTcgMDA6MDA6MDAgMjAwMQ0KRnJvbTogSmlyaSBLb3NpbmEg
PGprb3NpbmFAc3VzZS5jej4NCkRhdGU6IFdlZCwgMTYgSmFuIDIwMTkgMjA6
NTM6MTcgKzAxMDANClN1YmplY3Q6IFtQQVRDSCAxLzJdIG1tL21pbmNvcmU6
IG1ha2UgbWluY29yZSgpIG1vcmUgY29uc2VydmF0aXZlDQoNClRoZSBzZW1h
bnRpY3Mgb2Ygd2hhdCBtaW5jb3JlKCkgY29uc2lkZXJzIHRvIGJlIHJlc2lk
ZW50IGlzIG5vdCBjb21wbGV0ZWx5DQpjbGVhciwgYnV0IExpbnV4IGhhcyBh
bHdheXMgKHNpbmNlIDIuMy41Miwgd2hpY2ggaXMgd2hlbiBtaW5jb3JlKCkg
d2FzDQppbml0aWFsbHkgZG9uZSkgdHJlYXRlZCBpdCBhcyAicGFnZSBpcyBh
dmFpbGFibGUgaW4gcGFnZSBjYWNoZSIuDQoNClRoYXQncyBwb3RlbnRpYWxs
eSBhIHByb2JsZW0sIGFzIHRoYXQgW2luXWRpcmVjdGx5IGV4cG9zZXMgbWV0
YS1pbmZvcm1hdGlvbg0KYWJvdXQgcGFnZWNhY2hlIC8gbWVtb3J5IG1hcHBp
bmcgc3RhdGUgZXZlbiBhYm91dCBtZW1vcnkgbm90IHN0cmljdGx5IGJlbG9u
Z2luZw0KdG8gdGhlIHByb2Nlc3MgZXhlY3V0aW5nIHRoZSBzeXNjYWxsLCBv
cGVuaW5nIHBvc3NpYmlsaXRpZXMgZm9yIHNpZGVjaGFubmVsDQphdHRhY2tz
Lg0KDQpDaGFuZ2UgdGhlIHNlbWFudGljcyBvZiBtaW5jb3JlKCkgc28gdGhh
dCBpdCBvbmx5IHJldmVhbHMgcGFnZWNhY2hlIGluZm9ybWF0aW9uDQpmb3Ig
bm9uLWFub255bW91cyBtYXBwaW5ncyB0aGF0IGJlbG9nIHRvIGZpbGVzIHRo
YXQgdGhlIGNhbGxpbmcgcHJvY2VzcyBjb3VsZA0KKGlmIGl0IHRyaWVkIHRv
KSBzdWNjZXNzZnVsbHkgb3BlbiBmb3Igd3JpdGluZy4NCg0KT3JpZ2luYWxs
eS1ieTogTGludXMgVG9ydmFsZHMgPHRvcnZhbGRzQGxpbnV4LWZvdW5kYXRp
b24ub3JnPg0KT3JpZ2luYWxseS1ieTogRG9taW5pcXVlIE1hcnRpbmV0IDxh
c21hZGV1c0Bjb2Rld3JlY2sub3JnPg0KU2lnbmVkLW9mZi1ieTogSmlyaSBL
b3NpbmEgPGprb3NpbmFAc3VzZS5jej4NCi0tLQ0KIG1tL21pbmNvcmUuYyB8
IDE1ICsrKysrKysrKysrKysrLQ0KIDEgZmlsZSBjaGFuZ2VkLCAxNCBpbnNl
cnRpb25zKCspLCAxIGRlbGV0aW9uKC0pDQoNCmRpZmYgLS1naXQgYS9tbS9t
aW5jb3JlLmMgYi9tbS9taW5jb3JlLmMNCmluZGV4IDIxODA5OWI1ZWQzMS4u
NzQ3YTQ5MDdhM2FjIDEwMDY0NA0KLS0tIGEvbW0vbWluY29yZS5jDQorKysg
Yi9tbS9taW5jb3JlLmMNCkBAIC0xNjksNiArMTY5LDE0IEBAIHN0YXRpYyBp
bnQgbWluY29yZV9wdGVfcmFuZ2UocG1kX3QgKnBtZCwgdW5zaWduZWQgbG9u
ZyBhZGRyLCB1bnNpZ25lZCBsb25nIGVuZCwNCiAJcmV0dXJuIDA7DQogfQ0K
IA0KK3N0YXRpYyBpbmxpbmUgYm9vbCBjYW5fZG9fbWluY29yZShzdHJ1Y3Qg
dm1fYXJlYV9zdHJ1Y3QgKnZtYSkNCit7DQorCXJldHVybiB2bWFfaXNfYW5v
bnltb3VzKHZtYSkgfHwNCisJCSh2bWEtPnZtX2ZpbGUgJiYNCisJCQkoaW5v
ZGVfb3duZXJfb3JfY2FwYWJsZShmaWxlX2lub2RlKHZtYS0+dm1fZmlsZSkp
DQorCQkJIHx8IGlub2RlX3Blcm1pc3Npb24oZmlsZV9pbm9kZSh2bWEtPnZt
X2ZpbGUpLCBNQVlfV1JJVEUpID09IDApKTsNCit9DQorDQogLyoNCiAgKiBE
byBhIGNodW5rIG9mICJzeXNfbWluY29yZSgpIi4gV2UndmUgYWxyZWFkeSBj
aGVja2VkDQogICogYWxsIHRoZSBhcmd1bWVudHMsIHdlIGhvbGQgdGhlIG1t
YXAgc2VtYXBob3JlOiB3ZSBzaG91bGQNCkBAIC0xODksOCArMTk3LDEzIEBA
IHN0YXRpYyBsb25nIGRvX21pbmNvcmUodW5zaWduZWQgbG9uZyBhZGRyLCB1
bnNpZ25lZCBsb25nIHBhZ2VzLCB1bnNpZ25lZCBjaGFyICp2DQogCXZtYSA9
IGZpbmRfdm1hKGN1cnJlbnQtPm1tLCBhZGRyKTsNCiAJaWYgKCF2bWEgfHwg
YWRkciA8IHZtYS0+dm1fc3RhcnQpDQogCQlyZXR1cm4gLUVOT01FTTsNCi0J
bWluY29yZV93YWxrLm1tID0gdm1hLT52bV9tbTsNCiAJZW5kID0gbWluKHZt
YS0+dm1fZW5kLCBhZGRyICsgKHBhZ2VzIDw8IFBBR0VfU0hJRlQpKTsNCisJ
aWYgKCFjYW5fZG9fbWluY29yZSh2bWEpKSB7DQorCQl1bnNpZ25lZCBsb25n
IHBhZ2VzID0gKGVuZCAtIGFkZHIpID4+IFBBR0VfU0hJRlQ7DQorCQltZW1z
ZXQodmVjLCAxLCBwYWdlcyk7DQorCQlyZXR1cm4gcGFnZXM7DQorCX0NCisJ
bWluY29yZV93YWxrLm1tID0gdm1hLT52bV9tbTsNCiAJZXJyID0gd2Fsa19w
YWdlX3JhbmdlKGFkZHIsIGVuZCwgJm1pbmNvcmVfd2Fsayk7DQogCWlmIChl
cnIgPCAwKQ0KIAkJcmV0dXJuIGVycjsNCi0tIA0KMi4xMi4zDQoNCg==

--1678380546-789356226-1548339955=:6626
Content-Type: text/x-patch; name=0002-mm-filemap-initiate-readahead-even-if-IOCB_NOWAIT-is.patch
Content-Transfer-Encoding: BASE64
Content-ID: <nycvar.YFH.7.76.1901241525531.6626@cbobk.fhfr.pm>
Content-Description: 
Content-Disposition: attachment; filename=0002-mm-filemap-initiate-readahead-even-if-IOCB_NOWAIT-is.patch

RnJvbSBmMjg3MTg1ZmM1ZTBmZmJiYjM4MGYyZDY4ZGQxOTI5MDcxNTgyOWE4
IE1vbiBTZXAgMTcgMDA6MDA6MDAgMjAwMQ0KRnJvbTogSmlyaSBLb3NpbmEg
PGprb3NpbmFAc3VzZS5jej4NCkRhdGU6IFdlZCwgMTYgSmFuIDIwMTkgMjE6
MDY6NTggKzAxMDANClN1YmplY3Q6IFtQQVRDSCAyLzJdIG1tL2ZpbGVtYXA6
IGluaXRpYXRlIHJlYWRhaGVhZCBldmVuIGlmIElPQ0JfTk9XQUlUIGlzIHNl
dA0KIGZvciB0aGUgSS9PDQoNCnByZWFkdjIoUldGX05PV0FJVCkgY2FuIGJl
IHVzZWQgdG8gb3BlbiBhIHNpZGUtY2hhbm5lbCB0byBwYWdlY2FjaGUgY29u
dGVudHMsIGFzDQppdCByZXZlYWxzIG1ldGFkYXRhIGFib3V0IHJlc2lkZW5j
eSBvZiBwYWdlcyBpbiBwYWdlY2FjaGUuDQoNCklmIHByZWFkdjIoUldGX05P
V0FJVCkgcmV0dXJucyBpbW1lZGlhdGVseSwgaXQgcHJvdmlkZXMgYSBjbGVh
ciAicGFnZSBub3QNCnJlc2lkZW50IiBpbmZvcm1hdGlvbiwgYW5kIHZpY2Ug
dmVyc2EuDQoNCkNsb3NlIHRoYXQgc2lkZWNoYW5uZWwgYnkgYWx3YXlzIGlu
aXRpYXRpbmcgcmVhZGFoZWFkIG9uIHRoZSBjYWNoZSBpZiB3ZQ0KZW5jb3Vu
dGVyIGEgY2FjaGUgbWlzcyBmb3IgcHJlYWR2MihSV0ZfTk9XQUlUKTsgd2l0
aCB0aGF0IGluIHBsYWNlLCBwcm9iaW5nDQp0aGUgcGFnZWNhY2hlIHJlc2lk
ZW5jeSBpdHNlbGYgd2lsbCBhY3R1YWxseSBwb3B1bGF0ZSB0aGUgY2FjaGUs
IG1ha2luZyB0aGUNCnNpZGVjaGFubmVsIHVzZWxlc3MuDQoNCk9yaWdpbmFs
bHktYnk6IExpbnVzIFRvcnZhbGRzIDx0b3J2YWxkc0BsaW51eC1mb3VuZGF0
aW9uLm9yZz4NClNpZ25lZC1vZmYtYnk6IEppcmkgS29zaW5hIDxqa29zaW5h
QHN1c2UuY3o+DQotLS0NCiBtbS9maWxlbWFwLmMgfCAyIC0tDQogMSBmaWxl
IGNoYW5nZWQsIDIgZGVsZXRpb25zKC0pDQoNCmRpZmYgLS1naXQgYS9tbS9m
aWxlbWFwLmMgYi9tbS9maWxlbWFwLmMNCmluZGV4IDlmNWUzMjNlODgzZS4u
N2JjZGQzNmU2MjlkIDEwMDY0NA0KLS0tIGEvbW0vZmlsZW1hcC5jDQorKysg
Yi9tbS9maWxlbWFwLmMNCkBAIC0yMDc1LDggKzIwNzUsNiBAQCBzdGF0aWMg
c3NpemVfdCBnZW5lcmljX2ZpbGVfYnVmZmVyZWRfcmVhZChzdHJ1Y3Qga2lv
Y2IgKmlvY2IsDQogDQogCQlwYWdlID0gZmluZF9nZXRfcGFnZShtYXBwaW5n
LCBpbmRleCk7DQogCQlpZiAoIXBhZ2UpIHsNCi0JCQlpZiAoaW9jYi0+a2lf
ZmxhZ3MgJiBJT0NCX05PV0FJVCkNCi0JCQkJZ290byB3b3VsZF9ibG9jazsN
CiAJCQlwYWdlX2NhY2hlX3N5bmNfcmVhZGFoZWFkKG1hcHBpbmcsDQogCQkJ
CQlyYSwgZmlscCwNCiAJCQkJCWluZGV4LCBsYXN0X2luZGV4IC0gaW5kZXgp
Ow0KLS0gDQoyLjEyLjMNCg0K

--1678380546-789356226-1548339955=:6626--
