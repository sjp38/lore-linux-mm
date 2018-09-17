Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 526EF8E0001
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 14:55:31 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id a26-v6so6639415pgw.7
        for <linux-mm@kvack.org>; Mon, 17 Sep 2018 11:55:31 -0700 (PDT)
Received: from g2t2352.austin.hpe.com (g2t2352.austin.hpe.com. [15.233.44.25])
        by mx.google.com with ESMTPS id h4-v6si15981313pgc.429.2018.09.17.11.55.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Sep 2018 11:55:30 -0700 (PDT)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: [PATCH 5/5] lib/ioremap: Ensure break-before-make is used for
 huge p4d mappings
Date: Mon, 17 Sep 2018 18:55:26 +0000
Message-ID: <5bb8514bd9cb344a6fdcf3fe7e96fcb2ecfd0136.camel@hpe.com>
References: <1536747974-25875-1-git-send-email-will.deacon@arm.com>
	 <1536747974-25875-6-git-send-email-will.deacon@arm.com>
In-Reply-To: <1536747974-25875-6-git-send-email-will.deacon@arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <C1E31795310A8C4CAB787A806539C77C@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "will.deacon@arm.com" <will.deacon@arm.com>
Cc: "tglx@linutronix.de" <tglx@linutronix.de>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "Hocko, Michal" <MHocko@suse.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

T24gV2VkLCAyMDE4LTA5LTEyIGF0IDExOjI2ICswMTAwLCBXaWxsIERlYWNvbiB3cm90ZToNCj4g
V2hpbHN0IG5vIGFyY2hpdGVjdHVyZXMgYWN0dWFsbHkgZW5hYmxlIHN1cHBvcnQgZm9yIGh1Z2Ug
cDRkIG1hcHBpbmdzDQo+IGluIHRoZSB2bWFwIGFyZWEsIHRoZSBjb2RlIHRoYXQgaXMgaW1wbGVt
ZW50ZWQgc2hvdWxkIGJlIHVzaW5nDQo+IGJyZWFrLWJlZm9yZS1tYWtlLCBhcyB3ZSBkbyBmb3Ig
cHVkIGFuZCBwbWQgaHVnZSBlbnRyaWVzLg0KPiANCj4gQ2M6IENoaW50YW4gUGFuZHlhIDxjcGFu
ZHlhQGNvZGVhdXJvcmEub3JnPg0KPiBDYzogVG9zaGkgS2FuaSA8dG9zaGkua2FuaUBocGUuY29t
Pg0KPiBDYzogVGhvbWFzIEdsZWl4bmVyIDx0Z2x4QGxpbnV0cm9uaXguZGU+DQo+IENjOiBNaWNo
YWwgSG9ja28gPG1ob2Nrb0BzdXNlLmNvbT4NCj4gQ2M6IEFuZHJldyBNb3J0b24gPGFrcG1AbGlu
dXgtZm91bmRhdGlvbi5vcmc+DQo+IFNpZ25lZC1vZmYtYnk6IFdpbGwgRGVhY29uIDx3aWxsLmRl
YWNvbkBhcm0uY29tPg0KDQpUaGFua3MuIFRoaXMga2VlcHMgdGhlIHA0ZCBwYXRoIGNvbnNpc3Rl
bnQuDQoNClJldmlld2VkLWJ5OiBUb3NoaSBLYW5pIDx0b3NoaS5rYW5pQGhwZS5jb20+DQoNCi1U
b3NoaQ0KDQo=
