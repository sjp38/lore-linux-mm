Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 07B606B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 06:28:52 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id j4so4983384pfc.8
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 03:28:52 -0700 (PDT)
Received: from epoutp02.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id e6si7028232pgf.259.2017.03.29.03.28.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 03:28:50 -0700 (PDT)
Received: from epcas2p2.samsung.com (unknown [182.195.41.54])
	by epoutp02.samsung.com (KnoxPortal) with ESMTP id 20170329102847epoutp0229afb84d3bb7e0caa7561ab9b3516ae2~wU4m_2Trf1247812478epoutp02I
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 10:28:47 +0000 (GMT)
Mime-Version: 1.0
Subject: Re: [PATCH v2] module: check if memory leak by module.
Reply-To: v.narang@samsung.com
From: Vaneet Narang <v.narang@samsung.com>
In-Reply-To: <alpine.LSU.2.20.1703290958390.4250@pobox.suse.cz>
Message-ID: <20170329092332epcms5p10ae8263c6e3ef14eac40e08a09eff9e6@epcms5p1>
Date: Wed, 29 Mar 2017 09:23:32 +0000
Content-Type: multipart/related;
	boundary="----=_Part_233510_75706858.1490779412459"
References: <alpine.LSU.2.20.1703290958390.4250@pobox.suse.cz>
	<1490767322-9914-1-git-send-email-maninder1.s@samsung.com>
	<20170329074522.GB27994@dhcp22.suse.cz>
	<CGME20170329060315epcas5p1c6f7ce3aca1b2770c5e1d9aaeb1a27e1@epcms5p1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miroslav Benes <mbenes@suse.cz>, Michal Hocko <mhocko@kernel.org>
Cc: Maninder Singh <maninder1.s@samsung.com>, "jeyu@redhat.com" <jeyu@redhat.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris@chris-wilson.co.uk" <chris@chris-wilson.co.uk>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "joonas.lahtinen@linux.intel.com" <joonas.lahtinen@linux.intel.com>, "keescook@chromium.org" <keescook@chromium.org>, "pavel@ucw.cz" <pavel@ucw.cz>, "jinb.park7@gmail.com" <jinb.park7@gmail.com>, "anisse@astier.eu" <anisse@astier.eu>, "rafael.j.wysocki@intel.com" <rafael.j.wysocki@intel.com>, "zijun_hu@htc.com" <zijun_hu@htc.com>, "mingo@kernel.org" <mingo@kernel.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "thgarnie@google.com" <thgarnie@google.com>, "joelaf@google.com" <joelaf@google.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, PANKAJ MISHRA <pankaj.m@samsung.com>, Ajeet Kumar Yadav <ajeet.y@samsung.com>, =?UTF-8?B?7J207ZWZ67SJ?= <hakbong5.lee@samsung.com>, AMIT SAHRAWAT <a.sahrawat@samsung.com>, =?UTF-8?B?656E66a/?= <lalit.mohan@samsung.com>, CPGS <cpgs@samsung.com>

------=_Part_233510_75706858.1490779412459
Content-Transfer-Encoding: base64
Content-Type: text/plain; charset="utf-8"

