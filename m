Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 62A276B0582
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 21:08:55 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id j9-v6so4934122qtn.22
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 18:08:55 -0700 (PDT)
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (mail-eopbgr680106.outbound.protection.outlook.com. [40.107.68.106])
        by mx.google.com with ESMTPS id t41-v6si759896qth.214.2018.08.16.18.08.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Aug 2018 18:08:54 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [RESEND PATCH v10 3/6] mm: page_alloc: reduce unnecessary binary
 search in memblock_next_valid_pfn()
Date: Fri, 17 Aug 2018 01:08:50 +0000
Message-ID: <61ca29b9-a985-cce0-03e9-d216791c802c@microsoft.com>
References: <1530867675-9018-1-git-send-email-hejianet@gmail.com>
 <1530867675-9018-4-git-send-email-hejianet@gmail.com>
In-Reply-To: <1530867675-9018-4-git-send-email-hejianet@gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <4EA3EB841819D74C911EF6E2CD4115AB@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Vladimir Murzin <vladimir.murzin@arm.com>, Philip Derrin <philip@cog.systems>, AKASHI Takahiro <takahiro.akashi@linaro.org>, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jia He <jia.he@hxt-semitech.com>

DQo+IFNpZ25lZC1vZmYtYnk6IEppYSBIZSA8amlhLmhlQGh4dC1zZW1pdGVjaC5jb20+DQo+IC0t
LQ0KPiAgbW0vbWVtYmxvY2suYyB8IDM3ICsrKysrKysrKysrKysrKysrKysrKysrKysrKysrLS0t
LS0tLS0NCj4gIDEgZmlsZSBjaGFuZ2VkLCAyOSBpbnNlcnRpb25zKCspLCA4IGRlbGV0aW9ucygt
KQ0KPiANCj4gZGlmZiAtLWdpdCBhL21tL21lbWJsb2NrLmMgYi9tbS9tZW1ibG9jay5jDQo+IGlu
ZGV4IGNjYWQyMjUuLjg0ZjdmYTcgMTAwNjQ0DQo+IC0tLSBhL21tL21lbWJsb2NrLmMNCj4gKysr
IGIvbW0vbWVtYmxvY2suYw0KPiBAQCAtMTE0MCwzMSArMTE0MCw1MiBAQCBpbnQgX19pbml0X21l
bWJsb2NrIG1lbWJsb2NrX3NldF9ub2RlKHBoeXNfYWRkcl90IGJhc2UsIHBoeXNfYWRkcl90IHNp
emUsDQo+ICAjZW5kaWYgLyogQ09ORklHX0hBVkVfTUVNQkxPQ0tfTk9ERV9NQVAgKi8NCj4gIA0K
PiAgI2lmZGVmIENPTkZJR19IQVZFX01FTUJMT0NLX1BGTl9WQUxJRA0KPiArc3RhdGljIGludCBl
YXJseV9yZWdpb25faWR4IF9faW5pdF9tZW1ibG9jayA9IC0xOw0KDQpPbmUgY29tbWVudDoNCg0K
VGhpcyBzaG91bGQgYmUgX19pbml0ZGF0YSwgYnV0IGV2ZW4gYmV0dGVyIGJyaW5nIGl0IGluc2lk
ZSB0aGUgZnVuY3Rpb24NCmFzIGxvY2FsIHN0YXRpYyB2YXJpYWJsZS4NCg0KPiAgdWxvbmcgX19p
bml0X21lbWJsb2NrIG1lbWJsb2NrX25leHRfdmFsaWRfcGZuKHVsb25nIHBmbikNCj4gIHsNCg0K
T3RoZXJ3aXNlIGxvb2tzIGdvb2Q6DQoNClJldmlld2VkLWJ5OiBQYXZlbCBUYXRhc2hpbiA8cGF2
ZWwudGF0YXNoaW5AbWljcm9zb2Z0LmNvbT4NCg0K
