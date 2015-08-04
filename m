Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id B54626B0253
	for <linux-mm@kvack.org>; Mon,  3 Aug 2015 22:56:48 -0400 (EDT)
Received: by padck2 with SMTP id ck2so104420795pad.0
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 19:56:48 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id hp8si29921861pac.226.2015.08.03.19.56.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Aug 2015 19:56:47 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: hugetlb pages not accounted for in rss
Date: Tue, 4 Aug 2015 02:55:30 +0000
Message-ID: <20150804025530.GA13210@hori1.linux.bs1.fc.nec.co.jp>
References: <55B6BE37.3010804@oracle.com>
 <20150728183248.GB1406@Sligo.logfs.org> <55B7F0F8.8080909@oracle.com>
 <alpine.DEB.2.10.1507281509420.23577@chino.kir.corp.google.com>
 <20150728222654.GA28456@Sligo.logfs.org>
 <alpine.DEB.2.10.1507281622470.10368@chino.kir.corp.google.com>
 <20150729005332.GB17938@Sligo.logfs.org>
 <alpine.DEB.2.10.1507291205590.24373@chino.kir.corp.google.com>
 <55B95FDB.1000801@oracle.com>
In-Reply-To: <55B95FDB.1000801@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="utf-8"
Content-ID: <18A38E793700D44A88AAC373F8BC250B@gisp.nec.co.jp>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: David Rientjes <rientjes@google.com>, =?utf-8?B?SsO2cm4gRW5nZWw=?= <joern@purestorage.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

