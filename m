Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1ABCF6B0005
	for <linux-mm@kvack.org>; Tue, 17 May 2016 04:19:47 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 203so18337079pfy.2
        for <linux-mm@kvack.org>; Tue, 17 May 2016 01:19:47 -0700 (PDT)
Received: from m15-5.126.com (m15-5.126.com. [220.181.15.5])
        by mx.google.com with ESMTP id x10si3107355pas.64.2016.05.17.01.19.45
        for <linux-mm@kvack.org>;
        Tue, 17 May 2016 01:19:46 -0700 (PDT)
Date: Tue, 17 May 2016 16:17:15 +0800 (CST)
From: "Wang Xiaoqiang" <wang_xiaoq@126.com>
Subject: Re:Re: Question About Functions "__free_pages_check" and
 "check_new_page" in page_alloc.c
In-Reply-To: <573AA8C2.2060606@suse.cz>
References: <7374bd2e.da35.154b9cda7d2.Coremail.wang_xiaoq@126.com>
 <20160516151657.GC23251@dhcp22.suse.cz>
 <5877fe6c.1e45.154bc401c81.Coremail.wang_xiaoq@126.com>
 <573AA8C2.2060606@suse.cz>
Content-Type: multipart/alternative;
	boundary="----=_Part_207485_2036151241.1463473035147"
MIME-Version: 1.0
Message-ID: <48761067.9b95.154bdca578c.Coremail.wang_xiaoq@126.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, n-horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

------=_Part_207485_2036151241.1463473035147
Content-Type: text/plain; charset=GBK
Content-Transfer-Encoding: base64

dGhhbmsgeW91IHZlcnkgbXVjaCEgVmxhc3RpbWlsLgoKCkF0IDIwMTYtMDUtMTcgMTM6MTQ6NDIs
ICJWbGFzdGltaWwgQmFia2EiIDx2YmFia2FAc3VzZS5jej4gd3JvdGU6Cj5PbiAwNS8xNy8yMDE2
IDAzOjA2IEFNLCBXYW5nIFhpYW9xaWFuZyB3cm90ZToKPj4+eWVzIGl0IHdvdWxkLiBXaHkgdGhh
dCB3b3VsZCBtYXR0ZXIuIFRoZSBjaGVja3Mgc2hvdWxkIGJlIGluIGFuIG9yZGVyCj4+PndoaWNo
IGNvdWxkIGdpdmUgdXMgYSBtb3JlIHNwZWNpZmljIHJlYXNvbiB3aXRoIGxhdGVyIGNoZWNrcy4g
YmFkX3BhZ2UoKQo+PiAKPj4gSSBzZWUsIHlvdSBtZWFuIHRoZSBsYXRlciAiYmFkX3JlYXNvbiIg
aXMgdGhlIHN1cGVyc2V0IG9mIHRoZSBwcmV2aW91cyBvbmUuCj4KPk5vdCBleGFjdGx5LiBJdCdz
IG5vdCBwb3NzaWJsZSB0byBzb3J0IGFsbCB0aGUgcmVhc29ucyBsaWtlIHRoYXQuIEJ1dCBhcwo+
TWljaGFsIHNhaWQsIGJhZF9wYWdlKCkgd2lsbCBwcmludCBhbGwgdGhlIHJlbGV2YW50IGluZm8g
c28geW91IGNhbgo+cmVjb25zdHJ1Y3QgYWxsIHJlYXNvbnMgZnJvbSBpdC4gVGhlIGJhZF9yZWFz
b24gdGV4dCBpcyBtb3N0bHkgYSBoaW50Cj53aGF0IHRvIGNoZWNrIGZpcnN0Lgo+Cj4+PndpbGwg
dGhlbiBwcmludCBtb3JlIGRldGFpbGVkIGluZm9ybWF0aW9uLgo+Pj4tLQo+Pj5NaWNoYWwgSG9j
a28KPj4+U1VTRSBMYWJzCj4+IAo+PiB0aGFuayB5b3UsIE1pY2hhbC4K
------=_Part_207485_2036151241.1463473035147
Content-Type: text/html; charset=GBK
Content-Transfer-Encoding: base64

PGRpdiBzdHlsZT0ibGluZS1oZWlnaHQ6MS43O2NvbG9yOiMwMDAwMDA7Zm9udC1zaXplOjE0cHg7
Zm9udC1mYW1pbHk6QXJpYWwiPjxkaXYgaWQ9ImRpdk5ldGVhc2VNYWlsQ2FyZCI+PC9kaXY+PGRp
dj50aGFuayB5b3UgdmVyeSBtdWNoISBWbGFzdGltaWwuPGJyPjxicj48L2Rpdj48cHJlPkF0IDIw
MTYtMDUtMTcgMTM6MTQ6NDIsICJWbGFzdGltaWwgQmFia2EiICZsdDt2YmFia2FAc3VzZS5jeiZn
dDsgd3JvdGU6CiZndDtPbiAwNS8xNy8yMDE2IDAzOjA2IEFNLCBXYW5nIFhpYW9xaWFuZyB3cm90
ZToKJmd0OyZndDsmZ3Q7eWVzIGl0IHdvdWxkLiBXaHkgdGhhdCB3b3VsZCBtYXR0ZXIuIFRoZSBj
aGVja3Mgc2hvdWxkIGJlIGluIGFuIG9yZGVyCiZndDsmZ3Q7Jmd0O3doaWNoIGNvdWxkIGdpdmUg
dXMgYSBtb3JlIHNwZWNpZmljIHJlYXNvbiB3aXRoIGxhdGVyIGNoZWNrcy4gYmFkX3BhZ2UoKQom
Z3Q7Jmd0OyAKJmd0OyZndDsgSSBzZWUsIHlvdSBtZWFuIHRoZSBsYXRlciAiYmFkX3JlYXNvbiIg
aXMgdGhlIHN1cGVyc2V0IG9mIHRoZSBwcmV2aW91cyBvbmUuCiZndDsKJmd0O05vdCBleGFjdGx5
LiBJdCdzIG5vdCBwb3NzaWJsZSB0byBzb3J0IGFsbCB0aGUgcmVhc29ucyBsaWtlIHRoYXQuIEJ1
dCBhcwomZ3Q7TWljaGFsIHNhaWQsIGJhZF9wYWdlKCkgd2lsbCBwcmludCBhbGwgdGhlIHJlbGV2
YW50IGluZm8gc28geW91IGNhbgomZ3Q7cmVjb25zdHJ1Y3QgYWxsIHJlYXNvbnMgZnJvbSBpdC4g
VGhlIGJhZF9yZWFzb24gdGV4dCBpcyBtb3N0bHkgYSBoaW50CiZndDt3aGF0IHRvIGNoZWNrIGZp
cnN0LgomZ3Q7CiZndDsmZ3Q7Jmd0O3dpbGwgdGhlbiBwcmludCBtb3JlIGRldGFpbGVkIGluZm9y
bWF0aW9uLgomZ3Q7Jmd0OyZndDstLQomZ3Q7Jmd0OyZndDtNaWNoYWwgSG9ja28KJmd0OyZndDsm
Z3Q7U1VTRSBMYWJzCiZndDsmZ3Q7IAomZ3Q7Jmd0OyB0aGFuayB5b3UsIE1pY2hhbC4KPC9wcmU+
PC9kaXY+PGJyPjxicj48c3BhbiB0aXRsZT0ibmV0ZWFzZWZvb3RlciI+PHA+Jm5ic3A7PC9wPjwv
c3Bhbj4=
------=_Part_207485_2036151241.1463473035147--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
