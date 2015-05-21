Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 056A16B015A
	for <linux-mm@kvack.org>; Thu, 21 May 2015 06:17:28 -0400 (EDT)
Received: by wgjc11 with SMTP id c11so80594686wgj.0
        for <linux-mm@kvack.org>; Thu, 21 May 2015 03:17:27 -0700 (PDT)
Received: from mail2.protonmail.ch (mail2.protonmail.ch. [185.70.40.22])
        by mx.google.com with ESMTPS id e5si1998922wix.88.2015.05.21.03.17.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 03:17:26 -0700 (PDT)
Subject: RAM encryption and key storing in CPU
Date: Thu, 21 May 2015 06:17:25 -0400
From: ngabor <ngabor@protonmail.ch>
Reply-To: ngabor <ngabor@protonmail.ch>
Message-ID: <66f5c2af7580105cf14e85a0ee35be0a@protonmail.ch>
MIME-Version: 1.0
Content-Type: multipart/alternative;
	boundary="b1_66f5c2af7580105cf14e85a0ee35be0a"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "bp@alien8.de" <bp@alien8.de>, "lizefan@huawei.com" <lizefan@huawei.com>, "tj@kernel.org" <tj@kernel.org>, "cl@linux-foundation.org" <cl@linux-foundation.org>

This is a multi-part message in MIME format.

--b1_66f5c2af7580105cf14e85a0ee35be0a
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64

SGVsbG8sCgoKCj09PT09PT09PT0KClByb2JsZW06CgoKCkV2ZXJ5dGhpbmcgaXMgc3RvcmVkIGlu
IHBsYWludGV4dCBpbiB0aGUgTWVtb3J5LgoKCgpTbyBpZiBhbHRob3VnaCBmdWxsIGRpc2MgZW5j
cnlwdGlvbiBpcyB1c2VkIG9uIGEgTGludXggRGVza3RvcCwgaXQgaXMgcG9zc2libGUgdG8gY29w
eSB0aGUgY29udGVudCBvZiB0aGUgbWVtb3J5LCB3aGlsZSB0aGUgbm90ZWJvb2sgd2FzIG9uIHN1
c3BlbmQgb3IgaXQgd2FzIHJ1bm5pbmc6CgoKCmh0dHBzOi8vY2l0cC5wcmluY2V0b24uZWR1L3Jl
c2VhcmNoL21lbW9yeS9tZWRpYS8KCgoKPT09PT09PT09PQoKU29sdXRpb246CgoKCkNhbiB3ZSAo
b3B0aW9uYWxseSopIGVuY3J5cHQgdGhlIGNvbnRlbnQgb2YgdGhlIG1lbW9yeSBhbmQgc3RvcmUg
dGhlIGtleSBmb3IgZGVjcnlwdGlvbiBpbiB0aGUgQ1BVIHRvIGF2b2lkIGluIGdlbmVyYWwgdGhl
c2Uga2luZCBvZiBhdHRhY2tzPwoKCgpodHRwczovL3d3dzEuaW5mb3JtYXRpay51bmktZXJsYW5n
ZW4uZGUvdHJlc29yCgoKCklzIHRoaXMgc29sdXRpb24gYWxyZWFkeSBpbiB0aGUgTGludXgga2Vy
bmVsPyBJZiB5ZXMsIGhvdyBjYW4gYSBMaW51eCBlbmR1c2VyIHR1cm4gaXQgb24/IElmIG5vLCBo
b3cgY2FuIHdlIGdldCB0aGUgY29kZS9pZGVhIGluIHRoZSBtYWlubGluZT8gV2hhdCBhcmUgdGhl
IGFyZ3VtZW50cyBhZ2FpbnN0IGl0PwoKCgoqaWYgc29tZW9uZSB3b3VsZCB3YW50IHRvIGhhcmRl
biBpdCdzIExpbnV4IERlc2t0b3AgKHNpbmNlIG5vdGVib29rcyBjb3VsZCBiZSBzdG9sZW4uLikg
aXQgY291bGQgdHVybiBvbiB0aGlzIGZlYXR1cmUgdG8gYXZvaWQgYSBwb2xpY3kgdG8gYWx3YXlz
IHR1cm4gb2ZmIHRoZSBub3RlYm9vayB3aGlsZSBub3QgdXNpbmcgaXQuCgoKClRoYW5rIHlvdSBm
b3IgeW91ciBjb21tZW50cy4=


--b1_66f5c2af7580105cf14e85a0ee35be0a
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: base64