T24gV2VkLCBKdWwgMjksIDIwMTUgYXQgMDQ6MjA6NTlQTSAtMDcwMCwgTWlrZSBLcmF2ZXR6IHdy
b3RlOg0KPiBPbiAwNy8yOS8yMDE1IDEyOjA4IFBNLCBEYXZpZCBSaWVudGplcyB3cm90ZToNCj4g
Pk9uIFR1ZSwgMjggSnVsIDIwMTUsIErDtnJuIEVuZ2VsIHdyb3RlOg0KPiA+DQo+ID4+V2VsbCwg
d2UgZGVmaW5pdGVseSBuZWVkIHNvbWV0aGluZy4gIEhhdmluZyBhIDEwMEdCIHByb2Nlc3Mgc2hv
dyAzR0Igb2YNCj4gPj5yc3MgaXMgbm90IHZlcnkgdXNlZnVsLiAgSG93IHdvdWxkIHdlIG5vdGlj
ZSBhIG1lbW9yeSBsZWFrIGlmIGl0IG9ubHkNCj4gPj5hZmZlY3RzIGh1Z2VwYWdlcywgZm9yIGV4
YW1wbGU/DQo+ID4+DQo+ID4NCj4gPlNpbmNlIHRoZSBodWdldGxiIHBvb2wgaXMgYSBnbG9iYWwg
cmVzb3VyY2UsIGl0IHdvdWxkIGFsc28gYmUgaGVscGZ1bCB0bw0KPiA+ZGV0ZXJtaW5lIGlmIGEg
cHJvY2VzcyBpcyBtYXBwaW5nIG1vcmUgdGhhbiBleHBlY3RlZC4gIFlvdSBjYW4ndCBkbyB0aGF0
DQo+ID5qdXN0IGJ5IGFkZGluZyBhIGh1Z2UgcnNzIG1ldHJpYywgaG93ZXZlcjogaWYgeW91IGhh
dmUgMk1CIGFuZCAxR0INCj4gPmh1Z2VwYWdlcyBjb25maWd1cmVkIHlvdSB3b3VsZG4ndCBrbm93
IGlmIGEgcHJvY2VzcyB3YXMgbWFwcGluZyA1MTIgMk1CDQo+ID5odWdlcGFnZXMgb3IgMSAxR0Ig
aHVnZXBhZ2UuDQo+ID4NCj4gPlRoYXQncyB0aGUgcHVycG9zZSBvZiBodWdldGxiX2Nncm91cCwg
YWZ0ZXIgYWxsLCBhbmQgaXQgc3VwcG9ydHMgdXNhZ2UNCj4gPmNvdW50ZXJzIGZvciBhbGwgaHN0
YXRlcy4gIFRoZSB0ZXN0IGNvdWxkIGJlIGNvbnZlcnRlZCB0byB1c2UgdGhhdCB0bw0KPiA+bWVh
c3VyZSB1c2FnZSBpZiBjb25maWd1cmVkIGluIHRoZSBrZXJuZWwuDQo+ID4NCj4gPkJleW9uZCB0
aGF0LCBJJ20gbm90IHN1cmUgaG93IGEgcGVyLWhzdGF0ZSByc3MgbWV0cmljIHdvdWxkIGJlIGV4
cG9ydGVkIHRvDQo+ID51c2Vyc3BhY2UgaW4gYSBjbGVhbiB3YXkgYW5kIG90aGVyIHdheXMgb2Yg
b2J0YWluaW5nIHRoZSBzYW1lIGRhdGEgYXJlDQo+ID5wb3NzaWJsZSB3aXRoIGh1Z2V0bGJfY2dy
b3VwLiAgSSdtIG5vdCBzdXJlIGhvdyBzdWNjZXNzZnVsIHlvdSdkIGJlIGluDQo+ID5hcmd1aW5n
IHRoYXQgd2UgbmVlZCBzZXBhcmF0ZSByc3MgY291bnRlcnMgZm9yIGl0Lg0KPg0KPiBJZiBJIHdh
bnQgdG8gdHJhY2sgaHVnZXRsYiB1c2FnZSBvbiBhIHBlci10YXNrIGJhc2lzLCBkbyBJIHRoZW4g
bmVlZCB0bw0KPiBjcmVhdGUgb25lIGNncm91cCBwZXIgdGFzaz8NCj4NCj4gRm9yIGV4YW1wbGUs
IHN1cHBvc2UgSSBoYXZlIG1hbnkgdGFza3MgdXNpbmcgaHVnZXRsYiBhbmQgdGhlIGdsb2JhbCBw
b29sDQo+IGlzIGdldHRpbmcgbG93IG9uIGZyZWUgcGFnZXMuICBJdCBtaWdodCBiZSB1c2VmdWwg
dG8ga25vdyB3aGljaCB0YXNrcyBhcmUNCj4gdXNpbmcgaHVnZXRsYiBwYWdlcywgYW5kIGhvdyBt
YW55IHRoZXkgYXJlIHVzaW5nLg0KPg0KPiBJIGRvbid0IGFjdHVhbGx5IGhhdmUgdGhpcyBuZWVk
IChJIHRoaW5rKSwgYnV0IGl0IGFwcGVhcnMgdG8gYmUgd2hhdA0KPiBKw7ZybiBpcyBhc2tpbmcg
Zm9yLg0KDQpPbmUgcG9zc2libGUgd2F5IHRvIGdldCBodWdldGxiIG1ldHJpYyBpbiBwZXItdGFz
ayBiYXNpcyBpcyB0byB3YWxrIHBhZ2UNCnRhYmxlIHZpYSAvcHJvYy9waWQvcGFnZW1hcCwgYW5k
IGNvdW50aW5nIHBhZ2UgZmxhZ3MgZm9yIGVhY2ggbWFwcGVkIHBhZ2UNCih3ZSBjYW4gZWFzaWx5
IGRvIHRoaXMgd2l0aCB0b29scy92bS9wYWdlLXR5cGVzLmMgbGlrZSAicGFnZS10eXBlcyAtcCA8
UElEPg0KLWIgaHVnZSIpLiBUaGlzIGlzIG9idmlvdXNseSBzbG93ZXIgdGhhbiBqdXN0IHN0b3Jp
bmcgdGhlIGNvdW50ZXIgYXMNCmluLWtlcm5lbCBkYXRhIGFuZCBqdXN0IGV4cG9ydGluZyBpdCwg
YnV0IG1pZ2h0IGJlIHVzZWZ1bCBpbiBzb21lIHNpdHVhdGlvbi4NCg0KVGhhbmtzLA0KTmFveWEg
SG9yaWd1Y2hp

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
