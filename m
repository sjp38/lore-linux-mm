Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 69E046B0031
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 12:30:32 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id fp1so9264307pdb.2
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 09:30:32 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1lp0145.outbound.protection.outlook.com. [207.46.163.145])
        by mx.google.com with ESMTPS id kn9si45959523pbc.239.2014.07.09.09.30.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 09 Jul 2014 09:30:31 -0700 (PDT)
From: "Gabbay, Oded" <Oded.Gabbay@amd.com>
Subject: Re: [PATCH 1/8] mmput: use notifier chain to call subsystem exit
 handler.
Date: Wed, 9 Jul 2014 16:30:15 +0000
Message-ID: <019CCE693E457142B37B791721487FD918096336@storexdag01.amd.com>
References: <1404856801-11702-1-git-send-email-j.glisse@gmail.com>
	 <1404856801-11702-2-git-send-email-j.glisse@gmail.com>
	 <20140709162123.GN1958@8bytes.org>
In-Reply-To: <20140709162123.GN1958@8bytes.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <00387F204159EF458AD7AE5A86A2D34D@amd.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "joro@8bytes.org" <joro@8bytes.org>
Cc: "ldunning@nvidia.com" <ldunning@nvidia.com>, "airlied@redhat.com" <airlied@redhat.com>, "Morichetti, Laurent" <Laurent.Morichetti@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>, "hpa@zytor.com" <hpa@zytor.com>, "cabuschardt@nvidia.com" <cabuschardt@nvidia.com>, "peterz@infradead.org" <peterz@infradead.org>, "jweiner@redhat.com" <jweiner@redhat.com>, "liranl@mellanox.com" <liranl@mellanox.com>, "raindel@mellanox.com" <raindel@mellanox.com>, "roland@purestorage.com" <roland@purestorage.com>, "dpoole@nvidia.com" <dpoole@nvidia.com>, "jglisse@redhat.com" <jglisse@redhat.com>, "blc@redhat.com" <blc@redhat.com>, "sgutti@nvidia.com" <sgutti@nvidia.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "SCheung@nvidia.com" <SCheung@nvidia.com>, "Mantor, Michael" <Michael.Mantor@amd.com>, "Sander,
 Ben" <ben.sander@amd.com>, "mhairgrove@nvidia.com" <mhairgrove@nvidia.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "aarcange@redhat.com" <aarcange@redhat.com>, "jdonohue@redhat.com" <jdonohue@redhat.com>, "mgorman@suse.de" <mgorman@suse.de>, "j.glisse@gmail.com" <j.glisse@gmail.com>, "riel@redhat.com" <riel@redhat.com>, "Stoner, Greg" <Greg.Stoner@amd.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "arvindg@nvidia.com" <arvindg@nvidia.com>, "jhubbard@nvidia.com" <jhubbard@nvidia.com>

