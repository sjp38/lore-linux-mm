Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 60AB96B0005
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 21:03:56 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id 203-v6so1776998ybf.19
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 18:03:56 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id k138-v6si6049971ybf.119.2018.10.09.18.03.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 18:03:55 -0700 (PDT)
From: Rik van Riel <riel@fb.com>
Subject: Re: [PATCH 4/4] mm: zero-seek shrinkers
Date: Wed, 10 Oct 2018 01:03:50 +0000
Message-ID: <e01c4f441e24bb31816a3080389dcae7b49cc1ff.camel@fb.com>
References: <20181009184732.762-1-hannes@cmpxchg.org>
	 <20181009184732.762-5-hannes@cmpxchg.org>
In-Reply-To: <20181009184732.762-5-hannes@cmpxchg.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <C63FB951EA41CE49847DF2A2363D056C@namprd15.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>

T24gVHVlLCAyMDE4LTEwLTA5IGF0IDE0OjQ3IC0wNDAwLCBKb2hhbm5lcyBXZWluZXIgd3JvdGU6
DQoNCj4gVGhlc2Ugd29ya2xvYWRzIGFsc28gZGVhbCB3aXRoIHRlbnMgb2YgdGhvdXNhbmRzIG9m
IG9wZW4gZmlsZXMgYW5kDQo+IHVzZQ0KPiAvcHJvYyBmb3IgaW50cm9zcGVjdGlvbiwgd2hpY2gg
ZW5kcyB1cCBncm93aW5nIHRoZSBwcm9jX2lub2RlX2NhY2hlDQo+IHRvDQo+IGFic3VyZGx5IGxh
cmdlIHNpemVzIC0gYWdhaW4gYXQgdGhlIGNvc3Qgb2YgdmFsdWFibGUgY2FjaGUgc3BhY2UsDQo+
IHdoaWNoIGlzbid0IGEgcmVhc29uYWJsZSB0cmFkZS1vZmYsIGdpdmVuIHRoYXQgcHJvYyBpbm9k
ZXMgY2FuIGJlDQo+IHJlLWNyZWF0ZWQgd2l0aG91dCBpbnZvbHZpbmcgdGhlIGRpc2suDQo+IA0K
PiBUaGlzIHBhdGNoIGltcGxlbWVudHMgYSAiemVyby1zZWVrIiBzZXR0aW5nIGZvciBzaHJpbmtl
cnMgdGhhdA0KPiByZXN1bHRzDQo+IGluIGEgdGFyZ2V0IHJhdGlvIG9mIDA6MSBiZXR3ZWVuIHRo
ZWlyIG9iamVjdHMgYW5kIElPLWJhY2tlZA0KPiBjYWNoZXMuIFRoaXMgYWxsb3dzIHN1Y2ggdmly
dHVhbCBjYWNoZXMgdG8gZ3JvdyB3aGVuIG1lbW9yeSBpcw0KPiBhdmFpbGFibGUgKHRoZXkgZG8g
Y2FjaGUvYXZvaWQgQ1BVIHdvcmsgYWZ0ZXIgYWxsKSwgYnV0IGVmZmVjdGl2ZWx5DQo+IGRpc2Fi
bGVzIHRoZW0gYXMgc29vbiBhcyBJTy1iYWNrZWQgb2JqZWN0cyBhcmUgdW5kZXIgcHJlc3N1cmUu
DQo+IA0KPiBJdCB0aGVuIHN3aXRjaGVzIHRoZSBzaHJpbmtlcnMgZm9yIHByb2NmcyBhbmQgc3lz
ZnMgbWV0YWRhdGEsIGFzIHdlbGwNCj4gYXMgZXhjZXNzIHBhZ2UgY2FjaGUgc2hhZG93IG5vZGVz
LCB0byB0aGUgbmV3IHplcm8tc2VlayBzZXR0aW5nLg0KDQpUaGlzIHBhdGNoIGxvb2tzIGxpa2Ug
YSBncmVhdCBzdGVwIGluIHRoZSByaWdodA0KZGlyZWN0aW9uLCB0aG91Z2ggSSBkbyBub3Qga25v
dyB3aGV0aGVyIGl0IGlzDQphZ2dyZXNzaXZlIGVub3VnaC4NCg0KR2l2ZW4gdGhhdCBpbnRlcm5h
bCBzbGFiIGZyYWdtZW50YXRpb24gd2lsbA0KcHJldmVudCB0aGUgc2xhYiBjYWNoZSBmcm9tIHJl
dHVybmluZyBhIHNsYWIgdG8NCnRoZSBWTSBpZiBqdXN0IG9uZSBvYmplY3QgaW4gdGhhdCBzbGFi
IGlzIHN0aWxsDQppbiB1c2UsIHRoZXJlIG1heSB3ZWxsIGJlIHdvcmtsb2FkcyB3aGVyZSB3ZQ0K
c2hvdWxkIGp1c3QgcHV0IGEgaGFyZCBjYXAgb24gdGhlIG51bWJlciBvZg0KZnJlZWFibGUgaXRl
bXMgdGhlc2Ugc2xhYnMsIGFuZCByZWNsYWltIHRoZW0NCnByZWVtcHRpdmVseS4NCg0KSG93ZXZl
ciwgSSBkbyBub3Qga25vdyBmb3Igc3VyZSwgYW5kIHRoaXMgcGF0Y2gNCnNlZW1zIGxpa2UgYSBi
aWcgaW1wcm92ZW1lbnQgb3ZlciB3aGF0IHdlIGhhZA0KYmVmb3JlLCBzbyAuLi4NCg0KPiBSZXBv
cnRlZC1ieTogRG9tYXMgTWl0dXphcyA8ZG1pdHV6YXNAZmIuY29tPg0KPiBTaWduZWQtb2ZmLWJ5
OiBKb2hhbm5lcyBXZWluZXIgPGhhbm5lc0BjbXB4Y2hnLm9yZz4NCg0KUmV2aWV3ZWQtYnk6IFJp
ayB2YW4gUmllbCA8cmllbEBzdXJyaWVsLmNvbT4NCg0K
