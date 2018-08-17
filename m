Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id EB6436B0592
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 21:22:34 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id k21-v6so4968666qtj.23
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 18:22:34 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0725.outbound.protection.outlook.com. [2a01:111:f400:fe46::725])
        by mx.google.com with ESMTPS id c66-v6si764287qkd.46.2018.08.16.18.22.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Aug 2018 18:22:34 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [RESEND PATCH v10 3/6] mm: page_alloc: reduce unnecessary binary
 search in memblock_next_valid_pfn()
Date: Fri, 17 Aug 2018 01:22:28 +0000
Message-ID: <91823321-6d66-4b05-e5be-21d024d83854@microsoft.com>
References: <1530867675-9018-1-git-send-email-hejianet@gmail.com>
 <1530867675-9018-4-git-send-email-hejianet@gmail.com>
 <61ca29b9-a985-cce0-03e9-d216791c802c@microsoft.com>
In-Reply-To: <61ca29b9-a985-cce0-03e9-d216791c802c@microsoft.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <956FC95001EB624C9B76803DE75881B7@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Vladimir Murzin <vladimir.murzin@arm.com>, Philip Derrin <philip@cog.systems>, AKASHI Takahiro <takahiro.akashi@linaro.org>, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, Pasha Tatashin <Pavel.Tatashin@microsoft.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jia He <jia.he@hxt-semitech.com>

DQoNCk9uIDgvMTYvMTggOTowOCBQTSwgUGF2ZWwgVGF0YXNoaW4gd3JvdGU6DQo+IA0KPj4gU2ln
bmVkLW9mZi1ieTogSmlhIEhlIDxqaWEuaGVAaHh0LXNlbWl0ZWNoLmNvbT4NCj4+IC0tLQ0KPj4g
IG1tL21lbWJsb2NrLmMgfCAzNyArKysrKysrKysrKysrKysrKysrKysrKysrKysrKy0tLS0tLS0t
DQo+PiAgMSBmaWxlIGNoYW5nZWQsIDI5IGluc2VydGlvbnMoKyksIDggZGVsZXRpb25zKC0pDQo+
Pg0KPj4gZGlmZiAtLWdpdCBhL21tL21lbWJsb2NrLmMgYi9tbS9tZW1ibG9jay5jDQo+PiBpbmRl
eCBjY2FkMjI1Li44NGY3ZmE3IDEwMDY0NA0KPj4gLS0tIGEvbW0vbWVtYmxvY2suYw0KPj4gKysr
IGIvbW0vbWVtYmxvY2suYw0KPj4gQEAgLTExNDAsMzEgKzExNDAsNTIgQEAgaW50IF9faW5pdF9t
ZW1ibG9jayBtZW1ibG9ja19zZXRfbm9kZShwaHlzX2FkZHJfdCBiYXNlLCBwaHlzX2FkZHJfdCBz
aXplLA0KPj4gICNlbmRpZiAvKiBDT05GSUdfSEFWRV9NRU1CTE9DS19OT0RFX01BUCAqLw0KPj4g
IA0KPj4gICNpZmRlZiBDT05GSUdfSEFWRV9NRU1CTE9DS19QRk5fVkFMSUQNCj4+ICtzdGF0aWMg
aW50IGVhcmx5X3JlZ2lvbl9pZHggX19pbml0X21lbWJsb2NrID0gLTE7DQo+IA0KPiBPbmUgY29t
bWVudDoNCj4gDQo+IFRoaXMgc2hvdWxkIGJlIF9faW5pdGRhdGEsIGJ1dCBldmVuIGJldHRlciBi
cmluZyBpdCBpbnNpZGUgdGhlIGZ1bmN0aW9uDQo+IGFzIGxvY2FsIHN0YXRpYyB2YXJpYWJsZS4N
Cg0KRGlzcmVnYXJkIHRoaXMgY29tbWVudCwgdGhpcyBnbG9iYWwgaXMgdXNlZCBpbiB0aGUgbmV4
dCBjb21taXRzLiBTbywNCmV2ZXJ5dGhpbmcgaXMgT0suIE5vIG5lZWQgZm9yIF9faW5pdGRhdGEg
ZWl0aGVyLg0KDQo+IA0KPj4gIHVsb25nIF9faW5pdF9tZW1ibG9jayBtZW1ibG9ja19uZXh0X3Zh
bGlkX3Bmbih1bG9uZyBwZm4pDQo+PiAgew0KPiANCj4gT3RoZXJ3aXNlIGxvb2tzIGdvb2Q6DQo+
IA0KPiBSZXZpZXdlZC1ieTogUGF2ZWwgVGF0YXNoaW4gPHBhdmVsLnRhdGFzaGluQG1pY3Jvc29m
dC5jb20+DQo+IA0KPiA=
