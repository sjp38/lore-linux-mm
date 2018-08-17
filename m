Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id EF2C06B059F
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 21:35:25 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id l15-v6so2920917pff.1
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 18:35:25 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0095.outbound.protection.outlook.com. [104.47.41.95])
        by mx.google.com with ESMTPS id 5-v6si830462pgp.439.2018.08.16.18.35.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Aug 2018 18:35:24 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [RESEND PATCH v10 6/6] mm: page_alloc: reduce unnecessary binary
 search in early_pfn_valid()
Date: Fri, 17 Aug 2018 01:35:22 +0000
Message-ID: <c6ed43ee-b09e-1f75-43b3-6cd2808d13f3@microsoft.com>
References: <1530867675-9018-1-git-send-email-hejianet@gmail.com>
 <1530867675-9018-7-git-send-email-hejianet@gmail.com>
In-Reply-To: <1530867675-9018-7-git-send-email-hejianet@gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <7278A4BF60453842886E1096077C73BD@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Vladimir Murzin <vladimir.murzin@arm.com>, Philip Derrin <philip@cog.systems>, AKASHI Takahiro <takahiro.akashi@linaro.org>, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jia He <jia.he@hxt-semitech.com>

DQoNCk9uIDcvNi8xOCA1OjAxIEFNLCBKaWEgSGUgd3JvdGU6DQo+IENvbW1pdCBiOTJkZjFkZTVk
MjggKCJtbTogcGFnZV9hbGxvYzogc2tpcCBvdmVyIHJlZ2lvbnMgb2YgaW52YWxpZCBwZm5zDQo+
IHdoZXJlIHBvc3NpYmxlIikgb3B0aW1pemVkIHRoZSBsb29wIGluIG1lbW1hcF9pbml0X3pvbmUo
KS4gQnV0IHRoZXJlIGlzDQo+IHN0aWxsIHNvbWUgcm9vbSBmb3IgaW1wcm92ZW1lbnQuIEUuZy4g
aW4gZWFybHlfcGZuX3ZhbGlkKCksIGlmIHBmbiBhbmQNCj4gcGZuKzEgYXJlIGluIHRoZSBzYW1l
IG1lbWJsb2NrIHJlZ2lvbiwgd2UgY2FuIHJlY29yZCB0aGUgbGFzdCByZXR1cm5lZA0KPiBtZW1i
bG9jayByZWdpb24gaW5kZXggYW5kIGNoZWNrIHdoZXRoZXIgcGZuKysgaXMgc3RpbGwgaW4gdGhl
IHNhbWUNCj4gcmVnaW9uLg0KPiANCj4gQ3VycmVudGx5IGl0IG9ubHkgaW1wcm92ZSB0aGUgcGVy
Zm9ybWFuY2Ugb24gYXJtL2FybTY0IGFuZCB3aWxsIGhhdmUgbm8NCj4gaW1wYWN0IG9uIG90aGVy
IGFyY2hlcy4NCj4gDQo+IEZvciB0aGUgcGVyZm9ybWFuY2UgaW1wcm92ZW1lbnQsIGFmdGVyIHRo
aXMgc2V0LCBJIGNhbiBzZWUgdGhlIHRpbWUNCj4gb3ZlcmhlYWQgb2YgbWVtbWFwX2luaXQoKSBp
cyByZWR1Y2VkIGZyb20gMjc5NTZ1cyB0byAxMzUzN3VzIGluIG15DQo+IGFybXY4YSBzZXJ2ZXIo
UURGMjQwMCB3aXRoIDk2RyBtZW1vcnksIHBhZ2VzaXplIDY0aykuDQoNClRoaXMgc2VyaWVzIHdv
dWxkIGJlIGEgbG90IHNpbXBsZXIgaWYgcGF0Y2hlcyA0LCA1LCBhbmQgNiB3ZXJlIGRyb3BwZWQu
DQpUaGUgZXh0cmEgY29tcGxleGl0eSBkb2VzIG5vdCBtYWtlIHNlbnNlIHRvIHNhdmUgMC4wMDAx
cy9UIGR1cmluZyBub3QuDQoNClBhdGNoZXMgMS0zLCBsb29rIE9LLCBidXQgd2l0aG91dCBwYXRj
aGVzIDQtNSBfX2luaXRfbWVtYmxvY2sgc2hvdWxkIGJlDQptYWRlIGxvY2FsIHN0YXRpYyBhcyBJ
IHN1Z2dlc3RlZCBlYXJsaWVyLg0KDQpTbywgSSB0aGluayBKaWEgc2hvdWxkIHJlLXNwaW4gdGhp
cyBzZXJpZXMgd2l0aCBvbmx5IDMgcGF0Y2hlcy4gT3IsDQpBbmRyZXcgY291bGQgcmVtb3ZlIHRo
ZSBmcm9tIGxpbnV4LW5leHQgYmVmb3JlIG1lcmdlLg0KDQpUaGFuayB5b3UsDQpQYXZlbA==
