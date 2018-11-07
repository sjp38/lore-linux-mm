Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7A2A36B0548
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 15:03:43 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id i19-v6so14153026pfi.21
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 12:03:43 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id f7-v6si1619450plb.362.2018.11.07.12.03.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 12:03:42 -0800 (PST)
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Subject: Re: [PATCH v8 0/4] KASLR feature to randomize each loadable module
Date: Wed, 7 Nov 2018 20:03:40 +0000
Message-ID: <84597c620c39ed17be11de759646f3ace3e236fa.camel@intel.com>
References: <20181102192520.4522-1-rick.p.edgecombe@intel.com>
	 <20181106130459.7a2669604a2c274edbe25971@linux-foundation.org>
In-Reply-To: <20181106130459.7a2669604a2c274edbe25971@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <7EA5D5F7B5010143BB315E15C2C67207@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "daniel@iogearbox.net" <daniel@iogearbox.net>, "jeyu@kernel.org" <jeyu@kernel.org>, "keescook@chromium.org" <keescook@chromium.org>, "jannh@google.com" <jannh@google.com>, "willy@infradead.org" <willy@infradead.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "arjan@linux.intel.com" <arjan@linux.intel.com>, "x86@kernel.org" <x86@kernel.org>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "Hansen, Dave" <dave.hansen@intel.com>

