Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5AE5B6B0038
	for <linux-mm@kvack.org>; Sun, 23 Aug 2015 13:28:56 -0400 (EDT)
Received: by pdob1 with SMTP id b1so44287629pdo.2
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 10:28:56 -0700 (PDT)
Received: from COL004-OMC2S11.hotmail.com (col004-omc2s11.hotmail.com. [65.55.34.85])
        by mx.google.com with ESMTPS id le8si23240153pab.136.2015.08.23.10.28.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 23 Aug 2015 10:28:55 -0700 (PDT)
Message-ID: <COL130-W243DFFC807CCFA53BF26BCB9630@phx.gbl>
From: Chen Gang <xili_gchen_5257@hotmail.com>
Subject: RE: [PATCH] mm: mmap: Simplify the failure return working flow
Date: Mon, 24 Aug 2015 01:28:54 +0800
In-Reply-To: <COL130-W93ACD1C6A54A0035AAF173B9660@phx.gbl>
References: 
 <55D5275D.7020406@hotmail.com>,<COL130-W46B6A43FC26795B43939E0B9660@phx.gbl>,<55D52CDE.8060700@hotmail.com>,<COL130-W42D1358B7EBBCA5F39DA3CB9660@phx.gbl>,<20150820074521.GC4780@dhcp22.suse.cz>,<55D593C2.3040105@hotmail.com>,<COL130-W93ACD1C6A54A0035AAF173B9660@phx.gbl>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel mailing list <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, Linux Memory <linux-mm@kvack.org>

LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQo+IEZyb206IHhpbGlfZ2No
ZW5fNTI1N0Bob3RtYWlsLmNvbQo+IFRvOiBtaG9ja29Aa2VybmVsLm9yZwo+IENDOiBha3BtQGxp
bnV4LWZvdW5kYXRpb24ub3JnOyBsaW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3JnOyBraXJpbGwu
c2h1dGVtb3ZAbGludXguaW50ZWwuY29tOyByaWVsQHJlZGhhdC5jb207IHNhc2hhLmxldmluQG9y
YWNsZS5jb207IGxpbnV4LW1tQGt2YWNrLm9yZwo+IFN1YmplY3Q6IFJlOiBbUEFUQ0hdIG1tOiBt
bWFwOiBTaW1wbGlmeSB0aGUgZmFpbHVyZSByZXR1cm4gd29ya2luZyBmbG93Cj4gRGF0ZTogVGh1
LCAyMCBBdWcgMjAxNSAxNjo0ODoyMSArMDgwMAo+Cj4gT24gMjAxNeW5tDA45pyIMjDml6UgMTU6
NDUsIE1pY2hhbCBIb2NrbyB3cm90ZToKPj4gT24gVGh1IDIwLTA4LTE1IDA5OjI3OjQyLCBnY2hl
biBnY2hlbiB3cm90ZToKPj4gWy4uLl0KPj4+IFllcywgaXQgaXMgcmVhbGx5IHBlY3VsaWFyLCB0
aGUgcmVhc29uIGlzIGdtYWlsIGlzIG5vdCBzdGFibGUgaW4gQ2hpbmEuCj4+PiBJIGhhdmUgdG8g
c2VuZCBtYWlsIGluIG15IGhvdG1haWwgYWRkcmVzcy4KPj4+Cj4+PiBCdXQgSSBzdGlsbCB3YW50
IHRvIHVzZSBteSBnbWFpbCBhcyBTaWduZWQtb2ZmLWJ5LCBzaW5jZSBJIGhhdmUgYWxyZWFkeQo+
Pj4gdXNlZCBpdCwgYW5kIGFsc28gaXRzIG5hbWUgaXMgYSBsaXR0bGUgZm9ybWFsIHRoYW4gbXkg
aG90bWFpbC4KPj4+Cj4+PiBXZWxjb21lIGFueSBpZGVhcywgc3VnZ2VzdGlvbnMgYW5kIGNvbXBs
ZXRpb25zIGZvciBpdCAoZS5nLiBpZiBpdCBpcwo+Pj4gbmVjZXNzYXJ5IHRvIGxldCBzZW5kIG1h
aWwgYW5kIFNpZ25lZC1vZmYtYnkgbWFpbCBiZSB0aGUgc2FtZSwgSSBzaGFsbAo+Pj4gdHJ5KS4K
Pj4KPj4gWW91IGNhbiBkbyB0aGUgZm9sbG93aW5nIGluIHlvdXIgLmdpdC9jb25maWcKPj4KPj4g
W3VzZXJdCj4+IG5hbWUgPSBZT1VSX05BTUVfRk9SX1MtTy1CCj4+IGVtYWlsID0gWU9VUl9HTUFJ
TF9BRERSRVNTCj4+IFtzZW5kZW1haWxdCj4+IGZyb20gPSBZT1VSX1NUQUJMRV9TRU5ERVJfQURE
UkVTUwo+PiBlbnZlbG9wZXNlbmRlciA9IFlPVVJfU1RBQkxFX1NFTkRFUl9BRERSRVNTCj4+IHNt
dHBzZXJ2ZXIgPSBZT1VSX1NUQUJMRV9TTVRQCj4+Cj4+IFt1c2VyXSBwYXJ0IHdpbGwgYmUgdXNl
ZCBmb3Igcy1vLWIgYW5kIEF1dGhvciBlbWFpbCB3aGlsZSB0aGUgc2VuZGVtYWlsCj4+IHdpbGwg
YmUgdXNlZCBmb3IgZ2l0IHNlbmQtZW1haWwgdG8gcm91dGUgdGhlIHBhdGNoIHByb3Blcmx5LiBJ
ZiB0aGUgdHdvCj4+IGRpZmZlciBpdCB3aWxsIGFkZCBGcm9tOiB1c2VyLm5hbWUgPHVzZXIuZW1h
aWw+IGFzIHN1Z2dlc3RlZCBieSBBbmRyZXcuCj4+Cj4KCk9oLCBzb3JyeSwgaXQgc2VlbXMsIEkg
aGF2ZSB0byBzZW5kIG1haWwgaW4gaG90bWFpbCB3ZWJzaXRlIChJIGNhbiBzZW5kIGdtYWlsCm5l
aXRoZXIgdW5kZXIgY2xpZW50IG5vciB1bmRlciB3ZWJzaXRlKS4KCmxpbnV4IGtlcm5lbCBtYWls
aW5nIGxpc3QgZG9lcyBub3QgYWNjZXB0IFFRIG1haWwuIEVpdGhlciBhdCBwcmVzZW50LCBJIGNh
bgpub3Qgc2VuZCBob3RtYWlsIGZyb20gY2xpZW50ICh0aHVuZGVyYmlyZCBjbGllbnQsIGdpdCBj
bGllbnQpLCBJIGd1ZXNzIHRoZQpyZWFzb24gaXMgdGhlIGhvdG1haWwgaXMgYmxvY2tlZCBpbiBD
aGluYSAoYnV0IFFRIGlzIG9mIGNhdXNlIE9LwqBpbiBDaGluYSkuCgpTbyAuLi4gaXQgaXMgYSBi
YWQgbmV3cyB0byB1cyBhbGwuIDotKCDCoFdlbGNvbWUgYW55IHJlbGF0ZWQgaWRlYXMsIHN1Z2dl
c3Rpb25zCmFuIGNvbXBsZXRpb25zLgoKVGhhbmtzLgoKPiBPSywgdGhhbmsgeW91ciB2ZXJ5IG11
Y2ggZm9yIHlvdXIgZGV0YWlscyBpbmZvcm1hdGlvbi4gOi0pCj4KPiBJIHNoYWxsIHRyeSB0byB1
c2UgZ2l0IHRvIHNlbmQvcmVjdiBtYWlscyBpbnN0ZWFkIG9mIGN1cnJlbnQgdGh1bmRlcmJpcmQK
PiBjbGllbnQgKGhvcGUgSSBjYW4gZG8gaXQgbmV4dCB0aW1lLCBhbHRob3VnaCBJIGFtIG5vdCBx
dWl0ZSBzdXJlKS4KPgo+Cj4gVGhhbmtzLgo+IC0tCj4gQ2hlbiBHYW5nCj4KPiBPcGVuLCBzaGFy
ZSwgYW5kIGF0dGl0dWRlIGxpa2UgYWlyLCB3YXRlciwgYW5kIGxpZmUgd2hpY2ggR29kIGJsZXNz
ZWQKPgogCQkgCSAgIAkJICA=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
