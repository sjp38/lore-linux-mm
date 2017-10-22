Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id DEF906B0253
	for <linux-mm@kvack.org>; Sun, 22 Oct 2017 10:35:05 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t10so9771697pgo.20
        for <linux-mm@kvack.org>; Sun, 22 Oct 2017 07:35:05 -0700 (PDT)
Received: from esa5.hgst.iphmx.com (esa5.hgst.iphmx.com. [216.71.153.144])
        by mx.google.com with ESMTPS id f19si2947057plr.246.2017.10.22.07.35.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Oct 2017 07:35:04 -0700 (PDT)
From: Bart Van Assche <Bart.VanAssche@wdc.com>
Subject: Re: [RESEND PATCH 1/3] completion: Add support for initializing
 completion with lockdep_map
Date: Sun, 22 Oct 2017 14:34:56 +0000
Message-ID: <1508682894.2564.8.camel@wdc.com>
References: <1508319532-24655-1-git-send-email-byungchul.park@lge.com>
	 <1508319532-24655-2-git-send-email-byungchul.park@lge.com>
	 <1508455438.4542.4.camel@wdc.com>
	 <alpine.DEB.2.20.1710200829340.3083@nanos>
	 <1508529532.3029.15.camel@wdc.com>
	 <CANrsvRNnOp_rgEWG2FGg7qaEQi=yEyhiZkpWSW62w21BvJ9Shg@mail.gmail.com>
In-Reply-To: <CANrsvRNnOp_rgEWG2FGg7qaEQi=yEyhiZkpWSW62w21BvJ9Shg@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <B5349D68919D6A4D8481F45A211BEDF9@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "max.byungchul.park@gmail.com" <max.byungchul.park@gmail.com>
Cc: "mingo@kernel.org" <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "hch@infradead.org" <hch@infradead.org>, "amir73il@gmail.com" <amir73il@gmail.com>, "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "oleg@redhat.com" <oleg@redhat.com>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "darrick.wong@oracle.com" <darrick.wong@oracle.com>, "johannes.berg@intel.com" <johannes.berg@intel.com>, "byungchul.park@lge.com" <byungchul.park@lge.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "idryomov@gmail.com" <idryomov@gmail.com>, "tj@kernel.org" <tj@kernel.org>, "kernel-team@lge.com" <kernel-team@lge.com>, "david@fromorbit.com" <david@fromorbit.com>