SGksDQoNCj4+IEhtbSwgaG93IGNhbiB5b3UgdHJhY2sgX2FsbF8gdm1hbGxvYyBhbGxvY2F0aW9u
cyBkb25lIG9uIGJlaGFsZiBvZiB0aGUNCj4+IG1vZHVsZT8gSXQgaXMgcXVpdGUgc29tZSB0aW1l
IHNpbmNlIEkndmUgY2hlY2tlZCBrZXJuZWwvbW9kdWxlLmMgYnV0DQo+PiBmcm9tIG15IHZhZ3Vl
IHVuZGVyc3RhZGluZyB5b3VyIGNoZWNrIGlzIGJhc2ljYWxseSBvbmx5IGFib3V0IHN0YXRpY2Fs
bHkNCj4+IHZtYWxsb2NlZCBhcmVhcyBieSBtb2R1bGUgbG9hZGVyLiBJcyB0aGF0IGNvcnJlY3Q/
IElmIHllcyB0aGVuIGlzIHRoaXMNCj4+IGFjdHVhbGx5IHVzZWZ1bD8gV2VyZSB0aGVyZSBhbnkg
YnVncyBpbiB0aGUgbG9hZGVyIGNvZGUgcmVjZW50bHk/IFdoYXQNCj4+IGxlZCB5b3UgdG8gcHJl
cGFyZSB0aGlzIHBhdGNoPyBBbGwgdGhpcyBzaG91bGQgYmUgcGFydCBvZiB0aGUgY2hhbmdlbG9n
IQ0KDQpGaXJzdCBvZiBhbGwgdGhlcmUgaXMgbm8gaXNzdWUgaW4ga2VybmVsL21vZHVsZS5jLiBU
aGlzIHBhdGNoIGFkZCBmdW5jdGlvbmFsaXR5DQp0byBkZXRlY3Qgc2NlbmFyaW8gd2hlcmUgc29t
ZSBrZXJuZWwgbW9kdWxlIGRvZXMgc29tZSBtZW1vcnkgYWxsb2NhdGlvbiBidXQgZ2V0cw0KdW5s
b2FkZWQgd2l0aG91dCBkb2luZyB2ZnJlZS4gRm9yIGV4YW1wbGUNCnN0YXRpYyBpbnQga2VybmVs
X2luaXQodm9pZCkNCnsNCiAgICAgICAgY2hhciAqIHB0ciA9IHZtYWxsb2MoNDAwICogMTAyNCk7
DQogICAgICAgIHJldHVybiAwOw0KfQ0KDQpzdGF0aWMgdm9pZCBrZXJuZWxfZXhpdCh2b2lkKQ0K
eyAgICAgICAgDQp9DQoNCk5vdyBpbiB0aGlzIGNhc2UgaWYgd2UgZG8gcm1tb2QgdGhlbiBtZW1v
cnkgYWxsb2NhdGVkIGJ5IGtlcm5lbF9pbml0DQp3aWxsIG5vdCBiZSBmcmVlZCBidXQgdGhpcyBw
YXRjaCB3aWxsIGRldGVjdCBzdWNoIGtpbmQgb2YgYnVncyBpbiBrZXJuZWwgbW9kdWxlIA0KY29k
ZS4NCg0KQWxzbyBXZSBoYXZlIHNlZW4gYnVncyBpbiBzb21lIGtlcm5lbCBtb2R1bGVzIHdoZXJl
IHRoZXkgYWxsb2NhdGUgc29tZSBtZW1vcnkgYW5kDQpnZXRzIHJlbW92ZWQgd2l0aG91dCBmcmVl
aW5nIHRoZW0gYW5kIGlmIG5ldyBtb2R1bGUgZ2V0cyBsb2FkZWQgaW4gcGxhY2UNCm9mIHJlbW92
ZWQgbW9kdWxlIHRoZW4gL3Byb2Mvdm1hbGxvY2luZm8gc2hvd3Mgd3JvbmcgaW5mb3JtYXRpb24u
IHZtYWxsb2MgaW5mbyB3aWxsDQpzaG93IHBhZ2VzIGdldHRpbmcgYWxsb2NhdGVkIGJ5IG5ldyBt
b2R1bGUuIFNvIHRoZXNlIGxvZ3Mgd2lsbCBoZWxwIGluIGRldGVjdGluZyANCnN1Y2ggaXNzdWVz
Lg0KDQo+ID4gIHN0YXRpYyB2b2lkIGZyZWVfbW9kdWxlKHN0cnVjdCBtb2R1bGUgKm1vZCkNCj4g
PiAgew0KPiA+ICsJY2hlY2tfbWVtb3J5X2xlYWsobW9kKTsNCj4gPiArDQoNCj5PZiBjb3Vyc2Us
IHZmcmVlKCkgaGFzIG5vdCBiZWVuIGNhbGxlZCB5ZXQuIEl0IGlzIHRoZSBiZWdpbm5pbmcgb2Yg
DQo+ZnJlZV9tb2R1bGUoKS4gdmZyZWUoKSBpcyBvbmUgb2YgdGhlIGxhc3QgdGhpbmdzIHlvdSBu
ZWVkIHRvIGRvLiBTZWUgDQo+bW9kdWxlX21lbWZyZWUoKS4gSWYgSSBhbSBub3QgbWlzc2luZyBz
b21ldGhpbmcsIHlvdSBnZXQgcHJfZXJyKCkgDQo+ZXZlcnl0aW1lIGEgbW9kdWxlIGlzIHVubG9h
ZGVkLg0KDQpUaGlzIHBhdGNoIGlzIG5vdCB0byBkZXRlY3QgbWVtb3J5IGFsbG9jYXRlZCBieSBr
ZXJuZWwuIG1vZHVsZV9tZW1mcmVlDQp3aWxsIGFsbG9jYXRlZCBieSBrZXJuZWwgZm9yIGtlcm5l
bCBtb2R1bGVzIGJ1dCBvdXIgaW50ZW50IGlzIHRvIGRldGVjdA0KbWVtb3J5IGFsbG9jYXRlZCBk
aXJlY3RseSBieSBrZXJuZWwgbW9kdWxlcyBhbmQgbm90IGdldHRpbmcgZnJlZWQuDQoNClJlZ2Fy
ZHMsDQpWYW5lZXQgTmFyYW5n
------=_Part_233510_75706858.1490779412459--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
