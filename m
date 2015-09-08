Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 163706B0038
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 10:09:13 -0400 (EDT)
Received: by obbbh8 with SMTP id bh8so84082543obb.0
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 07:09:12 -0700 (PDT)
Received: from COL004-OMC4S14.hotmail.com (col004-omc4s14.hotmail.com. [65.55.34.216])
        by mx.google.com with ESMTPS id wz8si5714405pab.119.2015.09.08.07.09.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 08 Sep 2015 07:09:09 -0700 (PDT)
Message-ID: <COL130-W788D15AB0C9B955A71E5E1B9530@phx.gbl>
From: Chen Gang <xili_gchen_5257@hotmail.com>
Subject: Re: [PATCH] mm/mmap.c: Remove redundent 'get_area' function pointer
 in get_unmapped_area()
Date: Tue, 8 Sep 2015 22:09:08 +0800
In-Reply-To: <55EEEC18.10101@hotmail.com>
References: <COL130-W16C972B0457D5C7C9CB06B9560@phx.gbl>
 <20150907124148.GB32668@redhat.com>,<55EEEC18.10101@hotmail.com>
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "oleg@redhat.com" <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "pfeiner@google.com" <pfeiner@google.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "vishnu.ps@samsung.com" <vishnu.ps@samsung.com>, Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>

