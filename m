Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 530276B0008
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 12:19:57 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id u1-v6so3828831wrs.18
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 09:19:57 -0700 (PDT)
Received: from eu-smtp-delivery-211.mimecast.com (eu-smtp-delivery-211.mimecast.com. [207.82.80.211])
        by mx.google.com with ESMTPS id f140-v6si3603777wme.28.2018.07.19.09.19.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 09:19:55 -0700 (PDT)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] mm: Cleanup in do_shrink_slab()
Date: Thu, 19 Jul 2018 16:21:32 +0000
Message-ID: <0f98d9b38be1466b8608d5c071aa52ed@AcuMS.aculab.com>
References: <153201627722.12295.11034132843390627757.stgit@localhost.localdomain>
In-Reply-To: <153201627722.12295.11034132843390627757.stgit@localhost.localdomain>
Content-Language: en-US
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Kirill Tkhai' <ktkhai@virtuozzo.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "vdavydov.dev@gmail.com" <vdavydov.dev@gmail.com>, "mhocko@suse.com" <mhocko@suse.com>, "penguin-kernel@I-love.SAKURA.ne.jp" <penguin-kernel@I-love.SAKURA.ne.jp>, "shakeelb@google.com" <shakeelb@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

RnJvbTogS2lyaWxsIFRraGFpDQo+IFNlbnQ6IDE5IEp1bHkgMjAxOCAxNzowNQ0KPiANCj4gR3Jv
dXAgbG9uZyB2YXJpYWJsZXMgdG9nZXRoZXIgdG8gbWluaW1pemUgbnVtYmVyIG9mIG9jY3VwaWVk
IGxpbmVzDQo+IGFuZCBwbGFjZSBhbGwgZGVmaW5pdGlvbnMgaW4gYmFjayBDaHJpc3RtYXMgdHJl
ZSBvcmRlci4NCg0KR3JvdXBpbmcgdG9nZXRoZXIgdW5yZWxhdGVkIHZhcmlhYmxlcyBkb2Vzbid0
IHJlYWxseSBtYWtlIHRoZSBjb2RlDQphbnkgbW9yZSByZWFkYWJsZS4NCklNSE8gT25lIHZhcmlh
YmxlIHBlciBsaW5lIGlzIHVzdWFsbHkgYmVzdC4NCg0KPiBBbHNvLCBzaW1wbGlmeSBleHByZXNz
aW9uIGFyb3VuZCBiYXRjaF9zaXplOiB1c2UgYWxsIHBvd2VyIG9mIEMgbGFuZ3VhZ2UhDQoNCiAg
IGZvbyA9IGJhciA/IDogYmF6Ow0KSXMgbm90IHBhcnQgb2YgQywgaXQgaXMgYSBnY2MgZXh0ZW5z
aW9uLg0KDQoJRGF2aWQNCg0KLQ0KUmVnaXN0ZXJlZCBBZGRyZXNzIExha2VzaWRlLCBCcmFtbGV5
IFJvYWQsIE1vdW50IEZhcm0sIE1pbHRvbiBLZXluZXMsIE1LMSAxUFQsIFVLDQpSZWdpc3RyYXRp
b24gTm86IDEzOTczODYgKFdhbGVzKQ0K
