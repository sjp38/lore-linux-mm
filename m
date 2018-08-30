Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id EA3B36B5396
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 18:30:52 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id s200-v6so8986289oie.6
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 15:30:52 -0700 (PDT)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0134.outbound.protection.outlook.com. [104.47.42.134])
        by mx.google.com with ESMTPS id o203-v6si5490540oif.198.2018.08.30.15.30.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 30 Aug 2018 15:30:52 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH v1 4/5] mm/memory_hotplug: onlining pages can only fail
 due to notifiers
Date: Thu, 30 Aug 2018 22:30:49 +0000
Message-ID: <b558718f-d950-0890-a228-a8494c117f5f@microsoft.com>
References: <20180816100628.26428-1-david@redhat.com>
 <20180816100628.26428-5-david@redhat.com>
In-Reply-To: <20180816100628.26428-5-david@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <747BDC40E882F247AD0506982A099E18@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Jia He <jia.he@hxt-semitech.com>, Oscar Salvador <osalvador@suse.de>, Petr Tesarik <ptesarik@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dan Williams <dan.j.williams@intel.com>, Mathieu Malaterre <malat@debian.org>, Baoquan He <bhe@redhat.com>, Wei Yang <richard.weiyang@gmail.com>, Ross Zwisler <zwisler@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

TEdUTQ0KDQpSZXZpZXdlZC1ieTogUGF2ZWwgVGF0YXNoaW4gPHBhdmVsLnRhdGFzaGluQG1pY3Jv
c29mdC5jb20+DQoNCk9uIDgvMTYvMTggNjowNiBBTSwgRGF2aWQgSGlsZGVuYnJhbmQgd3JvdGU6
DQo+IE9ubGluaW5nIHBhZ2VzIGNhbiBvbmx5IGZhaWwgaWYgYSBub3RpZmllciByZXBvcnRlZCBh
IHByb2JsZW0gKGUuZy4gLUVOT01FTSkuDQo+IG9ubGluZV9wYWdlc19yYW5nZSgpIGNhbiBuZXZl
ciBmYWlsLg0KPiANCj4gU2lnbmVkLW9mZi1ieTogRGF2aWQgSGlsZGVuYnJhbmQgPGRhdmlkQHJl
ZGhhdC5jb20+DQo+IC0tLQ0KPiAgbW0vbWVtb3J5X2hvdHBsdWcuYyB8IDkgKystLS0tLS0tDQo+
ICAxIGZpbGUgY2hhbmdlZCwgMiBpbnNlcnRpb25zKCspLCA3IGRlbGV0aW9ucygtKQ0KPiANCj4g
ZGlmZiAtLWdpdCBhL21tL21lbW9yeV9ob3RwbHVnLmMgYi9tbS9tZW1vcnlfaG90cGx1Zy5jDQo+
IGluZGV4IDNkYzZkMmEzMDljMi4uYmJiZDE2ZjlkODc3IDEwMDY0NA0KPiAtLS0gYS9tbS9tZW1v
cnlfaG90cGx1Zy5jDQo+ICsrKyBiL21tL21lbW9yeV9ob3RwbHVnLmMNCj4gQEAgLTkzMywxMyAr
OTMzLDggQEAgaW50IF9fcmVmIG9ubGluZV9wYWdlcyh1bnNpZ25lZCBsb25nIHBmbiwgdW5zaWdu
ZWQgbG9uZyBucl9wYWdlcywgaW50IG9ubGluZV90eXANCj4gIAkJc2V0dXBfem9uZV9wYWdlc2V0
KHpvbmUpOw0KPiAgCX0NCj4gIA0KPiAtCXJldCA9IHdhbGtfc3lzdGVtX3JhbV9yYW5nZShwZm4s
IG5yX3BhZ2VzLCAmb25saW5lZF9wYWdlcywNCj4gLQkJb25saW5lX3BhZ2VzX3JhbmdlKTsNCj4g
LQlpZiAocmV0KSB7DQo+IC0JCWlmIChuZWVkX3pvbmVsaXN0c19yZWJ1aWxkKQ0KPiAtCQkJem9u
ZV9wY3BfcmVzZXQoem9uZSk7DQo+IC0JCWdvdG8gZmFpbGVkX2FkZGl0aW9uOw0KPiAtCX0NCj4g
Kwl3YWxrX3N5c3RlbV9yYW1fcmFuZ2UocGZuLCBucl9wYWdlcywgJm9ubGluZWRfcGFnZXMsDQo+
ICsJCQkgICAgICBvbmxpbmVfcGFnZXNfcmFuZ2UpOw0KPiAgDQo+ICAJem9uZS0+cHJlc2VudF9w
YWdlcyArPSBvbmxpbmVkX3BhZ2VzOw0KPiAgDQo+IA==
