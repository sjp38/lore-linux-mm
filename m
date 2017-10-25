Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D8F486B0033
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 03:07:27 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id g6so16355288pgn.11
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 00:07:27 -0700 (PDT)
Received: from esa1.hgst.iphmx.com (esa1.hgst.iphmx.com. [68.232.141.245])
        by mx.google.com with ESMTPS id y1si1546584pfy.314.2017.10.25.00.07.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Oct 2017 00:07:26 -0700 (PDT)
From: Bart Van Assche <Bart.VanAssche@wdc.com>
Subject: Re: [RESEND PATCH 1/3] completion: Add support for initializing
 completion with lockdep_map
Date: Wed, 25 Oct 2017 07:07:06 +0000
Message-ID: <1508915222.2947.15.camel@wdc.com>
References: <1508319532-24655-1-git-send-email-byungchul.park@lge.com>
	 <1508319532-24655-2-git-send-email-byungchul.park@lge.com>
	 <1508455438.4542.4.camel@wdc.com>
	 <alpine.DEB.2.20.1710200829340.3083@nanos>
	 <1508529532.3029.15.camel@wdc.com>
	 <CANrsvRNnOp_rgEWG2FGg7qaEQi=yEyhiZkpWSW62w21BvJ9Shg@mail.gmail.com>
	 <1508682894.2564.8.camel@wdc.com> <20171023020822.GI3310@X58A-UD3R>
In-Reply-To: <20171023020822.GI3310@X58A-UD3R>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <53F10DDA73D0334D8FA30A344F17E505@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "byungchul.park@lge.com" <byungchul.park@lge.com>
Cc: "mingo@kernel.org" <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "hch@infradead.org" <hch@infradead.org>, "amir73il@gmail.com" <amir73il@gmail.com>, "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "oleg@redhat.com" <oleg@redhat.com>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "darrick.wong@oracle.com" <darrick.wong@oracle.com>, "johannes.berg@intel.com" <johannes.berg@intel.com>, "max.byungchul.park@gmail.com" <max.byungchul.park@gmail.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "idryomov@gmail.com" <idryomov@gmail.com>, "tj@kernel.org" <tj@kernel.org>, "kernel-team@lge.com" <kernel-team@lge.com>, "david@fromorbit.com" <david@fromorbit.com>

