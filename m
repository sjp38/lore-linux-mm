Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id E676E8E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 09:44:10 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id a70-v6so1588820qkb.16
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 06:44:10 -0700 (PDT)
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (mail-eopbgr680115.outbound.protection.outlook.com. [40.107.68.115])
        by mx.google.com with ESMTPS id g82-v6si810922qkh.11.2018.09.12.06.44.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 12 Sep 2018 06:44:09 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH 4/4] nvdimm: Trigger the device probe on a cpu local to
 the device
Date: Wed, 12 Sep 2018 13:44:08 +0000
Message-ID: <3b308b65-ab45-9922-abae-b4c25117e388@microsoft.com>
References: <20180910232615.4068.29155.stgit@localhost.localdomain>
 <20180910234400.4068.15541.stgit@localhost.localdomain>
In-Reply-To: <20180910234400.4068.15541.stgit@localhost.localdomain>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <159C8E5CA49F674ABDCD724B6EFCE6FF@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>
Cc: "mhocko@suse.com" <mhocko@suse.com>, "dave.jiang@intel.com" <dave.jiang@intel.com>, "mingo@kernel.org" <mingo@kernel.org>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "jglisse@redhat.com" <jglisse@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "logang@deltatee.com" <logang@deltatee.com>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

DQoNCk9uIDkvMTAvMTggNzo0NCBQTSwgQWxleGFuZGVyIER1eWNrIHdyb3RlOg0KPiBGcm9tOiBB
bGV4YW5kZXIgRHV5Y2sgPGFsZXhhbmRlci5oLmR1eWNrQGludGVsLmNvbT4NCj4gDQo+IFRoaXMg
cGF0Y2ggaXMgYmFzZWQgb2ZmIG9mIHRoZSBwY2lfY2FsbF9wcm9iZSBmdW5jdGlvbiB1c2VkIHRv
IGluaXRpYWxpemUNCj4gUENJIGRldmljZXMuIFRoZSBnZW5lcmFsIGlkZWEgaGVyZSBpcyB0byBt
b3ZlIHRoZSBwcm9iZSBjYWxsIHRvIGEgbG9jYXRpb24NCj4gdGhhdCBpcyBsb2NhbCB0byB0aGUg
bWVtb3J5IGJlaW5nIGluaXRpYWxpemVkLiBCeSBkb2luZyB0aGlzIHdlIGNhbiBzaGF2ZQ0KPiBz
aWduaWZpY2FudCB0aW1lIG9mZiBvZiB0aGUgdG90YWwgdGltZSBuZWVkZWQgZm9yIGluaXRpYWxp
emF0aW9uLg0KPiANCj4gV2l0aCB0aGlzIHBhdGNoIGFwcGxpZWQgSSBzZWUgYSBzaWduaWZpY2Fu
dCByZWR1Y3Rpb24gaW4gb3ZlcmFsbCBpbml0IHRpbWUNCj4gYXMgd2l0aG91dCBpdCB0aGUgaW5p
dCB2YXJpZWQgYmV0d2VlbiAyMyBhbmQgMzcgc2Vjb25kcyB0byBpbml0aWFsaXplIGEgM0dCDQo+
IG5vZGUuIFdpdGggdGhpcyBwYXRjaCBhcHBsaWVkIHRoZSB2YXJpYW5jZSBpcyBvbmx5IGJldHdl
ZW4gMjMgYW5kIDI2DQo+IHNlY29uZHMgdG8gaW5pdGlhbGl6ZSBlYWNoIG5vZGUuDQo+IA0KPiBJ
IGhvcGUgdG8gcmVmaW5lIHRoaXMgZnVydGhlciBpbiB0aGUgZnV0dXJlIGJ5IGNvbWJpbmluZyB0
aGlzIGxvZ2ljIGludG8NCj4gdGhlIGFzeW5jX3NjaGVkdWxlX2RvbWFpbiBjb2RlIHRoYXQgaXMg
YWxyZWFkeSBpbiB1c2UuIEJ5IGRvaW5nIHRoYXQgaXQNCj4gd291bGQgbGlrZWx5IG1ha2UgdGhp
cyBmdW5jdGlvbmFsaXR5IHJlZHVuZGFudC4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IEFsZXhhbmRl
ciBEdXljayA8YWxleGFuZGVyLmguZHV5Y2tAaW50ZWwuY29tPg0KDQpMb29rcyBnb29kIHRvIG1l
LiBUaGUgcHJldmlvdXMgZmFzdCBydW5zIHdlcmUgYmVjYXVzZSB0aGVyZSB3ZSB3ZXJlDQpnZXR0
aW5nIGx1Y2t5IGFuZCBleGVjdXRlZCBpbiB0aGUgcmlnaHQgbGF0ZW5jeSBncm91cHMsIHJpZ2h0
PyBOb3csIHdlDQpib3VuZCB0aGUgZXhlY3V0aW9uIHRpbWUgdG8gYmUgYWx3YXlzIGZhc3QuDQoN
ClJldmlld2VkLWJ5OiBQYXZlbCBUYXRhc2hpbiA8cGF2ZWwudGF0YXNoaW5AbWljcm9zb2Z0LmNv
bT4NCg0KVGhhbmsgeW91LA0KUGF2ZWw=
