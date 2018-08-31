Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id CD7B56B5750
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 10:05:02 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id f34-v6so13929677qtk.16
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 07:05:02 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0138.outbound.protection.outlook.com. [104.47.33.138])
        by mx.google.com with ESMTPS id p43-v6si493634qtb.253.2018.08.31.07.05.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 31 Aug 2018 07:05:01 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH] mm/page_alloc: Clean up check_for_memory
Date: Fri, 31 Aug 2018 14:04:59 +0000
Message-ID: <b2fea9ef-84e9-84dc-c847-5b944a8d832f@microsoft.com>
References: <20180828210158.4617-1-osalvador@techadventures.net>
 <332d9ea1-cdd0-6bb6-8e83-28af25096637@microsoft.com>
 <20180831122401.GA2123@techadventures.net>
In-Reply-To: <20180831122401.GA2123@techadventures.net>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <18361ACBE0182B419F357C275908FB63@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.com" <mhocko@suse.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "sfr@canb.auug.org.au" <sfr@canb.auug.org.au>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oscar Salvador <osalvador@suse.de>

DQoNCk9uIDgvMzEvMTggODoyNCBBTSwgT3NjYXIgU2FsdmFkb3Igd3JvdGU6DQo+IE9uIFRodSwg
QXVnIDMwLCAyMDE4IGF0IDAxOjU1OjI5QU0gKzAwMDAsIFBhc2hhIFRhdGFzaGluIHdyb3RlOg0K
Pj4gSSB3b3VsZCByZS13cml0ZSB0aGUgYWJvdmUgZnVuY3Rpb24gbGlrZSB0aGlzOg0KPj4gc3Rh
dGljIHZvaWQgY2hlY2tfZm9yX21lbW9yeShwZ19kYXRhX3QgKnBnZGF0LCBpbnQgbmlkKQ0KPj4g
ew0KPj4gICAgICAgICBlbnVtIHpvbmVfdHlwZSB6b25lX3R5cGU7DQo+Pg0KPj4gICAgICAgICBm
b3IgKHpvbmVfdHlwZSA9IDA7IHpvbmVfdHlwZSA8IFpPTkVfTU9WQUJMRTsgem9uZV90eXBlKysp
IHsNCj4+ICAgICAgICAgICAgICAgICBpZiAocG9wdWxhdGVkX3pvbmUoJnBnZGF0LT5ub2RlX3pv
bmVzW3pvbmVfdHlwZV0pKSB7IA0KPj4gICAgICAgICAgICAgICAgICAgICAgICAgbm9kZV9zZXRf
c3RhdGUobmlkLCB6b25lX3R5cGUgPD0gWk9ORV9OT1JNQUwgPw0KPj4gICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgTl9OT1JNQUxfTUVNT1JZOiBOX0hJR0hfTUVNT1JZKTsN
Cj4+ICAgICAgICAgICAgICAgICAgICAgICAgIGJyZWFrOw0KPj4gICAgICAgICAgICAgICAgIH0N
Cj4+ICAgICAgICAgfQ0KPj4gfQ0KPiANCj4gSGkgUGF2ZWwsDQo+IA0KPiB0aGUgYWJvdmUgd291
bGQgbm90IHdvcmsgZmluZS4NCj4gWW91IHNldCBlaXRoZXIgTl9OT1JNQUxfTUVNT1JZIG9yIE5f
SElHSF9NRU1PUlksIGJ1dCBhIG5vZGUgY2FuIGhhdmUgYm90aA0KPiB0eXBlcyBvZiBtZW1vcnkg
YXQgdGhlIHNhbWUgdGltZSAob24gQ09ORklHX0hJR0hNRU0gc3lzdGVtcykuDQo+IA0KPiBOX0hJ
R0hfTUVNT1JZIHN0YW5kcyBmb3IgcmVndWxhciBvciBoaWdoIG1lbW9yeQ0KPiB3aGlsZSBOX05P
Uk1BTF9NRU1PUlkgc3RhbmRzIG9ubHkgZm9yIHJlZ3VsYXIgbWVtb3J5LA0KPiB0aGF0IGlzIHdo
eSB3ZSBzZXQgaXQgb25seSBpbiBjYXNlIHRoZSB6b25lIGlzIDw9IFpPTkVfTk9STUFMLg0KDQpI
aSBPc2NhciwNCg0KQXJlIHlvdSBzYXlpbmcgdGhlIGNvZGUgdGhhdCBpcyBpbiBtYWlubGluZSBp
cyBicm9rZW4/IEJlY2F1c2Ugd2Ugc2V0DQpub2RlX3NldF9zdGF0ZShuaWQsIE5fTk9STUFMX01F
TU9SWSk7IGV2ZW4gb24gbm9kZSB3aXRoIE5fSElHSF9NRU1PUlk6DQoNCjY4MjYJCQlpZiAoTl9O
T1JNQUxfTUVNT1JZICE9IE5fSElHSF9NRU1PUlkgJiYNCjY4MjcJCQkgICAgem9uZV90eXBlIDw9
IFpPTkVfTk9STUFMKQ0KNjgyOAkJCQlub2RlX3NldF9zdGF0ZShuaWQsIE5fTk9STUFMX01FTU9S
WSk7DQoNClRoYW5rIHlvdSwNClBhdmVs
