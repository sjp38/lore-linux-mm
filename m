Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id BFD2C6B0038
	for <linux-mm@kvack.org>; Sat,  5 Sep 2015 06:11:42 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so47864756pac.0
        for <linux-mm@kvack.org>; Sat, 05 Sep 2015 03:11:42 -0700 (PDT)
Received: from COL004-OMC1S14.hotmail.com (col004-omc1s14.hotmail.com. [65.55.34.24])
        by mx.google.com with ESMTPS id rd1si9212338pdb.167.2015.09.05.03.11.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 05 Sep 2015 03:11:41 -0700 (PDT)
Message-ID: <COL130-W64DF8D947992A52E4CBE40B9560@phx.gbl>
From: Chen Gang <xili_gchen_5257@hotmail.com>
Subject: Re: [PATCH] mm/mmap.c: Only call vma_unlock_anon_vm() when failure
 occurs in expand_upwards() and expand_downwards()
Date: Sat, 5 Sep 2015 18:11:40 +0800
In-Reply-To: <55EAC021.3080205@hotmail.com>
References: 
 <COL130-W9593F65D7C12B5353FE079B96B0@phx.gbl>,<55E5AD17.6060901@hotmail.com>
 <COL130-W4895D78CDAEA273AB88C53B96A0@phx.gbl>,<55E96E01.5010605@hotmail.com>
 <COL130-W49B21394779B6662272AD0B9570@phx.gbl>,<55EAC021.3080205@hotmail.com>
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>
Cc: Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>, Chen Gang <gchen_5i5j@21cn.com>

SGVsbG8gQWxsOgoKSSBoYXZlIHNlbmQgMiBuZXcgcGF0Y2hlcyBhYm91dCBtbSwgYW5kIDEgcGF0
Y2ggZm9yIGFyY2ggbWV0YWcgdmlhIG15CjIxY24gbWFpbC4gQ291bGQgYW55IG1lbWJlcnMgaGVs
cCB0byB0ZWxsIG1lLCB3aGV0aGVyIGhlL3NoZSBoYXZlCnJlY2VpdmVkIHRoZSBwYXRjaGVzIG9y
IG5vdD8KCkF0IHByZXNlbnQ6CgotIEZvciBDaGluZXNlIHNpdGU6IHFxLCBzb2h1LCBzaW5hLCAx
NjMsIDIxY24gLi4uIGl0IHNlZW1zIG9ubHkgMjFjbiBPSwoocXEgaXMgbm90IGFjY2VwdGVkLCBz
b2h1LCBzaW5hLCBhbmQgMTYzIHN1cHBvcnRzIHBsYWluIHRleHQgYmFkbHkpLgoKLSBnbWFpbCBj
YW5uJ3Qgc2VuZCBwYXRjaGVzIChidXQgY2FuIHJlY2VpdmUgbWFpbCB2aWEgcXEgbWFpbCBhZGRy
ZXNzKSwKaG90bWFpbCBjYW4gb25seSBzZW5kIHBhdGNoZXMgZnJvbSB3ZWJzaXRlLgoKLSBJZiAy
MWNuIG1haWwgZG9lcyBub3Qgd29yayB3ZWxsLCBJIGd1ZXNzLCB0aGUgb25seSB3YXkgZm9yIG1l
IGlzCiJzZW5kIHBhdGNoIGluIGF0dGFjaG1lbnQgaW4gbXkgaG90bWFpbCB3ZWJzaXRlIi4KCgpX
ZWxjb21lIGFueSBpZGVhcywgc3VnZ2VzdGlvbnMsIG9yIGNvbXBsZXRpb24uCgpUaGFua3MuCgpP
biA5LzQvMTUgMTg6MDksIENoZW4gR2FuZyB3cm90ZToKPiBIZWxsbyBhbGw6Cj4KPiBJdCBzZWVt
cyAyMWNuIG1haWwgY2FuIGJlIGFjY2VwdGVkIGJ5IG91ciBtYWlsaW5nIGxpc3QgKEkgZGlkbid0
IHJlY2VpdmUKPiBhbnkgcmVqZWN0aXZlIG5vdGlmaWNhdGlvbiBtYWlsIGZyb20gb3VyIG1haWxp
bmcgbGlzdCkuCj4KPiBJZiBpdCBpcyBuZWNlc3NhcnkgdG8gc2VuZCB0aGUgcGF0Y2ggYWdhaW4g
dmlhIGdpdCBjbGllbnQsIHBsZWFzZSBsZXQgbWUKPiBrbm93LCBJIHNoYWxsIHRyeSB0byBzZW5k
IGl0IGFnYWluIHdpdGggbXkgMjFjbiBtYWlsIGFkZHJlc3MgdmlhIGdpdAo+IGNsaWVudC4KPgo+
IFdlbGNvbWUgYW55IGlkZWFzLCBzdWdnZXN0aW9ucywgYW5kIGNvbXBsZXRpb25zLgo+Cj4gVGhh
bmtzLgo+Cj4gT24gOS8xLzE1IDIxOjQ5LCBDaGVuIEdhbmcgd3JvdGU6Cj4+Cj4+IFNvcnJ5IGZv
ciB0aGUgaW5jb3JyZWN0IGZvcm1hdCBvZiB0aGUgcGF0Y2guIFNvIEkgcHV0IHRoZSBwYXRjaCBp
bnRvIHRoZQo+PiBhdHRhY2htZW50IHdoaWNoIGdlbmVyYXRlZCBieSAiZ2l0IGZvcm1hdC1wYXRj
aCAtTSBIRUFEXiIuIFBsZWFzZSBoZWxwCj4+IGNoZWNrLCB0aGFua3MuCj4+Cj4+IE5leHQsIEkg
c2hhbGwgdHJ5IHRvIGZpbmQgYW5vdGhlciBtYWlsIGFkZHJlc3Mgd2hpY2ggY2FuIGJlIGFjY2Vw
dGVkIGJ5Cj4+IGJvdGggQ2hpbmEgYW5kIG91ciBtYWlsaW5nIGxpc3QuCj4+Cj4+IFRoYW5rcy4K
Pj4KPgo+Cj4gVGhhbmtzLgo+IC0tCj4gQ2hlbiBHYW5nICizwrjVKQo+Cj4gT3Blbiwgc2hhcmUs
IGFuZCBhdHRpdHVkZSBsaWtlIGFpciwgd2F0ZXIsIGFuZCBsaWZlIHdoaWNoIEdvZCBibGVzc2Vk
Cj4KPgoKLS0KQ2hlbiBHYW5nICizwrjVKQoKT3Blbiwgc2hhcmUsIGFuZCBhdHRpdHVkZSBsaWtl
IGFpciwgd2F0ZXIsIGFuZCBsaWZlIHdoaWNoIEdvZCBibGVzc2VkCiAJCSAJICAgCQkgIA==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