T24gTW9uLCAyMDE3LTEwLTIzIGF0IDExOjA4ICswOTAwLCBCeXVuZ2NodWwgUGFyayB3cm90ZToN
Cj4gT24gU3VuLCBPY3QgMjIsIDIwMTcgYXQgMDI6MzQ6NTZQTSArMDAwMCwgQmFydCBWYW4gQXNz
Y2hlIHdyb3RlOg0KPiA+IE9uIFNhdCwgMjAxNy0xMC0yMSBhdCAxMToyMyArMDkwMCwgQnl1bmdj
aHVsIFBhcmsgd3JvdGU6DQo+ID4gPiBPbiBTYXQsIE9jdCAyMSwgMjAxNyBhdCA0OjU4IEFNLCBC
YXJ0IFZhbiBBc3NjaGUgPEJhcnQuVmFuQXNzY2hlQHdkYy5jb20+IHdyb3RlOg0KPiA+ID4gPiBB
cyBleHBsYWluZWQgaW4gYW5vdGhlciBlLW1haWwgdGhyZWFkLCB1bmxpa2UgdGhlIGxvY2sgaW52
ZXJzaW9uIGNoZWNraW5nDQo+ID4gPiA+IHBlcmZvcm1lZCBieSB0aGUgPD0gdjQuMTMgbG9ja2Rl
cCBjb2RlLCBjcm9zcy1yZWxlYXNlIGNoZWNraW5nIGlzIGEgaGV1cmlzdGljDQo+ID4gPiA+IHRo
YXQgZG9lcyBub3QgaGF2ZSBhIHNvdW5kIHRoZW9yZXRpY2FsIGJhc2lzLiBUaGUgbG9jayB2YWxp
ZGF0b3IgaXMgYW4NCj4gPiA+IA0KPiA+ID4gSXQncyBub3QgaGV1cmlzdGljIGJ1dCBiYXNlZCBv
biB0aGUgc2FtZSB0aGVvcmV0aWNhbCBiYXNpcyBhcyA8PTQuMTMNCj4gPiA+IGxvY2tkZXAuIEkg
bWVhbiwgdGhlIGtleSBiYXNpcyBpczoNCj4gPiA+IA0KPiA+ID4gICAgMSkgV2hhdCBjYXVzZXMg
ZGVhZGxvY2sNCj4gPiA+ICAgIDIpIFdoYXQgaXMgYSBkZXBlbmRlbmN5DQo+ID4gPiAgICAzKSBC
dWlsZCBhIGRlcGVuZGVuY3kgd2hlbiBpZGVudGlmaWVkDQo+ID4gDQo+ID4gU29ycnkgYnV0IEkg
ZG91YnQgdGhhdCB0aGF0IHN0YXRlbWVudCBpcyBjb3JyZWN0LiBUaGUgcHVibGljYXRpb24gWzFd
IGNvbnRhaW5zDQo+IA0KPiBJTUhPLCB0aGUgcGFwZXIgaXMgdGFsa2luZyBhYm91dCB0b3RhbGx5
IGRpZmZlcmVudCB0aGluZ3Mgd3J0DQo+IGRlYWRsb2NrcyBieSB3YWl0X2Zvcl9ldmVudC9ldmVu
dCwgdGhhdCBpcywgbG9zdCBldmVudHMuDQoNClBsZWFzZSByZXJlYWQgdGhlIHBhcGVyIHRpdGxl
LiBUaGUgYXV0aG9ycyBvZiB0aGUgcGFwZXIgZXhwbGFpbiB0aGF0IHRoZWlyIGFsZ29yaXRobQ0K
Y2FuIGRldGVjdCBsb3N0IGV2ZW50cyBidXQgdGhlIG1vc3Qgc2lnbmlmaWNhbnQgY29udHJpYnV0
aW9uIG9mIHRoZSBwYXBlciBpcyBkZWFkbG9jaw0KZGV0ZWN0aW9uLg0KDQo+ID4gZmFsc2UgcG9z
aXRpdmVzIGZvciBwcm9ncmFtcyB0aGF0IG9ubHkgdXNlIG11dGV4ZXMgYXMgc3luY2hyb25pemF0
aW9uIG9iamVjdHMuDQo+IA0KPiBJIHdhbnQgdG8gYXNrIHlvdS4gV2hhdCBtYWtlcyBmYWxzZSBw
b3NpdGl2ZXMgYXZvaWRhYmxlIGluIHRoZSBwYXBlcj8NCg0KVGhlIGFsZ29yaXRobSB1c2VkIHRv
IGRldGVjdCBkZWFkbG9ja3MuIFRoYXQgYWxnb3JpdGhtIGhhcyBiZWVuIGV4cGxhaW5lZCBjbGVh
cmx5DQppbiB0aGUgcGFwZXIuDQoNCj4gPiBUaGUgY29tbWVudCBvZiB0aGUgYXV0aG9ycyBvZiB0
aGF0IHBhcGVyIGZvciBwcm9ncmFtcyB0aGF0IHVzZSBtdXRleGVzLA0KPiA+IGNvbmRpdGlvbiB2
YXJpYWJsZXMgYW5kIHNlbWFwaG9yZXMgaXMgYXMgZm9sbG93czogIkl0IGlzIHVuY2xlYXIgaG93
IHRvIGV4dGVuZA0KPiA+IHRoZSBsb2NrLWdyYXBoLWJhc2VkIGFsZ29yaXRobSBpbiBTZWN0aW9u
IDMgdG8gZWZmaWNpZW50bHkgY29uc2lkZXIgdGhlIGVmZmVjdHMNCj4gPiBvZiBjb25kaXRpb24g
dmFyaWFibGVzIGFuZCBzZW1hcGhvcmVzLiBUaGVyZWZvcmUsIHdoZW4gY29uc2lkZXJpbmcgYWxs
IHRocmVlDQo+ID4gc3luY2hyb25pemF0aW9uIG1lY2hhbmlzbXMsIHdlIGN1cnJlbnRseSB1c2Ug
YSBuYWl2ZSBhbGdvcml0aG0gdGhhdCBjaGVja3MgZWFjaA0KPiA+IGZlYXNpYmxlIHBlcm11dGF0
aW9uIG9mIHRoZSB0cmFjZSBmb3IgZGVhZGxvY2suIiBJbiBvdGhlciB3b3JkcywgaWYgeW91IGhh
dmUNCj4gPiBmb3VuZCBhbiBhcHByb2FjaCBmb3IgZGV0ZWN0aW5nIHBvdGVudGlhbCBkZWFkbG9j
a3MgZm9yIHByb2dyYW1zIHRoYXQgdXNlIHRoZXNlDQo+ID4gdGhyZWUga2luZHMgb2Ygc3luY2hy
b25pemF0aW9uIG9iamVjdHMgYW5kIHRoYXQgZG9lcyBub3QgcmVwb3J0IGZhbHNlIHBvc2l0aXZl
cw0KPiA+IHRoZW4gdGhhdCdzIGEgYnJlYWt0aHJvdWdoIHRoYXQncyB3b3J0aCBwdWJsaXNoaW5n
IGluIGEgam91cm5hbCBvciBpbiB0aGUNCj4gPiBwcm9jZWVkaW5ncyBvZiBhIHNjaWVudGlmaWMg
Y29uZmVyZW5jZS4NCj4gDQo+IFBsZWFzZSwgcG9pbnQgb3V0IGxvZ2ljYWwgcHJvYmxlbXMgb2Yg
Y3Jvc3MtcmVsZWFzZSB0aGFuIHNheWluZyBpdCdzDQo+IGltcG9zc2JpbGUgYWNjb3JkaW5nIHRv
IHRoZSBwYXBlci4NCg0KSXNuJ3QgdGhhdCB0aGUgc2FtZT8gSWYgaXQncyBpbXBvc3NpYmxlIHRv
IHVzZSBsb2NrLWdyYXBocyBmb3IgZGV0ZWN0aW5nIGRlYWRsb2Nrcw0KaW4gcHJvZ3JhbXMgdGhh
dCB1c2UgbXV0ZXhlcywgc2VtYXBob3JlcyBhbmQgY29uZGl0aW9uIHZhcmlhYmxlcyB3aXRob3V0
IHRyaWdnZXJpbmcNCmZhbHNlIHBvc2l0aXZlcyB0aGF0IG1lYW5zIHRoYXQgZXZlcnkgYXBwcm9h
Y2ggdGhhdCB0cmllcyB0byBkZXRlY3QgZGVhZGxvY2tzIGFuZA0KdGhhdCBpcyBiYXNlZCBvbiBs
b2NrIGdyYXBocywgaW5jbHVkaW5nIGNyb3NzLXJlbGVhc2UsIG11c3QgcmVwb3J0IGZhbHNlIHBv
c2l0aXZlcw0KZm9yIGNlcnRhaW4gcHJvZ3JhbXMuDQoNCkJhcnQuDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
