Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 98E2D6B007E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 09:43:18 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id yl2so253582188pac.2
        for <linux-mm@kvack.org>; Mon, 16 May 2016 06:43:18 -0700 (PDT)
Received: from m15-60.126.com (m15-60.126.com. [220.181.15.60])
        by mx.google.com with ESMTP id e127si36494902pfa.13.2016.05.16.06.43.16
        for <linux-mm@kvack.org>;
        Mon, 16 May 2016 06:43:17 -0700 (PDT)
Date: Mon, 16 May 2016 21:42:23 +0800 (CST)
From: "Wang Xiaoqiang" <wang_xiaoq@126.com>
Subject: Question About Functions "__free_pages_check" and "check_new_page"
 in page_alloc.c
Content-Type: multipart/alternative;
	boundary="----=_Part_272048_1660379652.1463406143442"
MIME-Version: 1.0
Message-ID: <7374bd2e.da35.154b9cda7d2.Coremail.wang_xiaoq@126.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vbabka@suse.cz, n-horiguchi@ah.jp.nec.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

------=_Part_272048_1660379652.1463406143442
Content-Type: text/plain; charset=GBK
Content-Transfer-Encoding: base64

SGkgYWxsLAoKICAgIEkgYW0gcmVhbGx5IGNvbmZ1c2VkIGFib3V0IHRoZXNlIHR3byBmdW5jdGlv
bnMuIFRoZSBmb2xsb3dpbmcgY29kZSBzbmlwcGV0OgoKaWYodW5saWtlbHkoYXRvbWljX3JlYWQo
JnBhZ2UtPl9tYXBjb3VudCkgIT0gLTEpKQoJCWJhZF9yZWFzb24gPSJub256ZXJvIG1hcGNvdW50
IjtpZih1bmxpa2VseShwYWdlLT5tYXBwaW5nICE9IE5VTEwpKQoJCWJhZF9yZWFzb24gPSJub24t
TlVMTCBtYXBwaW5nIjtpZih1bmxpa2VseShwYWdlX3JlZl9jb3VudChwYWdlKSAhPTApKQoJCWJh
ZF9yZWFzb24gPSJub256ZXJvIF9jb3VudCI7CiAgICAgICAgLi4uCldvdWxkbid0IHRoZSBwcmV2
aW91cyB2YWx1ZSBvZiAiYmFkX3JlYXNvbiIgYmUgb3ZlcndyaXR0ZW4gYnkgCnRoZSBsYXRlcj8g
SG9wZSB0byByZWNlaXZlIGZyb20geW91LgoKLS0KCnRoeCEKV2FuZyBYaWFvcWlhbmc=
------=_Part_272048_1660379652.1463406143442
Content-Type: text/html; charset=GBK
Content-Transfer-Encoding: base64

