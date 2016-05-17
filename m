Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9A8626B0005
	for <linux-mm@kvack.org>; Mon, 16 May 2016 21:07:38 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id dh6so350636obb.1
        for <linux-mm@kvack.org>; Mon, 16 May 2016 18:07:38 -0700 (PDT)
Received: from m15-52.126.com (m15-52.126.com. [220.181.15.52])
        by mx.google.com with ESMTP id vt10si69093obb.67.2016.05.16.18.07.36
        for <linux-mm@kvack.org>;
        Mon, 16 May 2016 18:07:37 -0700 (PDT)
Date: Tue, 17 May 2016 09:06:38 +0800 (CST)
From: "Wang Xiaoqiang" <wang_xiaoq@126.com>
Subject: Re:Re: Question About Functions "__free_pages_check" and
 "check_new_page" in page_alloc.c
In-Reply-To: <20160516151657.GC23251@dhcp22.suse.cz>
References: <7374bd2e.da35.154b9cda7d2.Coremail.wang_xiaoq@126.com>
 <20160516151657.GC23251@dhcp22.suse.cz>
Content-Type: multipart/alternative;
	boundary="----=_Part_57699_1377556961.1463447198849"
MIME-Version: 1.0
Message-ID: <5877fe6c.1e45.154bc401c81.Coremail.wang_xiaoq@126.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, vbabka <vbabka@suse.cz>, n-horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

------=_Part_57699_1377556961.1463447198849
Content-Type: text/plain; charset=GBK
Content-Transfer-Encoding: base64

PnllcyBpdCB3b3VsZC4gV2h5IHRoYXQgd291bGQgbWF0dGVyLiBUaGUgY2hlY2tzIHNob3VsZCBi
ZSBpbiBhbiBvcmRlcgo+d2hpY2ggY291bGQgZ2l2ZSB1cyBhIG1vcmUgc3BlY2lmaWMgcmVhc29u
IHdpdGggbGF0ZXIgY2hlY2tzLiBiYWRfcGFnZSgpCgpJIHNlZSwgeW91IG1lYW4gdGhlIGxhdGVy
ICJiYWRfcmVhc29uIiBpcyB0aGUgc3VwZXJzZXQgb2YgdGhlIHByZXZpb3VzIG9uZS4KCj53aWxs
IHRoZW4gcHJpbnQgbW9yZSBkZXRhaWxlZCBpbmZvcm1hdGlvbi4KPi0tCj5NaWNoYWwgSG9ja28K
PlNVU0UgTGFicwoKdGhhbmsgeW91LCBNaWNoYWwuCg==
------=_Part_57699_1377556961.1463447198849
Content-Type: text/html; charset=GBK
Content-Transfer-Encoding: base64

PGRpdiBzdHlsZT0ibGluZS1oZWlnaHQ6MS43O2NvbG9yOiMwMDAwMDA7Zm9udC1zaXplOjE0cHg7
Zm9udC1mYW1pbHk6QXJpYWwiPjxkaXY+CiZndDt5ZXMgaXQgd291bGQuIFdoeSB0aGF0IHdvdWxk
IG1hdHRlci4gVGhlIGNoZWNrcyBzaG91bGQgYmUgaW4gYW4gb3JkZXIKPGJyPiZndDt3aGljaCBj
b3VsZCBnaXZlIHVzIGEgbW9yZSBzcGVjaWZpYyByZWFzb24gd2l0aCBsYXRlciBjaGVja3MuIGJh
ZF9wYWdlKCkKPGJyPjxicj5JIHNlZSwgeW91IG1lYW4gdGhlIGxhdGVyICJiYWRfcmVhc29uIiBp
cyB0aGUgc3VwZXJzZXQgb2YgdGhlIHByZXZpb3VzIG9uZS48YnI+PGJyPiZndDt3aWxsIHRoZW4g
cHJpbnQgbW9yZSBkZXRhaWxlZCBpbmZvcm1hdGlvbi4KPGJyPiZndDstLSAKPGJyPiZndDtNaWNo
YWwgSG9ja28KPGJyPiZndDtTVVNFIExhYnM8YnI+PGJyPnRoYW5rIHlvdSwgTWljaGFsLjxicj48
L2Rpdj48L2Rpdj48YnI+PGJyPjxzcGFuIHRpdGxlPSJuZXRlYXNlZm9vdGVyIj48cD4mbmJzcDs8
L3A+PC9zcGFuPg==
------=_Part_57699_1377556961.1463447198849--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
