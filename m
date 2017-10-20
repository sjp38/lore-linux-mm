Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BAD466B0253
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 15:59:01 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y128so7182361pfg.5
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 12:59:01 -0700 (PDT)
Received: from esa5.hgst.iphmx.com (esa5.hgst.iphmx.com. [216.71.153.144])
        by mx.google.com with ESMTPS id y128si1190660pfy.380.2017.10.20.12.58.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 12:58:59 -0700 (PDT)
From: Bart Van Assche <Bart.VanAssche@wdc.com>
Subject: Re: [RESEND PATCH 1/3] completion: Add support for initializing
 completion with lockdep_map
Date: Fri, 20 Oct 2017 19:58:54 +0000
Message-ID: <1508529532.3029.15.camel@wdc.com>
References: <1508319532-24655-1-git-send-email-byungchul.park@lge.com>
	 <1508319532-24655-2-git-send-email-byungchul.park@lge.com>
	 <1508455438.4542.4.camel@wdc.com>
	 <alpine.DEB.2.20.1710200829340.3083@nanos>
In-Reply-To: <alpine.DEB.2.20.1710200829340.3083@nanos>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <4A4A6AF3E3BC7E488C0D3A7B1918BEFE@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "tglx@linutronix.de" <tglx@linutronix.de>
Cc: "mingo@kernel.org" <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "hch@infradead.org" <hch@infradead.org>, "amir73il@gmail.com" <amir73il@gmail.com>, "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "oleg@redhat.com" <oleg@redhat.com>, "darrick.wong@oracle.com" <darrick.wong@oracle.com>, "johannes.berg@intel.com" <johannes.berg@intel.com>, "byungchul.park@lge.com" <byungchul.park@lge.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "idryomov@gmail.com" <idryomov@gmail.com>, "tj@kernel.org" <tj@kernel.org>, "kernel-team@lge.com" <kernel-team@lge.com>, "david@fromorbit.com" <david@fromorbit.com>

