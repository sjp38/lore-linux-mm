Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 945706B0031
	for <linux-mm@kvack.org>; Sun,  6 Jul 2014 15:25:26 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so4285465pab.29
        for <linux-mm@kvack.org>; Sun, 06 Jul 2014 12:25:26 -0700 (PDT)
Received: from na01-by2-obe.outbound.protection.outlook.com (mail-by2lp0241.outbound.protection.outlook.com. [207.46.163.241])
        by mx.google.com with ESMTPS id gj4si39464907pbb.112.2014.07.06.12.25.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 06 Jul 2014 12:25:25 -0700 (PDT)
From: "Gabbay, Oded" <Oded.Gabbay@amd.com>
Subject: Re: [PATCH 1/6] mmput: use notifier chain to call subsystem exit
 handler.
Date: Sun, 6 Jul 2014 19:25:18 +0000
Message-ID: <019CCE693E457142B37B791721487FD918085329@storexdag01.amd.com>
References: <20140630160604.GF1956@gmail.com>
	 <20140630181623.GE26537@8bytes.org> <20140630183556.GB3280@gmail.com>
	 <20140701091535.GF26537@8bytes.org>
	 <019CCE693E457142B37B791721487FD91806DD8B@storexdag01.amd.com>
	 <20140701110018.GH26537@8bytes.org> <20140701193343.GB3322@gmail.com>
	 <20140701210620.GL26537@8bytes.org> <20140701213208.GC3322@gmail.com>
	 <20140703183024.GA3306@gmail.com> <20140703231541.GR26537@8bytes.org>
In-Reply-To: <20140703231541.GR26537@8bytes.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <0A58AD1CCF4E7042BF1AAC8E44083E23@amd.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "joro@8bytes.org" <joro@8bytes.org>
Cc: "dpoole@nvidia.com" <dpoole@nvidia.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "jweiner@redhat.com" <jweiner@redhat.com>, "mhairgrove@nvidia.com" <mhairgrove@nvidia.com>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "j.glisse@gmail.com" <j.glisse@gmail.com>, "Bridgman, John" <John.Bridgman@amd.com>, "Deucher,
 Alexander" <Alexander.Deucher@amd.com>, "Lewycky, Andrew" <Andrew.Lewycky@amd.com>, "sgutti@nvidia.com" <sgutti@nvidia.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "riel@redhat.com" <riel@redhat.com>, "arvindg@nvidia.com" <arvindg@nvidia.com>, "SCheung@nvidia.com" <SCheung@nvidia.com>, "jakumar@nvidia.com" <jakumar@nvidia.com>, "jhubbard@nvidia.com" <jhubbard@nvidia.com>, "Cornwall, Jay" <Jay.Cornwall@amd.com>, "mgorman@suse.de" <mgorman@suse.de>, "cabuschardt@nvidia.com" <cabuschardt@nvidia.com>, "ldunning@nvidia.com" <ldunning@nvidia.com>

