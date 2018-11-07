Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 94C8C6B054C
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 15:03:57 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id w10-v6so15549911plz.0
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 12:03:57 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id y19-v6si1592728plp.61.2018.11.07.12.03.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 12:03:56 -0800 (PST)
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Subject: Re: [PATCH v8 4/4] Kselftest for module text allocation benchmarking
Date: Wed, 7 Nov 2018 20:03:54 +0000
Message-ID: <97833c125c44ec2a8d7f96f667425d600a4fb7e3.camel@intel.com>
References: <20181102192520.4522-1-rick.p.edgecombe@intel.com>
	 <20181102192520.4522-5-rick.p.edgecombe@intel.com>
	 <20181106130557.11bfeddafe103bb609352aba@linux-foundation.org>
In-Reply-To: <20181106130557.11bfeddafe103bb609352aba@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <342C7B15C3C9B946B5AC87FAB57D2576@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "daniel@iogearbox.net" <daniel@iogearbox.net>, "jeyu@kernel.org" <jeyu@kernel.org>, "keescook@chromium.org" <keescook@chromium.org>, "jannh@google.com" <jannh@google.com>, "willy@infradead.org" <willy@infradead.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "arjan@linux.intel.com" <arjan@linux.intel.com>, "x86@kernel.org" <x86@kernel.org>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "Hansen, Dave" <dave.hansen@intel.com>

