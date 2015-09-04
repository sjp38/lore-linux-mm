Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 90FB16B0254
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 06:09:51 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so20364305pac.0
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 03:09:51 -0700 (PDT)
Received: from COL004-OMC1S9.hotmail.com (col004-omc1s9.hotmail.com. [65.55.34.19])
        by mx.google.com with ESMTPS id et1si3536285pbb.49.2015.09.04.03.09.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 04 Sep 2015 03:09:50 -0700 (PDT)
Message-ID: <COL130-W49B21394779B6662272AD0B9570@phx.gbl>
From: Chen Gang <xili_gchen_5257@hotmail.com>
Subject: Re: [PATCH] mm/mmap.c: Only call vma_unlock_anon_vm() when failure
 occurs in expand_upwards() and expand_downwards()
Date: Fri, 4 Sep 2015 18:09:50 +0800
In-Reply-To: <55E96E01.5010605@hotmail.com>
References: 
 <COL130-W9593F65D7C12B5353FE079B96B0@phx.gbl>,<55E5AD17.6060901@hotmail.com>
 <COL130-W4895D78CDAEA273AB88C53B96A0@phx.gbl>,<55E96E01.5010605@hotmail.com>
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>
Cc: Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>, Chen Gang <gchen_5i5j@21cn.com>

SGVsbG8gYWxsOgoKSXQgc2VlbXMgMjFjbiBtYWlsIGNhbiBiZSBhY2NlcHRlZCBieSBvdXIgbWFp
bGluZyBsaXN0IChJIGRpZG4ndCByZWNlaXZlCmFueSByZWplY3RpdmUgbm90aWZpY2F0aW9uIG1h
aWwgZnJvbSBvdXIgbWFpbGluZyBsaXN0KS4KCklmIGl0IGlzIG5lY2Vzc2FyeSB0byBzZW5kIHRo
ZSBwYXRjaCBhZ2FpbiB2aWEgZ2l0IGNsaWVudCwgcGxlYXNlIGxldCBtZQprbm93LCBJIHNoYWxs
IHRyeSB0byBzZW5kIGl0IGFnYWluIHdpdGggbXkgMjFjbiBtYWlsIGFkZHJlc3MgdmlhIGdpdApj
bGllbnQuCgpXZWxjb21lIGFueSBpZGVhcywgc3VnZ2VzdGlvbnMsIGFuZCBjb21wbGV0aW9ucy4K
ClRoYW5rcy4KCk9uIDkvMS8xNSAyMTo0OSwgQ2hlbiBHYW5nIHdyb3RlOgo+Cj4gU29ycnkgZm9y
IHRoZSBpbmNvcnJlY3QgZm9ybWF0IG9mIHRoZSBwYXRjaC4gU28gSSBwdXQgdGhlIHBhdGNoIGlu
dG8gdGhlCj4gYXR0YWNobWVudCB3aGljaCBnZW5lcmF0ZWQgYnkgImdpdCBmb3JtYXQtcGF0Y2gg
LU0gSEVBRF4iLiBQbGVhc2UgaGVscAo+IGNoZWNrLCB0aGFua3MuCj4KPiBOZXh0LCBJIHNoYWxs
IHRyeSB0byBmaW5kIGFub3RoZXIgbWFpbCBhZGRyZXNzIHdoaWNoIGNhbiBiZSBhY2NlcHRlZCBi
eQo+IGJvdGggQ2hpbmEgYW5kIG91ciBtYWlsaW5nIGxpc3QuCj4KPiBUaGFua3MuCj4KCgpUaGFu
a3MuCi0tCkNoZW4gR2FuZyAos8K41SkKCk9wZW4sIHNoYXJlLCBhbmQgYXR0aXR1ZGUgbGlrZSBh
aXIsIHdhdGVyLCBhbmQgbGlmZSB3aGljaCBHb2QgYmxlc3NlZAogCQkgCSAgIAkJICA=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