T24gV2VkLCAyMDE0LTA3LTA5IGF0IDE4OjIxICswMjAwLCBKb2VyZyBSb2VkZWwgd3JvdGU6DQo+
IE9uIFR1ZSwgSnVsIDA4LCAyMDE0IGF0IDA1OjU5OjU4UE0gLTA0MDAsIGouZ2xpc3NlQGdtYWls
LmNvbSB3cm90ZToNCj4gPiAgK2ludCBtbXB1dF9yZWdpc3Rlcl9ub3RpZmllcihzdHJ1Y3Qgbm90
aWZpZXJfYmxvY2sgKm5iKQ0KPiA+ICArew0KPiA+ICArICAgICAgICByZXR1cm4gYmxvY2tpbmdf
bm90aWZpZXJfY2hhaW5fcmVnaXN0ZXIoJm1tcHV0X25vdGlmaWVyLCBuYik7DQo+ID4gICt9DQo+
ID4gICtFWFBPUlRfU1lNQk9MX0dQTChtbXB1dF9yZWdpc3Rlcl9ub3RpZmllcik7DQo+ID4gICsN
Cj4gPiAgK2ludCBtbXB1dF91bnJlZ2lzdGVyX25vdGlmaWVyKHN0cnVjdCBub3RpZmllcl9ibG9j
ayAqbmIpDQo+ID4gICt7DQo+ID4gICsgICAgICAgIHJldHVybiBibG9ja2luZ19ub3RpZmllcl9j
aGFpbl91bnJlZ2lzdGVyKCZtbXB1dF9ub3RpZmllciwgbmIpOw0KPiA+ICArfQ0KPiA+ICArRVhQ
T1JUX1NZTUJPTF9HUEwobW1wdXRfdW5yZWdpc3Rlcl9ub3RpZmllcik7DQo+ICANCj4gSSBhbSBz
dGlsbCBub3QgY29udmluY2VkIHRoYXQgdGhpcyBpcyByZXF1aXJlZC4gRm9yIGNvcmUgY29kZSB0
aGF0IA0KPiBuZWVkcw0KPiB0byBob29rIGludG8gbW1wdXQgKGxpa2UgYWlvIG9yIHVwcm9iZXMp
IGl0IHJlYWxseSBpbXByb3ZlcyBjb2RlDQo+IHJlYWRhYmlsaXR5IGlmIHRoZWlyIHRlYXJkb3du
IGZ1bmN0aW9ucyBhcmUgY2FsbGVkIGV4cGxpY2l0bHkgaW4gDQo+IG1tcHV0Lg0KPiAgDQo+IEFu
ZCBkcml2ZXJzIHRoYXQgZGVhbCB3aXRoIHRoZSBtbSBjYW4gdXNlIHRoZSBhbHJlYWR5IGV4aXN0
aW5nDQo+IG1tdV9ub3RpZmVycy4gVGhhdCB3b3JrcyBhdCBsZWFzdCBmb3IgdGhlIEFNRC1JT01N
VXYyIGFuZCBLRkQgDQo+IGRyaXZlcnMuDQo+ICANCj4gTWF5YmUgSE1NIGlzIGRpZmZlcmVudCBo
ZXJlLCBidXQgdGhlbiB5b3Ugc2hvdWxkIGV4cGxhaW4gd2h5IGFuZCBob3cgDQo+IGl0DQo+IGlz
IGRpZmZlcmVudCBhbmQgd2h5IHlvdSBjYW4ndCBhZGQgYW4gZXhwbGljaXQgdGVhcmRvd24gZnVu
Y3Rpb24gZm9yDQo+IEhNTS4NCj4gIA0KPiAgDQo+ICAgICAgICAgSm9lcmcNCj4gIA0KPiAgDQpK
b2VyZywgDQoNCkl0J3MgdHJ1ZSBJJ20gdXNpbmcgdGhlIGNhbGxiYWNrIGZyb20gQU1ELUlPTU1V
djIgd2hlbiBpdCBpcyBjYWxsZWQgDQpmcm9tIHRoZSByZWxlYXNlIG5vdGlmaWVyLCBidXQgSSBv
bmx5IHVzZSB0aGF0IHRvIGRlc3Ryb3kgcXVldWVzIHRoYXQgDQphcmUgcmVsYXRlZCB0byB0aGUg
cGFzaWQgdGhhdCBpcyBiZWluZyB1bmJvdW5kLg0KS0ZEIGRyaXZlciBzdGlsbCBuZWVkcyBlaXRo
ZXIgdGhpcyBwYXRjaCwgb3IgYW4gZXhwbGljaXQgY2FsbCB0byANCmtmZF9wcm9jZXNzX2V4aXQg
ZnJvbSBtbXB1dCB0byByZWxlYXNlIGtmZF9wcm9jZXNzIG9iamVjdCwgd2hpY2ggY2FuJ3QgDQpi
ZSByZWxlYXNlZCBpbiB0aGUgY2FsbGJhY2suIEkgd2VudCBmb3IgdGhlIGV4cGxpY2l0IGNhbGwg
YnV0IEFuZHJldyANCk1vcnRvbiBzYWlkIHRoYXQgdGhpcyBiZWdzIGZvciBjb252ZXJ0aW5nIGlu
dG8gbm90aWZpZXIgY2hhaW4uIEplcm9tZSANCmFuZCBJIGZvbGxvd2VkIGhpcyBhZHZpY2UgYW5k
IGhlbmNlIHRoaXMgcGF0Y2guDQoNCiAgICAgICAgT2RlZA==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