PGRpdiBzdHlsZT0ibGluZS1oZWlnaHQ6MS43O2NvbG9yOiMwMDAwMDA7Zm9udC1zaXplOjE0cHg7
Zm9udC1mYW1pbHk6QXJpYWwiPkhpIDxzcGFuIGNsYXNzPSJsaWJyYXZhdGFyIj48L3NwYW4+YWxs
LCA8YnI+PGRpdiBzdHlsZT0ibGluZS1oZWlnaHQ6MS43O2NvbG9yOiMwMDAwMDA7Zm9udC1zaXpl
OjE0cHg7Zm9udC1mYW1pbHk6QXJpYWwiPiZuYnNwOyZuYnNwOyZuYnNwOyBJIGFtIHJlYWxseSBj
b25mdXNlZCBhYm91dCB0aGVzZSB0d28gZnVuY3Rpb25zLiBUaGUgZm9sbG93aW5nIGNvZGUgc25p
cHBldDo8YnI+PHByZT48Y29kZT4JPHNwYW4gY2xhc3M9ImhsIGt3YSI+aWY8L3NwYW4+IDxzcGFu
IGNsYXNzPSJobCBvcHQiPig8L3NwYW4+PHNwYW4gY2xhc3M9ImhsIGt3ZCI+dW5saWtlbHk8L3Nw
YW4+PHNwYW4gY2xhc3M9ImhsIG9wdCI+KDwvc3Bhbj48c3BhbiBjbGFzcz0iaGwga3dkIj5hdG9t
aWNfcmVhZDwvc3Bhbj48c3BhbiBjbGFzcz0iaGwgb3B0Ij4oJmFtcDs8L3NwYW4+cGFnZTxzcGFu
IGNsYXNzPSJobCBvcHQiPi0mZ3Q7PC9zcGFuPl9tYXBjb3VudDxzcGFuIGNsYXNzPSJobCBvcHQi
PikgIT0gLTwvc3Bhbj48c3BhbiBjbGFzcz0iaGwgbnVtIj4xPC9zcGFuPjxzcGFuIGNsYXNzPSJo
bCBvcHQiPikpPC9zcGFuPgoJCWJhZF9yZWFzb24gPHNwYW4gY2xhc3M9ImhsIG9wdCI+PTwvc3Bh
bj4gPHNwYW4gY2xhc3M9ImhsIHN0ciI+Im5vbnplcm8gbWFwY291bnQiPC9zcGFuPjxzcGFuIGNs
YXNzPSJobCBvcHQiPjs8L3NwYW4+Cgk8c3BhbiBjbGFzcz0iaGwga3dhIj5pZjwvc3Bhbj4gPHNw
YW4gY2xhc3M9ImhsIG9wdCI+KDwvc3Bhbj48c3BhbiBjbGFzcz0iaGwga3dkIj51bmxpa2VseTwv
c3Bhbj48c3BhbiBjbGFzcz0iaGwgb3B0Ij4oPC9zcGFuPnBhZ2U8c3BhbiBjbGFzcz0iaGwgb3B0
Ij4tJmd0Ozwvc3Bhbj5tYXBwaW5nIDxzcGFuIGNsYXNzPSJobCBvcHQiPiE9PC9zcGFuPiBOVUxM
PHNwYW4gY2xhc3M9ImhsIG9wdCI+KSk8L3NwYW4+CgkJYmFkX3JlYXNvbiA8c3BhbiBjbGFzcz0i
aGwgb3B0Ij49PC9zcGFuPiA8c3BhbiBjbGFzcz0iaGwgc3RyIj4ibm9uLU5VTEwgbWFwcGluZyI8
L3NwYW4+PHNwYW4gY2xhc3M9ImhsIG9wdCI+Ozwvc3Bhbj4KCTxzcGFuIGNsYXNzPSJobCBrd2Ei
PmlmPC9zcGFuPiA8c3BhbiBjbGFzcz0iaGwgb3B0Ij4oPC9zcGFuPjxzcGFuIGNsYXNzPSJobCBr
d2QiPnVubGlrZWx5PC9zcGFuPjxzcGFuIGNsYXNzPSJobCBvcHQiPig8L3NwYW4+PHNwYW4gY2xh
c3M9ImhsIGt3ZCI+cGFnZV9yZWZfY291bnQ8L3NwYW4+PHNwYW4gY2xhc3M9ImhsIG9wdCI+KDwv
c3Bhbj5wYWdlPHNwYW4gY2xhc3M9ImhsIG9wdCI+KSAhPTwvc3Bhbj4gPHNwYW4gY2xhc3M9Imhs
IG51bSI+MDwvc3Bhbj48c3BhbiBjbGFzcz0iaGwgb3B0Ij4pKTwvc3Bhbj4KCQliYWRfcmVhc29u
IDxzcGFuIGNsYXNzPSJobCBvcHQiPj08L3NwYW4+IDxzcGFuIGNsYXNzPSJobCBzdHIiPiJub256
ZXJvIF9jb3VudCI8L3NwYW4+PHNwYW4gY2xhc3M9ImhsIG9wdCI+Ozxicj4gICAgICAgIC4uLjxi
cj5Xb3VsZG4ndCB0aGUgcHJldmlvdXMgdmFsdWUgb2YgImJhZF9yZWFzb24iIGJlIG92ZXJ3cml0
dGVuIGJ5IDxicj50aGUgbGF0ZXI/IEhvcGUgdG8gcmVjZWl2ZSBmcm9tIHlvdS48YnI+PC9zcGFu
PjwvY29kZT48L3ByZT48ZGl2IHN0eWxlPSJwb3NpdGlvbjpyZWxhdGl2ZTt6b29tOjEiPi0tPGJy
PjxkaXY+dGh4ITwvZGl2PjxkaXY+V2FuZyBYaWFvcWlhbmc8L2Rpdj48ZGl2IHN0eWxlPSJjbGVh
cjpib3RoIj48L2Rpdj48L2Rpdj48L2Rpdj48L2Rpdj48YnI+PGJyPjxzcGFuIHRpdGxlPSJuZXRl
YXNlZm9vdGVyIj48cD4mbmJzcDs8L3A+PC9zcGFuPg==
------=_Part_272048_1660379652.1463406143442--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
