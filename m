Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 60A126B0253
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 04:48:23 -0400 (EDT)
Received: by pdrh1 with SMTP id h1so12120856pdr.0
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 01:48:23 -0700 (PDT)
Received: from COL004-OMC2S11.hotmail.com (col004-omc2s11.hotmail.com. [65.55.34.85])
        by mx.google.com with ESMTPS id rj13si6433120pdb.84.2015.08.20.01.48.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 20 Aug 2015 01:48:22 -0700 (PDT)
Message-ID: <COL130-W93ACD1C6A54A0035AAF173B9660@phx.gbl>
From: gchen gchen <xili_gchen_5257@hotmail.com>
Subject: Re: [PATCH] mm: mmap: Simplify the failure return working flow
Date: Thu, 20 Aug 2015 16:48:21 +0800
In-Reply-To: <55D593C2.3040105@hotmail.com>
References: <55D5275D.7020406@hotmail.com>
 <COL130-W46B6A43FC26795B43939E0B9660@phx.gbl> <55D52CDE.8060700@hotmail.com>
 <COL130-W42D1358B7EBBCA5F39DA3CB9660@phx.gbl>
 <20150820074521.GC4780@dhcp22.suse.cz>,<55D593C2.3040105@hotmail.com>
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel mailing list <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, Linux Memory <linux-mm@kvack.org>

T24gMjAxNcTqMDjUwjIwyNUgMTU6NDUsIE1pY2hhbCBIb2NrbyB3cm90ZToKPiBPbiBUaHUgMjAt
MDgtMTUgMDk6Mjc6NDIsIGdjaGVuIGdjaGVuIHdyb3RlOgo+IFsuLi5dCj4+IFllcywgaXQgaXMg
cmVhbGx5IHBlY3VsaWFyLCB0aGUgcmVhc29uIGlzIGdtYWlsIGlzIG5vdCBzdGFibGUgaW4gQ2hp
bmEuCj4+IEkgaGF2ZSB0byBzZW5kIG1haWwgaW4gbXkgaG90bWFpbCBhZGRyZXNzLgo+Pgo+PiBC
dXQgSSBzdGlsbCB3YW50IHRvIHVzZSBteSBnbWFpbCBhcyBTaWduZWQtb2ZmLWJ5LCBzaW5jZSBJ
IGhhdmUgYWxyZWFkeQo+PiB1c2VkIGl0LCBhbmQgYWxzbyBpdHMgbmFtZSBpcyBhIGxpdHRsZSBm
b3JtYWwgdGhhbiBteSBob3RtYWlsLgo+Pgo+PiBXZWxjb21lIGFueSBpZGVhcywgc3VnZ2VzdGlv
bnMgYW5kIGNvbXBsZXRpb25zIGZvciBpdCAoZS5nLiBpZiBpdCBpcwo+PiBuZWNlc3NhcnkgdG8g
bGV0IHNlbmQgbWFpbCBhbmQgU2lnbmVkLW9mZi1ieSBtYWlsIGJlIHRoZSBzYW1lLCBJIHNoYWxs
Cj4+IHRyeSkuCj4KPiBZb3UgY2FuIGRvIHRoZSBmb2xsb3dpbmcgaW4geW91ciAuZ2l0L2NvbmZp
Zwo+Cj4gW3VzZXJdCj4gICAgICAgbmFtZSA9IFlPVVJfTkFNRV9GT1JfUy1PLUIKPiAgICAgICBl
bWFpbCA9IFlPVVJfR01BSUxfQUREUkVTUwo+IFtzZW5kZW1haWxdCj4gICAgICAgZnJvbSA9IFlP
VVJfU1RBQkxFX1NFTkRFUl9BRERSRVNTCj4gICAgICAgZW52ZWxvcGVzZW5kZXIgPSBZT1VSX1NU
QUJMRV9TRU5ERVJfQUREUkVTUwo+ICAgICAgIHNtdHBzZXJ2ZXIgPSBZT1VSX1NUQUJMRV9TTVRQ
Cj4KPiBbdXNlcl0gcGFydCB3aWxsIGJlIHVzZWQgZm9yIHMtby1iIGFuZCBBdXRob3IgZW1haWwg
d2hpbGUgdGhlIHNlbmRlbWFpbAo+IHdpbGwgYmUgdXNlZCBmb3IgZ2l0IHNlbmQtZW1haWwgdG8g
cm91dGUgdGhlIHBhdGNoIHByb3Blcmx5LiBJZiB0aGUgdHdvCj4gZGlmZmVyIGl0IHdpbGwgYWRk
IEZyb206IHVzZXIubmFtZSA8dXNlci5lbWFpbD4gYXMgc3VnZ2VzdGVkIGJ5IEFuZHJldy4KPgoK
T0ssIHRoYW5rIHlvdXIgdmVyeSBtdWNoIGZvciB5b3VyIGRldGFpbHMgaW5mb3JtYXRpb24uIDot
KQoKSSBzaGFsbCB0cnkgdG8gdXNlIGdpdCB0byBzZW5kL3JlY3YgbWFpbHMgaW5zdGVhZCBvZiBj
dXJyZW50IHRodW5kZXJiaXJkCmNsaWVudCAoaG9wZSBJIGNhbiBkbyBpdCBuZXh0IHRpbWUsIGFs
dGhvdWdoIEkgYW0gbm90IHF1aXRlIHN1cmUpLgoKClRoYW5rcy4KLS0KQ2hlbiBHYW5nCgpPcGVu
LCBzaGFyZSwgYW5kIGF0dGl0dWRlIGxpa2UgYWlyLCB3YXRlciwgYW5kIGxpZmUgd2hpY2ggR29k
IGJsZXNzZWQKIAkJIAkgICAJCSAg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
