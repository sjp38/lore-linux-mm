Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id EE8D68E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 16:14:34 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id l24-v6so24748028iok.21
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 13:14:34 -0700 (PDT)
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (mail-eopbgr700123.outbound.protection.outlook.com. [40.107.70.123])
        by mx.google.com with ESMTPS id j6-v6si18753121iob.180.2018.09.21.13.14.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 21 Sep 2018 13:14:33 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH v4 3/5] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
Date: Fri, 21 Sep 2018 20:14:32 +0000
Message-ID: <0d9a970c-bec2-e350-be9e-52029282da30@microsoft.com>
References: <20180920215824.19464.8884.stgit@localhost.localdomain>
 <20180920222758.19464.83992.stgit@localhost.localdomain>
 <2254cfe1-5cd3-eedc-1f24-8e011dcf3575@microsoft.com>
 <f4d5ace6-9657-746b-9448-064a4b7cfb8d@linux.intel.com>
In-Reply-To: <f4d5ace6-9657-746b-9448-064a4b7cfb8d@linux.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <7A0664749558304189A8B9EA61198D88@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>
Cc: "mhocko@suse.com" <mhocko@suse.com>, "dave.jiang@intel.com" <dave.jiang@intel.com>, "mingo@kernel.org" <mingo@kernel.org>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "jglisse@redhat.com" <jglisse@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "logang@deltatee.com" <logang@deltatee.com>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

DQo+Pj4gK8KgwqDCoMKgwqDCoMKgIHBhZ2UtPnBnbWFwID0gcGdtYXA7DQo+Pj4gK8KgwqDCoMKg
wqDCoMKgIHBhZ2UtPmhtbV9kYXRhID0gMDsNCj4+DQo+PiBfX2luaXRfc2luZ2xlX3BhZ2UoKQ0K
Pj4gwqDCoCBtbV96ZXJvX3N0cnVjdF9wYWdlKCkNCj4+DQo+PiBUYWtlcyBjYXJlIG9mIHplcm9p
bmcsIG5vIG5lZWQgdG8gZG8gYW5vdGhlciBzdG9yZSBoZXJlLg0KPiANCj4gVGhlIHByb2JsZW0g
aXMgX19pbml0X3NpbmdlX3BhZ2UgYWxzbyBjYWxscyBJTklUX0xJU1RfSEVBRCB3aGljaCBJDQo+
IGJlbGlldmUgc2V0cyB0aGUgcHJldiBwb2ludGVyIHdoaWNoIG92ZXJsYXBzIHdpdGggaG1tX2Rh
dGEuDQoNCkluZGVlZCBpdCBkb2VzOg0KDQpJTklUX0xJU1RfSEVBRCgmcGFnZS0+bHJ1KTsgb3Zl
cmxhcHMgd2l0aCBobW1fZGF0YSwgYW5kIGJlZm9yZQ0KbGlzdF9kZWwoJnBhZ2UtPmxydSk7IHdh
cyBjYWxsZWQgdG8gcmVtb3ZlIGZyb20gdGhlIGxpc3QuDQoNCkFuZCBub3cgSSBzZWUgeW91IGFs
c28gbWVudGlvbmVkIGFib3V0IHRoaXMgaW4gY29tbWVudHMuIEkgYWxzbyBwcmVmZXINCmhhdmlu
ZyBpdCB6ZXJvZWQgaW5zdGVhZCBvZiBsZWZ0IHBvaXNvbmVkIG9yIHVuaW5pdGlhbGl6ZWQuIFRo
ZSBjaGFuZ2UNCmxvb2tzIGdvb2QuDQoNClRoYW5rIHlvdSwNClBhdmVsDQoNCj4gDQo+Pg0KPj4g
TG9va3MgZ29vZCBvdGhlcndpc2UuDQo+Pg0KPj4gUmV2aWV3ZWQtYnk6IFBhdmVsIFRhdGFzaGlu
IDxwYXZlbC50YXRhc2hpbkBtaWNyb3NvZnQuY29tPg0KPj4NCj4gDQo+IFRoYW5rcyBmb3IgdGhl
IHJldmlldy4NCj4g