PGRpdj5IZWxsbywgPGJyPjwvZGl2PjxkaXY+PGJyPjwvZGl2PjxkaXY+PT09PT09PT09PTxicj48
L2Rpdj48ZGl2PjxiPlByb2JsZW08L2I+OiA8YnI+PC9kaXY+PGRpdj48YnI+PC9kaXY+PGRpdj5F
dmVyeXRoaW5nIGlzIHN0b3JlZCBpbiBwbGFpbnRleHQgaW4gdGhlIE1lbW9yeS4gPGJyPjwvZGl2
PjxkaXY+PGJyPjwvZGl2PjxkaXY+U28gaWYgYWx0aG91Z2ggZnVsbCBkaXNjIGVuY3J5cHRpb24g
aXMgdXNlZCBvbiBhIExpbnV4IERlc2t0b3AsIGl0IGlzIHBvc3NpYmxlIHRvIGNvcHkgdGhlIGNv
bnRlbnQgb2YgdGhlIG1lbW9yeSwgd2hpbGUgdGhlIG5vdGVib29rIHdhcyBvbiBzdXNwZW5kIG9y
IGl0IHdhcyBydW5uaW5nOiA8YnI+PC9kaXY+PGRpdj48YnI+PC9kaXY+PGRpdj48YSBocmVmPSJo
dHRwczovL2NpdHAucHJpbmNldG9uLmVkdS9yZXNlYXJjaC9tZW1vcnkvbWVkaWEvIj5odHRwczov
L2NpdHAucHJpbmNldG9uLmVkdS9yZXNlYXJjaC9tZW1vcnkvbWVkaWEvPC9hPjxicj48L2Rpdj48
ZGl2Pjxicj48L2Rpdj48ZGl2Pj09PT09PT09PT08YnI+PC9kaXY+PGRpdj48Yj5Tb2x1dGlvbjwv
Yj46IDxicj48L2Rpdj48ZGl2Pjxicj48L2Rpdj48ZGl2PkNhbiB3ZSAob3B0aW9uYWxseSopIGVu
Y3J5cHQgdGhlIGNvbnRlbnQgb2YgdGhlIG1lbW9yeSBhbmQgc3RvcmUgdGhlIGtleSBmb3IgZGVj
cnlwdGlvbiBpbiB0aGUgQ1BVIHRvIGF2b2lkIGluIGdlbmVyYWwgdGhlc2Uga2luZCBvZiBhdHRh
Y2tzPyA8YnI+PC9kaXY+PGRpdj48YnI+PC9kaXY+PGRpdj48YSBocmVmPSJodHRwczovL3d3dzEu
aW5mb3JtYXRpay51bmktZXJsYW5nZW4uZGUvdHJlc29yIj5odHRwczovL3d3dzEuaW5mb3JtYXRp
ay51bmktZXJsYW5nZW4uZGUvdHJlc29yPC9hPjxicj48L2Rpdj48ZGl2Pjxicj48L2Rpdj48ZGl2
PklzIHRoaXMgc29sdXRpb24gYWxyZWFkeSBpbiB0aGUgTGludXgga2VybmVsPyBJZiB5ZXMsIGhv
dyBjYW4gYSBMaW51eCBlbmR1c2VyIHR1cm4gaXQgb24/IElmIG5vLCBob3cgY2FuIHdlIGdldCB0
aGUgY29kZS9pZGVhIGluIHRoZSBtYWlubGluZT8gV2hhdCBhcmUgdGhlIGFyZ3VtZW50cyBhZ2Fp
bnN0IGl0PyA8YnI+PC9kaXY+PGRpdj48YnI+PC9kaXY+PGRpdj4qaWYgc29tZW9uZSB3b3VsZCB3
YW50IHRvIGhhcmRlbiBpdCdzIExpbnV4IERlc2t0b3AgKHNpbmNlIG5vdGVib29rcyBjb3VsZCBi
ZSBzdG9sZW4uLikgaXQgY291bGQgdHVybiBvbiB0aGlzIGZlYXR1cmUgdG8gYXZvaWQgYSBwb2xp
Y3kgdG8gYWx3YXlzIHR1cm4gb2ZmIHRoZSBub3RlYm9vayB3aGlsZSBub3QgdXNpbmcgaXQuIDxi
cj48L2Rpdj48ZGl2Pjxicj48L2Rpdj48ZGl2PlRoYW5rIHlvdSBmb3IgeW91ciBjb21tZW50cy4g
PGJyPjwvZGl2Pg==



--b1_66f5c2af7580105cf14e85a0ee35be0a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
