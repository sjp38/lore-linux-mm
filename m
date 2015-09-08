Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8A5E46B0258
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 10:14:20 -0400 (EDT)
Received: by oiww128 with SMTP id w128so59284283oiw.2
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 07:14:20 -0700 (PDT)
Received: from COL004-OMC4S6.hotmail.com (col004-omc4s6.hotmail.com. [65.55.34.208])
        by mx.google.com with ESMTPS id ya4si2648655pab.124.2015.09.08.07.14.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 08 Sep 2015 07:14:19 -0700 (PDT)
Message-ID: <COL130-W6916929C85FB1943CC1B11B9530@phx.gbl>
From: Chen Gang <xili_gchen_5257@hotmail.com>
Subject: Re: [PATCH] mm/mmap.c: Remove useless statement "vma = NULL" in
 find_vma()
Date: Tue, 8 Sep 2015 22:14:19 +0800
In-Reply-To: <55EEED66.6090509@hotmail.com>
References: <COL130-W64A6555222F8CEDA513171B9560@phx.gbl>
 <20150907123656.GA32668@redhat.com>,<55EEED66.6090509@hotmail.com>
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "oleg@redhat.com" <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "pfeiner@google.com" <pfeiner@google.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "vishnu.ps@samsung.com" <vishnu.ps@samsung.com>, Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>

T24gOS83LzE1IDIwOjM2LCBPbGVnIE5lc3Rlcm92IHdyb3RlOgo+IE9uIDA5LzA1LCBDaGVuIEdh
bmcgd3JvdGU6Cj4+Cj4+IEZyb20gYjEyZmE1YTkyNjNjZjRjMDQ0OTg4ZTU5ZjAwNzFmNGJjYzEz
MjIxNSBNb24gU2VwIDE3IDAwOjAwOjAwIDIwMDEKPj4gRnJvbTogQ2hlbiBHYW5nIDxnYW5nLmNo
ZW4uNWk1akBnbWFpbC5jb20+Cj4+IERhdGU6IFNhdCwgNSBTZXAgMjAxNSAyMTo0OTo1NiArMDgw
MAo+PiBTdWJqZWN0OiBbUEFUQ0hdIG1tL21tYXAuYzogUmVtb3ZlIHVzZWxlc3Mgc3RhdGVtZW50
ICJ2bWEgPSBOVUxMIiBpbgo+PiBmaW5kX3ZtYSgpCj4+Cj4+IEJlZm9yZSB0aGUgbWFpbiBsb29w
aW5nLCB2bWEgaXMgYWxyZWFkeSBpcyBOVUxMLCBzbyBuZWVkIG5vdCBzZXQgaXQgdG8KPj4gTlVM
TCwgYWdhaW4uCj4+Cj4+IFNpZ25lZC1vZmYtYnk6IENoZW4gR2FuZyA8Z2FuZy5jaGVuLjVpNWpA
Z21haWwuY29tPgo+Cj4gUmV2aWV3ZWQtYnk6IE9sZWcgTmVzdGVyb3YgPG9sZWdAcmVkaGF0LmNv
bT4KPgoKT0ssIHRoYW5rcy4KCgpJIGFsc28gd2FudCB0byBjb25zdWx0OiB0aGUgY29tbWVudHMg
b2YgZmluZF92bWEoKSBzYXlzOgoKIkxvb2sgdXAgdGhlIGZpcnN0IFZNQSB3aGljaCBzYXRpc2Zp
ZXMgYWRkciA8IHZtX2VuZCwgLi4uIgoKSXMgaXQgT0s/ICh3aHkgbm90ICJ2bV9zdGFydCA8PSBh
ZGRyIDwgdm1fZW5kIiksIG5lZWQgd2UgbGV0ICJ2bWEgPSB0bXAiCmluICJpZiAodG1wLT52bV9z
dGFydCA8PSBhZGRyKSI/IC0tIGl0IGxvb2tzIHRoZSBjb21tZW50cyBpcyBub3QgbWF0Y2gKdGhl
IGltcGxlbWVudGF0aW9uLCBwcmVjaXNlbHkgKG1heWJlIG5vdCAxc3QgVk1BKS4KCgpUaGFua3Mu
CgoKPj4gLS0tCj4+IG1tL21tYXAuYyB8IDEgLQo+PiAxIGZpbGUgY2hhbmdlZCwgMSBkZWxldGlv
bigtKQo+Pgo+PiBkaWZmIC0tZ2l0IGEvbW0vbW1hcC5jIGIvbW0vbW1hcC5jCj4+IGluZGV4IGRm
NmQ1ZjAuLjRkYjdjZjAgMTAwNjQ0Cj4+IC0tLSBhL21tL21tYXAuYwo+PiArKysgYi9tbS9tbWFw
LmMKPj4gQEAgLTIwNTQsNyArMjA1NCw2IEBAIHN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqZmluZF92
bWEoc3RydWN0IG1tX3N0cnVjdCAqbW0sIHVuc2lnbmVkIGxvbmcgYWRkcikKPj4gcmV0dXJuIHZt
YTsKPj4KPj4gcmJfbm9kZSA9IG1tLT5tbV9yYi5yYl9ub2RlOwo+PiAtIHZtYSA9IE5VTEw7Cj4+
Cj4+IHdoaWxlIChyYl9ub2RlKSB7Cj4+IHN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqdG1wOwo+PiAt
LQo+PiAxLjkuMwo+Pgo+Pgo+Cj4KCi0tCkNoZW4gR2FuZyAos8K41SkKCk9wZW4sIHNoYXJlLCBh
bmQgYXR0aXR1ZGUgbGlrZSBhaXIsIHdhdGVyLCBhbmQgbGlmZSB3aGljaCBHb2QgYmxlc3NlZAog
CQkgCSAgIAkJICA=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