T24gOS83LzE1IDIwOjQxLCBPbGVnIE5lc3Rlcm92IHdyb3RlOgo+IE9uIDA5LzA1LCBDaGVuIEdh
bmcgd3JvdGU6Cj4+Cj4+IEZyb20gYTFiZjQ3MjZmNzFkNmQwMzk0YjQxMzA5OTQ0NjQ2ZmM4MDZh
OGEwYyBNb24gU2VwIDE3IDAwOjAwOjAwIDIwMDEKPj4gRnJvbTogQ2hlbiBHYW5nIDxnYW5nLmNo
ZW4uNWk1akBnbWFpbC5jb20+Cj4+IERhdGU6IFNhdCwgNSBTZXAgMjAxNSAyMTo1MTowOCArMDgw
MAo+PiBTdWJqZWN0OiBbUEFUQ0hdIG1tL21tYXAuYzogUmVtb3ZlIHJlZHVuZGVudCAnZ2V0X2Fy
ZWEnIGZ1bmN0aW9uIHBvaW50ZXIgaW4KPj4gZ2V0X3VubWFwcGVkX2FyZWEoKQo+Pgo+PiBDYWxs
IHRoZSBmdW5jdGlvbiBwb2ludGVyIGRpcmVjdGx5LCB0aGVuIGxldCBjb2RlIGEgYml0IHNpbXBs
ZXIuCj4gXl5eXl5eXl5eXl5eXl5eXl5eCj4KPiBUaGlzIGlzIHN1YmplY3RpdmUgeW91IGtub3cg
OykKPgoKT2gsIHNvcnJ5LiBUaGUgY29tbWVudHMgbmVlZCBiZSBpbXByb3ZlZC4KCj4gSSBndWVz
cyB0aGUgYXV0aG9yIG9mIHRoaXMgY29kZSBhZGRlZCB0aGlzIHZhcmlhYmxlIHRvIG1ha2UgdGhl
IGNvZGUKPiBtb3JlIHJlYWRhYmxlLiBBbmQgdG8gbWUgaXQgYmVjb21lcyBsZXNzIHJlYWRhYmxl
IGFmdGVyIHlvdXIgY2hhbmdlLgo+Cj4gSSBsZWF2ZSB0aGlzIHRvIHlvdSBhbmQgbWFpbnRhaW5l
cnMuCj4KCk9LLCBJIGNhbiB1bmRlcnN0YW5kLCBldmVyeSBtZW1iZXJzIGhhdmUgdGhlaXIgb3du
IHRhc3RlIChteSB0YXN0ZSBpcwppZiBvbmUgYnVmZmVyaW5nIHZhcmlhYmxlIGlzIHVzZWQgd2l0
aGluIDIgdGltZXMsIEkgd2FudCB0byByZW1vdmUgaXQpLgoKRm9yIG9wdGltaXphdGlvbiwgdGhl
IG9yaWdpbmFsIGNvZGUgbWF5YmUgYmUgYSBsaXR0bGUgYmV0dGVyLgoKU28gZm9yIG1lLCBpZiBt
b3JlIHRoYW4gMjAlIG1lbWJlcnMgc3RpbGwgbGlrZSB0aGUgb3JpZ2luYWwgY29kZSwgd2UKc2hv
dWxkIGtlZXAgdGhlIG9yaWdpbmFsIGNvZGUgbm8gdG91Y2guCgoKVGhhbmtzLgoKPj4gU2lnbmVk
LW9mZi1ieTogQ2hlbiBHYW5nIDxnYW5nLmNoZW4uNWk1akBnbWFpbC5jb20+Cj4+IC0tLQo+PiBt
bS9tbWFwLmMgfCAxMiArKysrKystLS0tLS0KPj4gMSBmaWxlIGNoYW5nZWQsIDYgaW5zZXJ0aW9u
cygrKSwgNiBkZWxldGlvbnMoLSkKPj4KPj4gZGlmZiAtLWdpdCBhL21tL21tYXAuYyBiL21tL21t
YXAuYwo+PiBpbmRleCA0ZGI3Y2YwLi4zOWZkNzI3IDEwMDY0NAo+PiAtLS0gYS9tbS9tbWFwLmMK
Pj4gKysrIGIvbW0vbW1hcC5jCj4+IEBAIC0yMDEyLDEwICsyMDEyLDggQEAgdW5zaWduZWQgbG9u
Zwo+PiBnZXRfdW5tYXBwZWRfYXJlYShzdHJ1Y3QgZmlsZSAqZmlsZSwgdW5zaWduZWQgbG9uZyBh
ZGRyLCB1bnNpZ25lZCBsb25nIGxlbiwKPj4gdW5zaWduZWQgbG9uZyBwZ29mZiwgdW5zaWduZWQg
bG9uZyBmbGFncykKPj4gewo+PiAtIHVuc2lnbmVkIGxvbmcgKCpnZXRfYXJlYSkoc3RydWN0IGZp
bGUgKiwgdW5zaWduZWQgbG9uZywKPj4gLSB1bnNpZ25lZCBsb25nLCB1bnNpZ25lZCBsb25nLCB1
bnNpZ25lZCBsb25nKTsKPj4gLQo+PiB1bnNpZ25lZCBsb25nIGVycm9yID0gYXJjaF9tbWFwX2No
ZWNrKGFkZHIsIGxlbiwgZmxhZ3MpOwo+PiArCj4+IGlmIChlcnJvcikKPj4gcmV0dXJuIGVycm9y
Owo+Pgo+PiBAQCAtMjAyMywxMCArMjAyMSwxMiBAQCBnZXRfdW5tYXBwZWRfYXJlYShzdHJ1Y3Qg
ZmlsZSAqZmlsZSwgdW5zaWduZWQgbG9uZyBhZGRyLCB1bnNpZ25lZCBsb25nIGxlbiwKPj4gaWYg
KGxlbj4gVEFTS19TSVpFKQo+PiByZXR1cm4gLUVOT01FTTsKPj4KPj4gLSBnZXRfYXJlYSA9IGN1
cnJlbnQtPm1tLT5nZXRfdW5tYXBwZWRfYXJlYTsKPj4gaWYgKGZpbGUgJiYgZmlsZS0+Zl9vcC0+
Z2V0X3VubWFwcGVkX2FyZWEpCj4+IC0gZ2V0X2FyZWEgPSBmaWxlLT5mX29wLT5nZXRfdW5tYXBw
ZWRfYXJlYTsKPj4gLSBhZGRyID0gZ2V0X2FyZWEoZmlsZSwgYWRkciwgbGVuLCBwZ29mZiwgZmxh
Z3MpOwo+PiArIGFkZHIgPSBmaWxlLT5mX29wLT5nZXRfdW5tYXBwZWRfYXJlYShmaWxlLCBhZGRy
LCBsZW4sCj4+ICsgcGdvZmYsIGZsYWdzKTsKPj4gKyBlbHNlCj4+ICsgYWRkciA9IGN1cnJlbnQt
Pm1tLT5nZXRfdW5tYXBwZWRfYXJlYShmaWxlLCBhZGRyLCBsZW4sCj4+ICsgcGdvZmYsIGZsYWdz
KTsKPj4gaWYgKElTX0VSUl9WQUxVRShhZGRyKSkKPj4gcmV0dXJuIGFkZHI7Cj4+Cj4+IC0tCj4+
IDEuOS4zCj4+Cj4+Cj4KCi0tCkNoZW4gR2FuZyAos8K41SkKCk9wZW4sIHNoYXJlLCBhbmQgYXR0
aXR1ZGUgbGlrZSBhaXIsIHdhdGVyLCBhbmQgbGlmZSB3aGljaCBHb2QgYmxlc3NlZAogCQkgCSAg
IAkJICA=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