T24gVHVlLCAyMDE4LTExLTA2IGF0IDEzOjA1IC0wODAwLCBBbmRyZXcgTW9ydG9uIHdyb3RlOg0K
PiBPbiBGcmksICAyIE5vdiAyMDE4IDEyOjI1OjIwIC0wNzAwIFJpY2sgRWRnZWNvbWJlIDxyaWNr
LnAuZWRnZWNvbWJlQGludGVsLmNvbT4NCj4gd3JvdGU6DQo+IA0KPiA+IFRoaXMgYWRkcyBhIHRl
c3QgbW9kdWxlIGluIGxpYi8sIGFuZCBhIHNjcmlwdCBpbiBrc2VsZnRlc3QgdGhhdCBkb2VzDQo+
ID4gYmVuY2htYXJraW5nIG9uIHRoZSBhbGxvY2F0aW9uIG9mIG1lbW9yeSBpbiB0aGUgbW9kdWxl
IHNwYWNlLiBQZXJmb3JtYW5jZQ0KPiA+IGhlcmUNCj4gPiB3b3VsZCBoYXZlIHNvbWUgc21hbGwg
aW1wYWN0IG9uIGtlcm5lbCBtb2R1bGUgaW5zZXJ0aW9ucywgQlBGIEpJVCBpbnNlcnRpb25zDQo+
ID4gYW5kIGtwcm9iZXMuIEluIHRoZSBjYXNlIG9mIEtBU0xSIGZlYXR1cmVzIGZvciB0aGUgbW9k
dWxlIHNwYWNlLCB0aGlzIG1vZHVsZQ0KPiA+IGNhbiBiZSB1c2VkIHRvIG1lYXN1cmUgdGhlIGFs
bG9jYXRpb24gcGVyZm9ybWFuY2Ugb2YgZGlmZmVyZW50DQo+ID4gY29uZmlndXJhdGlvbnMuDQo+
ID4gVGhpcyBtb2R1bGUgbmVlZHMgdG8gYmUgY29tcGlsZWQgaW50byB0aGUga2VybmVsIGJlY2F1
c2UgbW9kdWxlX2FsbG9jIGlzIG5vdA0KPiA+IGV4cG9ydGVkLg0KPiANCj4gV2VsbCwgd2UgY291
bGQgZXhwb3J0IG1vZHVsZV9hbGxvYygpLiAgV291bGQgdGhhdCBiZSBoZWxwZnVsIGF0IGFsbD8N
CkZvciBtZSBhdCBsZWFzdCwgaXQgd2Fzbid0IGFuIGlzc3VlIHRvIGNvbXBpbGUgaXQgaW50byB0
aGUga2VybmVsLCBzaW5jZSBpdHMNCmp1c3QgZm9yIGRldmVsb3BtZW50IHRlc3RpbmcuIFNpbmNl
IGl0cyBjb250cm9sbGVkIHRocm91Z2ggZGVidWdmcywgaXQgZG9lc24ndA0KZG8gYW55dGhpbmcg
dW50aWwgeW91IHdyaXRlIHRvIGl0Lg0KDQo+ID4gV2l0aCBzb21lIG1vZGlmaWNhdGlvbiB0byB0
aGUgY29kZSwgYXMgZXhwbGFpbmVkIGluIHRoZSBjb21tZW50cywgaXQgY2FuIGJlDQo+ID4gZW5h
YmxlZCB0byBtZWFzdXJlIFRMQiBmbHVzaGVzIGFzIHdlbGwuDQo+ID4gDQo+ID4gVGhlcmUgYXJl
IHR3byB0ZXN0cyBpbiB0aGUgbW9kdWxlLiBPbmUgYWxsb2NhdGVzIHVudGlsIGZhaWx1cmUgaW4g
b3JkZXIgdG8NCj4gPiB0ZXN0IG1vZHVsZSBjYXBhY2l0eSBhbmQgdGhlIG90aGVyIHRpbWVzIGFs
bG9jYXRpbmcgc3BhY2UgaW4gdGhlIG1vZHVsZQ0KPiA+IGFyZWEuDQo+ID4gVGhleSBib3RoIHVz
ZSBtb2R1bGUgc2l6ZXMgdGhhdCByb3VnaGx5IGFwcHJveGltYXRlIHRoZSBkaXN0cmlidXRpb24g
b2YgaW4tDQo+ID4gdHJlZQ0KPiA+IFg4Nl82NCBtb2R1bGVzLg0KPiA+IA0KPiA+IFlvdSBjYW4g
Y29udHJvbCB0aGUgbnVtYmVyIG9mIG1vZHVsZXMgdXNlZCBpbiB0aGUgdGVzdHMgbGlrZSB0aGlz
Og0KPiA+IGVjaG8gbTEwMDA+L2Rldi9tb2RfYWxsb2NfdGVzdA0KPiA+IA0KPiA+IFJ1biB0aGUg
dGVzdCBmb3IgbW9kdWxlIGNhcGFjaXR5IGxpa2U6DQo+ID4gZWNobyB0MT4vZGV2L21vZF9hbGxv
Y190ZXN0DQo+ID4gDQo+ID4gVGhlIG90aGVyIHRlc3Qgd2lsbCBtZWFzdXJlIHRoZSBhbGxvY2F0
aW9uIHRpbWUsIGFuZCBmb3IgQ09ORkdfWDg2XzY0IGFuZA0KPiA+IENPTkZJR19SQU5ET01JWkVf
QkFTRSwgYWxzbyBnaXZlIGRhdGEgb24gaG93IG9mdGVuIHRoZSDigJxiYWNrdXAgYXJlYSIgaXMN
Cj4gPiB1c2VkLg0KPiA+IA0KPiA+IFJ1biB0aGUgdGVzdCBmb3IgYWxsb2NhdGlvbiB0aW1lIGFu
ZCBiYWNrdXAgYXJlYSB1c2FnZSBsaWtlOg0KPiA+IGVjaG8gdDI+L2Rldi9tb2RfYWxsb2NfdGVz
dA0KPiA+IFRoZSBvdXRwdXQgd2lsbCBiZSBzb21ldGhpbmcgbGlrZSB0aGlzOg0KPiA+IG51bQkJ
YWxsKG5zKQkJbGFzdChucykNCj4gPiAxMDAwCQkxMDgzCQkxMDk5DQo+ID4gTGFzdCBtb2R1bGUg
aW4gYmFja3VwIGNvdW50ID0gMA0KPiA+IFRvdGFsIG1vZHVsZXMgaW4gYmFja3VwICAgICA9IDAN
Cj4gPiA+IDEgbW9kdWxlIGluIGJhY2t1cCBjb3VudCAgID0gMA0KPiANCj4gQXJlIHRoZSBhYm92
ZSB1c2FnZSBpbnN0cnVjdGlvbnMgY2FwdHVyZWQgaW4gdGhlIGtlcm5lbCBjb2RlIHNvbWV3aGVy
ZT8NCj4gSSBjYW4ndCBzZWUgaXQsIGFuZCBleHBlY3RpbmcgcGVvcGxlIHRvIHRyYXdsIGdpdCBj
aGFuZ2Vsb2dzIGlzbid0DQo+IHZlcnkgZnJpZW5kbHkuDQo+IA0KVGhhbmtzLiBJJ2xsIGFkZCB0
aGUgaW5zdHJ1Y3Rpb25zIHRvIHRoZSBmaWxlLiBGb3IgdGhlIHBlcmZvcm1hbmNlIHRlc3QsIGEN
CnNjcmlwdCBpcyBpbmNsdWRlZCB0aGF0IGRvZXMgZXZlcnl0aGluZyBuZWVkZWQuDQo=