T24gRnJpLCAyMDE0LTA3LTA0IGF0IDAxOjE1ICswMjAwLCBKb2VyZyBSb2VkZWwgd3JvdGU6DQo+
IEhpIEplcm9tZSwNCj4gDQo+IE9uIFRodSwgSnVsIDAzLCAyMDE0IGF0IDAyOjMwOjI2UE0gLTA0
MDAsIEplcm9tZSBHbGlzc2Ugd3JvdGU6DQo+ID4gSm9lcmcgZG8geW91IHN0aWxsIG9iamVjdCB0
byB0aGlzIHBhdGNoID8NCj4gDQo+IFllcy4NCj4gDQo+ID4gQWdhaW4gdGhlIG5hdHVyYWwgcGxh
Y2UgdG8gY2FsbCB0aGlzIGlzIGZyb20gbW1wdXQgYW5kIHRoZSBmYWN0IHRoYXQgbWFueQ0KPiA+
IG90aGVyIHN1YnN5c3RlbSBhbHJlYWR5IGNhbGwgaW4gZnJvbSB0aGVyZSB0byBjbGVhbnVwIHRo
ZXJlIG93biBwZXIgbW0gZGF0YQ0KPiA+IHN0cnVjdHVyZSBpcyBhIHRlc3RpbW9ueSB0aGF0IHRo
aXMgaXMgYSB2YWxpZCB1c2UgY2FzZSBhbmQgdmFsaWQgZGVzaWduLg0KPiANCj4gRGV2aWNlIGRy
aXZlcnMgYXJlIHNvbWV0aGluZyBkaWZmZXJlbnQgdGhhbiBzdWJzeXN0ZW1zLiANCkkgdGhpbmsg
dGhhdCBoc2EgKGtmZCkgYW5kIGhtbSBfYXJlXyBzdWJzeXN0ZW1zLCBpZiBub3QgaW4gZGVmaW5p
dGlvbg0KdGhhbiBpbiBwcmFjdGljZS4gT3VyIG1vZGVsIGlzIG5vdCBhIGNsYXNzaWMgZGV2aWNl
LWRyaXZlciBtb2RlbCBpbiB0aGUNCnNlbnNlIHRoYXQgb3VyIGlvY3RsJ3MgYXJlIG1vcmUgbGlr
ZSBzeXNjYWxscyB0aGFuIHRyYWRpdGlvbmFsDQpkZXZpY2UtZHJpdmVyIGlvY3Rscy4gZS5nIG91
ciBrZmRfb3BlbigpIGRvZXNuJ3Qgb3BlbiBhIGtmZCBkZXZpY2Ugb3INCmV2ZW4gYSBncHUgZGV2
aWNlLCBpdCAqYmluZHMqIGEgKnByb2Nlc3MqIHRvIGEgZGV2aWNlLiBTbyBiYXNpY2FsbHksIG91
cg0KaW9jdGxzIGFyZSBub3QgcmVsYXRlZCB0byBhIHNwZWNpZmljIEgvVyBpbnN0YW5jZSAoc3Bl
Y2lmaWMgR1BVIGluIGNhc2UNCm9mIGtmZCkgYnV0IG1vcmUgcmVsYXRlZCB0byBhIHNwZWNpZmlj
IHByb2Nlc3MuDQoNCk9uY2Ugd2UgY2FuIGFncmVlIG9uIHRoYXQsIHRoYW4gSSB0aGluayB3ZSBj
YW4gYWdyZWUgdGhhdCBrZmQgYW5kIGhtbQ0KY2FuIGFuZCBzaG91bGQgYmUgYm91bmRlZCB0byBt
bSBzdHJ1Y3QgYW5kIG5vdCBmaWxlIGRlc2NyaXB0b3JzLg0KDQoJT2RlZA0KDQo+IEkgdGhpbmsg
dGhlDQo+IHBvaW50IHRoYXQgdGhlIG1tdV9ub3RpZmllciBzdHJ1Y3QgY2FuIG5vdCBiZSBmcmVl
ZCBpbiB0aGUgLnJlbGVhc2UNCj4gY2FsbC1iYWNrIGlzIGEgd2VhayByZWFzb24gZm9yIGludHJv
ZHVjaW5nIGEgbmV3IG5vdGlmaWVyLiBJbiB0aGUgZW5kDQo+IGV2ZXJ5IHVzZXIgb2YgbW11X25v
dGlmaWVycyBoYXMgdG8gY2FsbCBtbXVfbm90aWZpZXJfcmVnaXN0ZXIgc29tZXdoZXJlDQo+IChm
aWxlLW9wZW4vaW9jdGwgcGF0aCBvciBzb21ld2hlcmUgZWxzZSB3aGVyZSB0aGUgbW08LT5kZXZp
Y2UgYmluZGluZyBpcw0KPiAgc2V0IHVwKSBhbmQgY2FuIGNhbGwgbW11X25vdGlmaWVyX3VucmVn
aXN0ZXIgaW4gYSBzaW1pbGFyIHBhdGggd2hpY2gNCj4gZGVzdHJveXMgdGhlIGJpbmRpbmcuDQo+
IA0KPiA+IFlvdSBwb2ludGVkIG91dCB0aGF0IHRoZSBjbGVhbnVwIHNob3VsZCBiZSBkb25lIGZy
b20gdGhlIGRldmljZSBkcml2ZXIgZmlsZQ0KPiA+IGNsb3NlIGNhbGwuIEJ1dCBhcyBpIHN0cmVz
c2VkIHNvbWUgb2YgdGhlIG5ldyB1c2VyIHdpbGwgbm90IG5lY2Vzc2FyaWx5IGhhdmUNCj4gPiBh
IGRldmljZSBmaWxlIG9wZW4gaGVuY2Ugbm8gd2F5IGZvciB0aGVtIHRvIGZyZWUgdGhlIGFzc29j
aWF0ZWQgc3RydWN0dXJlDQo+ID4gZXhjZXB0IHdpdGggaGFja2lzaCBkZWxheWVkIGpvYi4NCj4g
DQo+IFBsZWFzZSB0ZWxsIG1lIG1vcmUgYWJvdXQgdGhlc2UgJ25ldyB1c2VycycsIGhvdyBkb2Vz
IG1tPC0+ZGV2aWNlIGJpbmRpbmcNCj4gaXMgc2V0IHVwIHRoZXJlIGlmIG5vIGZkIGlzIHVzZWQ/
DQo+IA0KPiANCj4gCUpvZXJnDQo+IA0KPiANCg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