T24gU2F0LCAyMDE3LTEwLTIxIGF0IDExOjIzICswOTAwLCBCeXVuZ2NodWwgUGFyayB3cm90ZToN
Cj4gT24gU2F0LCBPY3QgMjEsIDIwMTcgYXQgNDo1OCBBTSwgQmFydCBWYW4gQXNzY2hlIDxCYXJ0
LlZhbkFzc2NoZUB3ZGMuY29tPiB3cm90ZToNCj4gPiBBcyBleHBsYWluZWQgaW4gYW5vdGhlciBl
LW1haWwgdGhyZWFkLCB1bmxpa2UgdGhlIGxvY2sgaW52ZXJzaW9uIGNoZWNraW5nDQo+ID4gcGVy
Zm9ybWVkIGJ5IHRoZSA8PSB2NC4xMyBsb2NrZGVwIGNvZGUsIGNyb3NzLXJlbGVhc2UgY2hlY2tp
bmcgaXMgYSBoZXVyaXN0aWMNCj4gPiB0aGF0IGRvZXMgbm90IGhhdmUgYSBzb3VuZCB0aGVvcmV0
aWNhbCBiYXNpcy4gVGhlIGxvY2sgdmFsaWRhdG9yIGlzIGFuDQo+IA0KPiBJdCdzIG5vdCBoZXVy
aXN0aWMgYnV0IGJhc2VkIG9uIHRoZSBzYW1lIHRoZW9yZXRpY2FsIGJhc2lzIGFzIDw9NC4xMw0K
PiBsb2NrZGVwLiBJIG1lYW4sIHRoZSBrZXkgYmFzaXMgaXM6DQo+IA0KPiAgICAxKSBXaGF0IGNh
dXNlcyBkZWFkbG9jaw0KPiAgICAyKSBXaGF0IGlzIGEgZGVwZW5kZW5jeQ0KPiAgICAzKSBCdWls
ZCBhIGRlcGVuZGVuY3kgd2hlbiBpZGVudGlmaWVkDQoNClNvcnJ5IGJ1dCBJIGRvdWJ0IHRoYXQg
dGhhdCBzdGF0ZW1lbnQgaXMgY29ycmVjdC4gVGhlIHB1YmxpY2F0aW9uIFsxXSBjb250YWlucw0K
YSBwcm9vZiB0aGF0IGFuIGFsZ29yaXRobSB0aGF0IGlzIGNsb3NlbHkgcmVsYXRlZCB0byB0aGUg
dHJhZGl0aW9uYWwgbG9ja2RlcA0KbG9jayBpbnZlcnNpb24gZGV0ZWN0b3IgaXMgYWJsZSB0byBk
ZXRlY3QgYWxsIGRlYWRsb2NrcyBhbmQgZG9lcyBub3QgcmVwb3J0DQpmYWxzZSBwb3NpdGl2ZXMg
Zm9yIHByb2dyYW1zIHRoYXQgb25seSB1c2UgbXV0ZXhlcyBhcyBzeW5jaHJvbml6YXRpb24gb2Jq
ZWN0cy4NClRoZSBjb21tZW50IG9mIHRoZSBhdXRob3JzIG9mIHRoYXQgcGFwZXIgZm9yIHByb2dy
YW1zIHRoYXQgdXNlIG11dGV4ZXMsDQpjb25kaXRpb24gdmFyaWFibGVzIGFuZCBzZW1hcGhvcmVz
IGlzIGFzIGZvbGxvd3M6ICJJdCBpcyB1bmNsZWFyIGhvdyB0byBleHRlbmQNCnRoZSBsb2NrLWdy
YXBoLWJhc2VkIGFsZ29yaXRobSBpbiBTZWN0aW9uIDMgdG8gZWZmaWNpZW50bHkgY29uc2lkZXIg
dGhlIGVmZmVjdHMNCm9mIGNvbmRpdGlvbiB2YXJpYWJsZXMgYW5kIHNlbWFwaG9yZXMuIFRoZXJl
Zm9yZSwgd2hlbiBjb25zaWRlcmluZyBhbGwgdGhyZWUNCnN5bmNocm9uaXphdGlvbiBtZWNoYW5p
c21zLCB3ZSBjdXJyZW50bHkgdXNlIGEgbmFpdmUgYWxnb3JpdGhtIHRoYXQgY2hlY2tzIGVhY2gN
CmZlYXNpYmxlIHBlcm11dGF0aW9uIG9mIHRoZSB0cmFjZSBmb3IgZGVhZGxvY2suIiBJbiBvdGhl
ciB3b3JkcywgaWYgeW91IGhhdmUNCmZvdW5kIGFuIGFwcHJvYWNoIGZvciBkZXRlY3RpbmcgcG90
ZW50aWFsIGRlYWRsb2NrcyBmb3IgcHJvZ3JhbXMgdGhhdCB1c2UgdGhlc2UNCnRocmVlIGtpbmRz
IG9mIHN5bmNocm9uaXphdGlvbiBvYmplY3RzIGFuZCB0aGF0IGRvZXMgbm90IHJlcG9ydCBmYWxz
ZSBwb3NpdGl2ZXMNCnRoZW4gdGhhdCdzIGEgYnJlYWt0aHJvdWdoIHRoYXQncyB3b3J0aCBwdWJs
aXNoaW5nIGluIGEgam91cm5hbCBvciBpbiB0aGUNCnByb2NlZWRpbmdzIG9mIGEgc2NpZW50aWZp
YyBjb25mZXJlbmNlLg0KDQpCYXJ0Lg0KDQpbMV0gQWdhcndhbCwgUmFodWwsIGFuZCBTY290dCBE
LiBTdG9sbGVyLiAiUnVuLXRpbWUgZGV0ZWN0aW9uIG9mIHBvdGVudGlhbA0KZGVhZGxvY2tzIGZv
ciBwcm9ncmFtcyB3aXRoIGxvY2tzLCBzZW1hcGhvcmVzLCBhbmQgY29uZGl0aW9uIHZhcmlhYmxl
cy4iIEluDQpQcm9jZWVkaW5ncyBvZiB0aGUgMjAwNiB3b3Jrc2hvcCBvbiBQYXJhbGxlbCBhbmQg
ZGlzdHJpYnV0ZWQgc3lzdGVtczogdGVzdGluZw0KYW5kIGRlYnVnZ2luZywgcHAuIDUxLTYwLiBB
Q00sIDIwMDYuDQooaHR0cHM6Ly9wZGZzLnNlbWFudGljc2Nob2xhci5vcmcvOTMyNC9mYzBiNWQ1
Y2Q1ZTA1ZDU1MWEzZTk4NzU3MTIyMDM5OTQ2YTIucGRmKS4=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
