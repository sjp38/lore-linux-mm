Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 777556B0038
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 18:09:03 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id r203so19920067oif.2
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 15:09:03 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0135.outbound.protection.outlook.com. [104.47.33.135])
        by mx.google.com with ESMTPS id 29si1612445qtr.34.2016.08.31.15.09.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 31 Aug 2016 15:09:02 -0700 (PDT)
From: "Kani, Toshimitsu" <toshi.kani@hpe.com>
Subject: Re: [PATCH v2 0/9] re-enable DAX PMD support
Date: Wed, 31 Aug 2016 22:08:59 +0000
Message-ID: <1472681284.2092.30.camel@hpe.com>
References: <20160823220419.11717-1-ross.zwisler@linux.intel.com>
	 <20160830230150.GA12173@linux.intel.com> <1472674799.2092.19.camel@hpe.com>
	 <20160831213607.GA6921@linux.intel.com>
In-Reply-To: <20160831213607.GA6921@linux.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <9CF8BC9D254DF144AF101EE6F7D0B3D0@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "adilger.kernel@dilger.ca" <adilger.kernel@dilger.ca>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "jack@suse.com" <jack@suse.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "david@fromorbit.com" <david@fromorbit.com>

T24gV2VkLCAyMDE2LTA4LTMxIGF0IDE1OjM2IC0wNjAwLCBSb3NzIFp3aXNsZXIgd3JvdGU6DQo+
IE9uIFdlZCwgQXVnIDMxLCAyMDE2IGF0IDA4OjIwOjQ4UE0gKzAwMDAsIEthbmksIFRvc2hpbWl0
c3Ugd3JvdGU6DQo+ID4gDQo+ID4gT24gVHVlLCAyMDE2LTA4LTMwIGF0IDE3OjAxIC0wNjAwLCBS
b3NzIFp3aXNsZXIgd3JvdGU6DQo+ID4gPiANCj4gPiA+IE9uIFR1ZSwgQXVnIDIzLCAyMDE2IGF0
IDA0OjA0OjEwUE0gLTA2MDAsIFJvc3MgWndpc2xlciB3cm90ZToNCsKgOg0KPiA+ID4gDQo+ID4g
PiBQaW5nIG9uIHRoaXMgc2VyaWVzP8KgwqBBbnkgb2JqZWN0aW9ucyBvciBjb21tZW50cz8NCj4g
PiANCj4gPiBIaSBSb3NzLA0KPiA+IA0KPiA+IEkgYW0gc2VlaW5nIGEgbWFqb3IgcGVyZm9ybWFu
Y2UgbG9zcyBpbiBmaW8gbW1hcCB0ZXN0IHdpdGggdGhpcw0KPiA+IHBhdGNoLXNldCBhcHBsaWVk
LiDCoFRoaXMgaGFwcGVucyB3aXRoIG9yIHdpdGhvdXQgbXkgcGF0Y2hlcyBbMV0NCj4gPiBhcHBs
aWVkIG9uIHRvcCBvZiB5b3Vycy4gwqBXaXRob3V0IG15IHBhdGNoZXMswqBkYXhfcG1kX2ZhdWx0
KCkgZmFsbHMNCj4gPiBiYWNrIHRvIHRoZSBwdGUgaGFuZGxlciBzaW5jZSBhbiBtbWFwJ2VkIGFk
ZHJlc3MgaXMgbm90IDJNQi0NCj4gPiBhbGlnbmVkLg0KPiA+IA0KPiA+IEkgaGF2ZSBhdHRhY2hl
ZCB0aHJlZSB0ZXN0IHJlc3VsdHMuDQo+ID4gwqBvIHJjNC5sb2cgLSA0LjguMC1yYzQgKGJhc2Up
DQo+ID4gwqBvIG5vbi1wbWQubG9nIC0gNC44LjAtcmM0ICsgeW91ciBwYXRjaHNldCAoZmFsbCBi
YWNrIHRvIHB0ZSkNCj4gPiDCoG8gcG1kLmxvZyAtIDQuOC4wLXJjNCArIHlvdXIgcGF0Y2hzZXQg
KyBteSBwYXRjaHNldCAodXNlIHBtZCBtYXBzKQ0KPiA+IA0KPiA+IE15IHRlc3Qgc3RlcHMgYXJl
IGFzIGZvbGxvd3MuDQo+ID4gDQo+ID4gbWtmcy5leHQ0IC1PIGJpZ2FsbG9jIC1DIDJNIC9kZXYv
cG1lbTANCj4gPiBtb3VudCAtbyBkYXggL2Rldi9wbWVtMCAvbW50L3BtZW0wDQo+ID4gbnVtYWN0
bCAtLXByZWZlcnJlZCBibG9jazpwbWVtMCAtLWNwdW5vZGViaW5kIGJsb2NrOnBtZW0wIGZpbw0K
PiA+IHRlc3QuZmlvDQo+ID4gDQo+ID4gInRlc3QuZmlvIg0KPiA+IC0tLQ0KPiA+IFtnbG9iYWxd
DQo+ID4gYnM9NGsNCj4gPiBzaXplPTJHDQo+ID4gZGlyZWN0b3J5PS9tbnQvcG1lbTANCj4gPiBp
b2VuZ2luZT1tbWFwDQo+ID4gW3JhbmRyd10NCj4gPiBydz1yYW5kcncNCj4gPiAtLS0NCj4gPiAN
Cj4gPiBDYW4geW91IHBsZWFzZSB0YWtlIGEgbG9vaz8NCj4gDQo+IFllcCwgdGhhbmtzIGZvciB0
aGUgcmVwb3J0Lg0KDQpJIGhhdmUgc29tZSBtb3JlIG9ic2VydmF0aW9ucy4gwqBJdCBzZWVtcyB0
aGlzIGlzc3VlIGlzIHJlbGF0ZWQgd2l0aCBwbWQNCm1hcHBpbmdzIGFmdGVyIGFsbC4gwqBmaW8g
Y3JlYXRlcyAicmFuZHJ3LjAuMCIgZmlsZS4gwqBJbiBteSBzZXR1cCwgYW4NCmluaXRpYWwgdGVz
dCBydW4gY3JlYXRlcyBwbWQgbWFwcGluZ3MgYW5kIGhpdHMgdGhpcyBpc3N1ZS4gwqBTdWJzZXF1
ZW50DQp0ZXN0IHJ1bnMgKGkuZS4gcmFuZHJ3LjAuMCBleGlzdHMpLCB3aXRob3V0IG15IHBhdGNo
ZXMsIGZhbGwgYmFjayB0bw0KcHRlIG1hcHBpbmdzIGFuZCBkbyBub3QgaGl0IHRoaXMgaXNzdWUu
IMKgV2l0aCBteSBwYXRjaGVzIGFwcGxpZWQsDQpzdWJzZXF1ZW50IHJ1bnMgc3RpbGwgY3JlYXRl
IHBtZCBtYXBwaW5ncyBhbmQgaGl0IHRoaXMgaXNzdWUuDQoNClRoYW5rcywNCi1Ub3NoaSDCoA0K
DQoNCg0KDQoNCg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
