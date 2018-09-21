Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 093708E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 10:25:39 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id v20-v6so21783141iom.14
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 07:25:39 -0700 (PDT)
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (mail-eopbgr680123.outbound.protection.outlook.com. [40.107.68.123])
        by mx.google.com with ESMTPS id r19-v6si18611602jad.135.2018.09.21.07.25.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 21 Sep 2018 07:25:38 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH v2 3/4] mm/memory_hotplug: Simplify
 node_states_check_changes_online
Date: Fri, 21 Sep 2018 14:25:36 +0000
Message-ID: <52890425-5d16-bd34-4b88-df174a2be7ff@microsoft.com>
References: <20180921132634.10103-1-osalvador@techadventures.net>
 <20180921132634.10103-4-osalvador@techadventures.net>
In-Reply-To: <20180921132634.10103-4-osalvador@techadventures.net>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <59D565C86967C44C915837B450D02570@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "mhocko@suse.com" <mhocko@suse.com>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "david@redhat.com" <david@redhat.com>, "Jonathan.Cameron@huawei.com" <Jonathan.Cameron@huawei.com>, "yasu.isimatu@gmail.com" <yasu.isimatu@gmail.com>, "malat@debian.org" <malat@debian.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oscar Salvador <osalvador@suse.de>

DQoNCk9uIDkvMjEvMTggOToyNiBBTSwgT3NjYXIgU2FsdmFkb3Igd3JvdGU6DQo+IEZyb206IE9z
Y2FyIFNhbHZhZG9yIDxvc2FsdmFkb3JAc3VzZS5kZT4NCj4gDQo+IFdoaWxlIGxvb2tpbmcgYXQg
bm9kZV9zdGF0ZXNfY2hlY2tfY2hhbmdlc19vbmxpbmUsIEkgc3R1bWJsZWQNCj4gdXBvbiBzb21l
IGNvbmZ1c2luZyB0aGluZ3MuDQo+IA0KPiBSaWdodCBhZnRlciBlbnRlcmluZyB0aGUgZnVuY3Rp
b24sIHdlIGZpbmQgdGhpczoNCj4gDQo+IGlmIChOX01FTU9SWSA9PSBOX05PUk1BTF9NRU1PUlkp
DQo+ICAgICAgICAgem9uZV9sYXN0ID0gWk9ORV9NT1ZBQkxFOw0KPiANCj4gVGhpcyBpcyB3cm9u
Zy4NCj4gTl9NRU1PUlkgY2Fubm90IHJlYWxseSBiZSBlcXVhbCB0byBOX05PUk1BTF9NRU1PUlku
DQo+IE15IGd1ZXNzIGlzIHRoYXQgdGhpcyB3YW50ZWQgdG8gYmUgc29tZXRoaW5nIGxpa2U6DQo+
IA0KPiBpZiAoTl9OT1JNQUxfTUVNT1JZID09IE5fSElHSF9NRU1PUlkpDQo+IA0KPiB0byBjaGVj
ayBpZiB3ZSBoYXZlIENPTkZJR19ISUdITUVNLg0KPiANCj4gTGF0ZXIgb24sIGluIHRoZSBDT05G
SUdfSElHSE1FTSBibG9jaywgd2UgaGF2ZToNCj4gDQo+IGlmIChOX01FTU9SWSA9PSBOX0hJR0hf
TUVNT1JZKQ0KPiAgICAgICAgIHpvbmVfbGFzdCA9IFpPTkVfTU9WQUJMRTsNCj4gDQo+IEFnYWlu
LCB0aGlzIGlzIHdyb25nLCBhbmQgd2lsbCBuZXZlciBiZSBldmFsdWF0ZWQgdG8gdHJ1ZS4NCj4g
DQo+IEJlc2lkZXMgcmVtb3ZpbmcgdGhlc2Ugd3JvbmcgaWYgc3RhdGVtZW50cywgSSBzaW1wbGlm
aWVkDQo+IHRoZSBmdW5jdGlvbiBhIGJpdC4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IE9zY2FyIFNh
bHZhZG9yIDxvc2FsdmFkb3JAc3VzZS5kZT4NCj4gU3VnZ2VzdGVkLWJ5OiBQYXZlbCBUYXRhc2hp
biA8cGF2ZWwudGF0YXNoaW5AbWljcm9zb2Z0LmNvbT4NCg0KUmV2aWV3ZWQtYnk6IFBhdmVsIFRh
dGFzaGluIDxwYXZlbC50YXRhc2hpbkBtaWNyb3NvZnQuY29tPg==