T24gVHVlLCAyMDE4LTExLTA2IGF0IDEzOjA0IC0wODAwLCBBbmRyZXcgTW9ydG9uIHdyb3RlOg0K
PiBPbiBGcmksICAyIE5vdiAyMDE4IDEyOjI1OjE2IC0wNzAwIFJpY2sgRWRnZWNvbWJlIDxyaWNr
LnAuZWRnZWNvbWJlQGludGVsLmNvbT4NCj4gd3JvdGU6DQo+IA0KPiA+IFRoaXMgaXMgVjggb2Yg
dGhlICJLQVNMUiBmZWF0dXJlIHRvIHJhbmRvbWl6ZSBlYWNoIGxvYWRhYmxlIG1vZHVsZSINCj4g
PiBwYXRjaHNldC4NCj4gPiBUaGUgcHVycG9zZSBpcyB0byBpbmNyZWFzZSB0aGUgcmFuZG9taXph
dGlvbiBhbmQgYWxzbyB0byBtYWtlIHRoZSBtb2R1bGVzDQo+ID4gcmFuZG9taXplZCBpbiByZWxh
dGlvbiB0byBlYWNoIG90aGVyIGluc3RlYWQgb2YganVzdCB0aGUgYmFzZSwgc28gdGhhdCBpZg0K
PiA+IG9uZQ0KPiA+IG1vZHVsZSBsZWFrcyB0aGUgbG9jYXRpb24gb2YgdGhlIG90aGVycyBjYW4n
dCBiZSBpbmZlcnJlZC4NCj4gDQo+IEknbSBub3Qgc2VlaW5nIGFueSBpbmZvIGhlcmUgd2hpY2gg
ZXhwbGFpbnMgd2h5IHdlIHNob3VsZCBhZGQgdGhpcyB0bw0KPiBMaW51eC4NCj4gDQo+IFdoYXQg
aXMgdGhlIGVuZC11c2VyIHZhbHVlPyAgV2hhdCBwcm9ibGVtcyBkb2VzIGl0IHNvbHZlPyAgQXJl
IHRob3NlDQo+IHByb2JsZW1zIHJlYWwgb3IgdGhlb3JldGljYWw/ICBXaGF0IGFyZSB0aGUgZXhw
bG9pdCBzY2VuYXJpb3MgYW5kIGhvdw0KPiByZWFsaXN0aWMgYXJlIHRoZXk/ICBldGNldGVyYSwg
ZXRjZXRlcmEuICBIb3cgYXJlIHdlIHRvIGRlY2lkZSB0byBidXkNCj4gdGhpcyB0aGluZyBpZiB3
ZSBhcmVuJ3QgZ2l2ZW4gYSBnbG9zc3kgYnJvY2h1cmU/DQpIaSBBbmRyZXcsDQoNClRoYW5rcyBm
b3IgdGFraW5nIGEgbG9vayEgVGhlIGZpcnN0IHZlcnNpb24gaGFkIGEgcHJvcGVyIHdyaXRlIHVw
LCBidXQgbm93IHRoZQ0KZGV0YWlscyBhcmUgc3ByZWFkIG91dCBvdmVyIDggdmVyc2lvbnMuIEkn
bGwgc2VuZCBvdXQgYW5vdGhlciB2ZXJzaW9uIHdpdGggaXQNCmFsbCBpbiBvbmUgcGxhY2UuDQoN
ClRoZSBzaG9ydCB2ZXJzaW9uIGlzIHRoYXQgdG9kYXkgdGhlIFJBTkRPTUlaRV9CQVNFIGZlYXR1
cmUgcmFuZG9taXplcyB0aGUgYmFzZQ0KYWRkcmVzcyB3aGVyZSB0aGUgbW9kdWxlIGFsbG9jYXRp
b25zIGJlZ2luIHdpdGggMTAgYml0cyBvZiBlbnRyb3B5LiBGcm9tIGhlcmUsDQphIGhpZ2hseSBk
ZXRlcm1pbmlzdGljIGFsZ29yaXRobSBhbGxvY2F0ZXMgc3BhY2UgZm9yIHRoZSBtb2R1bGVzIGFz
IHRoZXkgYXJlIA0KbG9hZGVkIGFuZCB1bi1sb2FkZWQuIElmIGFuIGF0dGFja2VyIGNhbiBwcmVk
aWN0IHRoZSBvcmRlciBhbmQgaWRlbnRpdGllcyBmb3INCm1vZHVsZXMgdGhhdCB3aWxsIGJlIGxv
YWRlZCwgdGhlbiBhIHNpbmdsZSB0ZXh0IGFkZHJlc3MgbGVhayBjYW4gZ2l2ZSB0aGUNCmF0dGFj
a2VyIGFjY2VzcyB0byB0aGUgbG9jYXRpb25zIG9mIGFsbCB0aGUgbW9kdWxlcy4gDQoNClNvIHRo
aXMgaXMgdHJ5aW5nIHRvIHByZXZlbnQgdGhlIHNhbWUgY2xhc3Mgb2YgYXR0YWNrcyBhcyB0aGUg
ZXhpc3RpbmcgS0FTTFIsDQpsaWtlIGNvbnRyb2wgZmxvdyBtYW5pcHVsYXRpb24gYW5kIG5vdyBh
bHNvIG1ha2luZyBpdCBoYXJkZXIvbG9uZ2VyIHRvIGZpbmQNCnNwZWN1bGF0aXZlIGV4ZWN1dGlv
biBnYWRnZXRzLiBJdCBpbmNyZWFzZXMgdGhlIG51bWJlciBvZiBwb3NzaWJsZQ0KcG9zaXRpb25z
IDEyOFgsIGFuZCB3aXRoIHRoYXQgYW1vdW50IG9mIHJhbmRvbW5lc3MgcGVyIG1vZHVsZSBpbnN0
ZWFkIG9mIGZvciBhbGwNCm1vZHVsZXMuDQoNCj4gPiBUaGVyZSBpcyBhIHNtYWxsIGFsbG9jYXRp
b24gcGVyZm9ybWFuY2UgZGVncmFkYXRpb24gdmVyc3VzIHY3IGFzIGENCj4gPiB0cmFkZSBvZmYs
IGJ1dCBpdCBpcyBzdGlsbCBmYXN0ZXIgb24gYXZlcmFnZSB0aGFuIHRoZSBleGlzdGluZw0KPiA+
IGFsZ29yaXRobSB1bnRpbCA+NzAwMCBtb2R1bGVzLg0KPiANCj4gbG9sLiAgSG93IGRpZCB5b3Ug
dGVzdCA3MDAwIG1vZHVsZXM/ICBVc2luZyB0aGUgc2VsZnRlc3QgY29kZT8NCg0KWWVzLCB0aGlz
IGlzIHdpdGggc2ltdWxhdGlvbnMgdXNpbmcgdGhlIGluY2x1ZGVkIGtzZWxmdGVzdCBjb2RlIHdp
dGggc2l6ZXMNCmV4dHJhY3RlZCBmcm9tIHRoZSB4ODZfNjQgaW4tdHJlZSBtb2R1bGVzLiBTdXBw
b3J0aW5nIDcwMDAga2VybmVsIG1vZHVsZXMgaXMgbm90DQp0aGUgaW50ZW50aW9uIHRob3VnaCwg
aW5zdGVhZCBpdCdzIHRyeWluZyB0byBhY2NvbW1vZGF0ZSA3MDAwIGFsbG9jYXRpb25zIGluIHRo
ZQ0KbW9kdWxlIHNwYWNlLiBTbyBhbHNvIGVCUEYgSklULCBjbGFzc2ljIEJQRiBzb2NrZXQgZmls
dGVyIEpJVCwga3Byb2JlcywgZXRjLg0KDQo=
