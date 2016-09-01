Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4B2026B0038
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 01:46:45 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 93so159039678qtg.1
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 22:46:45 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id j6si3778888pad.199.2016.08.31.22.46.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 22:46:44 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [PATCH v3 kernel 0/7] Extend virtio-balloon for fast
 (de)inflating & fast live migration
Date: Thu, 1 Sep 2016 05:46:40 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E3A01C59B@shsmsx102.ccr.corp.intel.com>
References: <1470638134-24149-1-git-send-email-liang.z.li@intel.com>
 <CANRm+Cy=p8PKg8HqRp7apU0D9X=gpnrahtXRq+S+5Gq863VO8g@mail.gmail.com>
In-Reply-To: <CANRm+Cy=p8PKg8HqRp7apU0D9X=gpnrahtXRq+S+5Gq863VO8g@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <kernellwp@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, kvm <kvm@vger.kernel.org>, "qemu-devel@nongnu.org Developers" <qemu-devel@nongnu.org>, "quintela@redhat.com" <quintela@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>

PiBTdWJqZWN0OiBSZTogW1BBVENIIHYzIGtlcm5lbCAwLzddIEV4dGVuZCB2aXJ0aW8tYmFsbG9v
biBmb3IgZmFzdCAoZGUpaW5mbGF0aW5nDQo+ICYgZmFzdCBsaXZlIG1pZ3JhdGlvbg0KPiANCj4g
MjAxNi0wOC0wOCAxNDozNSBHTVQrMDg6MDAgTGlhbmcgTGkgPGxpYW5nLnoubGlAaW50ZWwuY29t
PjoNCj4gPiBUaGlzIHBhdGNoIHNldCBjb250YWlucyB0d28gcGFydHMgb2YgY2hhbmdlcyB0byB0
aGUgdmlydGlvLWJhbGxvb24uDQo+ID4NCj4gPiBPbmUgaXMgdGhlIGNoYW5nZSBmb3Igc3BlZWRp
bmcgdXAgdGhlIGluZmxhdGluZyAmIGRlZmxhdGluZyBwcm9jZXNzLA0KPiA+IHRoZSBtYWluIGlk
ZWEgb2YgdGhpcyBvcHRpbWl6YXRpb24gaXMgdG8gdXNlIGJpdG1hcCB0byBzZW5kIHRoZSBwYWdl
DQo+ID4gaW5mb3JtYXRpb24gdG8gaG9zdCBpbnN0ZWFkIG9mIHRoZSBQRk5zLCB0byByZWR1Y2Ug
dGhlIG92ZXJoZWFkIG9mDQo+ID4gdmlydGlvIGRhdGEgdHJhbnNtaXNzaW9uLCBhZGRyZXNzIHRy
YW5zbGF0aW9uIGFuZCBtYWR2aXNlKCkuIFRoaXMgY2FuDQo+ID4gaGVscCB0byBpbXByb3ZlIHRo
ZSBwZXJmb3JtYW5jZSBieSBhYm91dCA4NSUuDQo+ID4NCj4gPiBBbm90aGVyIGNoYW5nZSBpcyBm
b3Igc3BlZWRpbmcgdXAgbGl2ZSBtaWdyYXRpb24uIEJ5IHNraXBwaW5nIHByb2Nlc3MNCj4gPiBn
dWVzdCdzIGZyZWUgcGFnZXMgaW4gdGhlIGZpcnN0IHJvdW5kIG9mIGRhdGEgY29weSwgdG8gcmVk
dWNlIG5lZWRsZXNzDQo+ID4gZGF0YSBwcm9jZXNzaW5nLCB0aGlzIGNhbiBoZWxwIHRvIHNhdmUg
cXVpdGUgYSBsb3Qgb2YgQ1BVIGN5Y2xlcyBhbmQNCj4gPiBuZXR3b3JrIGJhbmR3aWR0aC4gV2Ug
cHV0IGd1ZXN0J3MgZnJlZSBwYWdlIGluZm9ybWF0aW9uIGluIGJpdG1hcCBhbmQNCj4gPiBzZW5k
IGl0IHRvIGhvc3Qgd2l0aCB0aGUgdmlydCBxdWV1ZSBvZiB2aXJ0aW8tYmFsbG9vbi4gRm9yIGFu
IGlkbGUgOEdCDQo+ID4gZ3Vlc3QsIHRoaXMgY2FuIGhlbHAgdG8gc2hvcnRlbiB0aGUgdG90YWwg
bGl2ZSBtaWdyYXRpb24gdGltZSBmcm9tDQo+ID4gMlNlYyB0byBhYm91dCA1MDBtcyBpbiB0aGUg
MTBHYnBzIG5ldHdvcmsgZW52aXJvbm1lbnQuDQo+IA0KPiBJIGp1c3QgcmVhZCB0aGUgc2xpZGVz
IG9mIHRoaXMgZmVhdHVyZSBmb3IgcmVjZW50IGt2bSBmb3J1bSwgdGhlIGNsb3VkDQo+IHByb3Zp
ZGVycyBtb3JlIGNhcmUgYWJvdXQgbGl2ZSBtaWdyYXRpb24gZG93bnRpbWUgdG8gYXZvaWQgY3Vz
dG9tZXJzJw0KPiBwZXJjZXB0aW9uIHRoYW4gdG90YWwgdGltZSwgaG93ZXZlciwgdGhpcyBmZWF0
dXJlIHdpbGwgaW5jcmVhc2UgZG93bnRpbWUNCj4gd2hlbiBhY3F1aXJlIHRoZSBiZW5lZml0IG9m
IHJlZHVjaW5nIHRvdGFsIHRpbWUsIG1heWJlIGl0IHdpbGwgYmUgbW9yZQ0KPiBhY2NlcHRhYmxl
IGlmIHRoZXJlIGlzIG5vIGRvd25zaWRlIGZvciBkb3dudGltZS4NCj4gDQo+IFJlZ2FyZHMsDQo+
IFdhbnBlbmcgTGkNCg0KSW4gdGhlb3J5LCB0aGVyZSBpcyBubyBmYWN0b3IgdGhhdCB3aWxsIGlu
Y3JlYXNlIHRoZSBkb3dudGltZS4gVGhlcmUgaXMgbm8gYWRkaXRpb25hbCBvcGVyYXRpb24NCmFu
ZCBubyBtb3JlIGRhdGEgY29weSBkdXJpbmcgdGhlIHN0b3AgYW5kIGNvcHkgc3RhZ2UuIEJ1dCBp
biB0aGUgdGVzdCwgdGhlIGRvd250aW1lIGluY3JlYXNlcw0KYW5kIHRoaXMgY2FuIGJlIHJlcHJv
ZHVjZWQuIEkgdGhpbmsgdGhlIGJ1c3kgbmV0d29yayBsaW5lIG1heWJlIHRoZSByZWFzb24gZm9y
IHRoaXMuIFdpdGggdGhpcw0KIG9wdGltaXphdGlvbiwgYSBodWdlIGFtb3VudCBvZiBkYXRhIGlz
IHdyaXR0ZW4gdG8gdGhlIHNvY2tldCBpbiBhIHNob3J0ZXIgdGltZSwgc28gc29tZSBvZiB0aGUg
d3JpdGUNCm9wZXJhdGlvbiBtYXkgbmVlZCB0byB3YWl0LiBXaXRob3V0IHRoaXMgb3B0aW1pemF0
aW9uLCB6ZXJvIHBhZ2UgY2hlY2tpbmcgdGFrZXMgbW9yZSB0aW1lLA0KdGhlIG5ldHdvcmsgaXMg
bm90IHNvIGJ1c3kuDQoNCklmIHRoZSBndWVzdCBpcyBub3QgYW4gaWRsZSBvbmUsIEkgdGhpbmsg
dGhlIGdhcCBvZiB0aGUgZG93bnRpbWUgd2lsbCBub3Qgc28gb2J2aW91cy4gIEFueXdheSwgdGhl
DQpkb3dudGltZSBpcyBzdGlsbCBsZXNzIHRoYW4gdGhlICBtYXhfZG93bl90aW1lIHNldCBieSB0
aGUgdXNlci4NCg0KVGhhbmtzIQ0KTGlhbmcNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