T24gRnJpLCAyMDE3LTEwLTIwIGF0IDA4OjM0ICswMjAwLCBUaG9tYXMgR2xlaXhuZXIgd3JvdGU6
DQo+IE9uIFRodSwgMTkgT2N0IDIwMTcsIEJhcnQgVmFuIEFzc2NoZSB3cm90ZToNCj4gPiBBcmUg
dGhlcmUgYW55IGNvbXBsZXRpb24gb2JqZWN0cyBmb3Igd2hpY2ggdGhlIGNyb3NzLXJlbGVhc2Ug
Y2hlY2tpbmcgaXMNCj4gPiB1c2VmdWw/DQo+IA0KPiBBbGwgb2YgdGhlbSBieSBkZWZpbml0aW9u
Lg0KDQpTb3JyeSBidXQgSSdtIG5vdCBzdXJlIHRoYXQncyB0aGUgYmVzdCBwb3NzaWJsZSBhbnN3
ZXIuIEluIG15IG9waW5pb24NCmF2b2lkaW5nIHRoYXQgY29tcGxldGlvbiBvYmplY3RzIGhhdmUg
ZGVwZW5kZW5jaWVzIG9uIG90aGVyIGxvY2sgb2JqZWN0cywNCmUuZy4gYnkgYXZvaWRpbmcgdG8g
d2FpdCBvbiBhIGNvbXBsZXRpb24gb2JqZWN0IHdoaWxlIGhvbGRpbmcgYSBtdXRleCwgaXMgYQ0K
ZmFyIHN1cGVyaW9yIHN0cmF0ZWd5IG92ZXIgYWRkaW5nIGNyb3NzLXJlbGVhc2UgY2hlY2tpbmcg
dG8gY29tcGxldGlvbg0Kb2JqZWN0cy4gVGhlIGZvcm1lciBzdHJhdGVneSBuYW1lbHkgbWFrZXMg
aXQgdW5uZWNlc3NhcnkgdG8gYWRkDQpjcm9zcy1yZWxlYXNlIGNoZWNraW5nIHRvIGNvbXBsZXRp
b24gb2JqZWN0cyBiZWNhdXNlIHRoYXQgc3RyYXRlZ3kgZW5zdXJlcw0KdGhhdCB0aGVzZSBjb21w
bGV0aW9uIG9iamVjdHMgY2Fubm90IGdldCBpbnZvbHZlZCBpbiBhIGRlYWRsb2NrLiBUaGUgbGF0
dGVyDQpzdHJhdGVneSBjYW4gbGVhZCB0byBmYWxzZSBwb3NpdGl2ZSBkZWFkbG9jayByZXBvcnRz
IGJ5IHRoZSBsb2NrZGVwIGNvZGUsDQpzb21ldGhpbmcgbm9uZSBvZiB1cyB3YW50cy4NCg0KQSBw
b3NzaWJsZSBhbHRlcm5hdGl2ZSBzdHJhdGVneSBjb3VsZCBiZSB0byBlbmFibGUgY3Jvc3MtcmVs
ZWFzZSBjaGVja2luZw0Kb25seSBmb3IgdGhvc2UgY29tcGxldGlvbiBvYmplY3RzIGZvciB3aGlj
aCB3YWl0aW5nIG9jY3VycyBpbnNpZGUgYSBjcml0aWNhbA0Kc2VjdGlvbi4NCg0KPiA+IEFyZSB0
aGVyZSBhbnkgd2FpdF9mb3JfY29tcGxldGlvbigpIGNhbGxlcnMgdGhhdCBob2xkIGEgbXV0ZXgg
b3INCj4gPiBvdGhlciBsb2NraW5nIG9iamVjdD8NCj4gDQo+IFllcywgdGhlcmUgYXJlIGFsc28g
Y3Jvc3MgY29tcGxldGlvbiBkZXBlbmRlbmNpZXMuIFRoZXJlIGhhdmUgYmVlbiBzdWNoDQo+IGJ1
Z3MgYW5kIEkgZXhwZWN0IG1vcmUgdG8gYmUgdW5lYXJ0aGVkLg0KPiANCj4gSSByZWFsbHkgaGF2
ZSB0byBhc2sgd2hhdCB5b3VyIG1vdGl2aWF0aW9uIGlzIHRvIGZpZ2h0IHRoZSBsb2NrZGVwIGNv
dmVyYWdlDQo+IG9mIHN5bmNocm9uaXphdGlvbiBvYmplY3RzIHRvb3RoIGFuZCBuYWlsPw0KDQpB
cyBleHBsYWluZWQgaW4gYW5vdGhlciBlLW1haWwgdGhyZWFkLCB1bmxpa2UgdGhlIGxvY2sgaW52
ZXJzaW9uIGNoZWNraW5nDQpwZXJmb3JtZWQgYnkgdGhlIDw9IHY0LjEzIGxvY2tkZXAgY29kZSwg
Y3Jvc3MtcmVsZWFzZSBjaGVja2luZyBpcyBhIGhldXJpc3RpYw0KdGhhdCBkb2VzIG5vdCBoYXZl
IGEgc291bmQgdGhlb3JldGljYWwgYmFzaXMuIFRoZSBsb2NrIHZhbGlkYXRvciBpcyBhbg0KaW1w
b3J0YW50IHRvb2wgZm9yIGtlcm5lbCBkZXZlbG9wZXJzLiBJdCBpcyBpbXBvcnRhbnQgdGhhdCBp
dCBwcm9kdWNlcyBhcyBmZXcNCmZhbHNlIHBvc2l0aXZlcyBhcyBwb3NzaWJsZS4gU2luY2UgdGhl
IGNyb3NzLXJlbGVhc2UgY2hlY2tzIGFyZSBlbmFibGVkDQphdXRvbWF0aWNhbGx5IHdoZW4gZW5h
YmxpbmcgbG9ja2RlcCwgSSB0aGluayBpdCBpcyBub3JtYWwgdGhhdCBJLCBhcyBhIGtlcm5lbA0K
ZGV2ZWxvcGVyLCBjYXJlIHRoYXQgdGhlIGNyb3NzLXJlbGVhc2UgY2hlY2tzIHByb2R1Y2UgYXMg
ZmV3IGZhbHNlIHBvc2l0aXZlcw0KYXMgcG9zc2libGUuDQoNCkJhcnQu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
