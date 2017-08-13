Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2EC606B025F
	for <linux-mm@kvack.org>; Sun, 13 Aug 2017 02:14:26 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id y192so81284461pgd.12
        for <linux-mm@kvack.org>; Sat, 12 Aug 2017 23:14:26 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0074.outbound.protection.outlook.com. [104.47.40.74])
        by mx.google.com with ESMTPS id s8si2583702pgs.474.2017.08.12.23.14.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 12 Aug 2017 23:14:24 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: Re: [PATCH v6 6/7] mm: fix MADV_[FREE|DONTNEED] TLB flush miss
 problem
Date: Sun, 13 Aug 2017 06:14:21 +0000
Message-ID: <E340B75B-2830-4E6D-BF0A-2C58A7002CF1@vmware.com>
References: <20170802000818.4760-1-namit@vmware.com>
 <20170802000818.4760-7-namit@vmware.com>
 <20170811133020.zozuuhbw72lzolj5@hirez.programming.kicks-ass.net>
In-Reply-To: <20170811133020.zozuuhbw72lzolj5@hirez.programming.kicks-ass.net>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <D0DC5E77A78A8F44A29F3FB55D8F7E44@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Linux Kernel Mailing
 List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Ingo Molnar <mingo@redhat.com>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, "David S.
 Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Jeff Dike <jdike@addtoit.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

UGV0ZXIgWmlqbHN0cmEgPHBldGVyekBpbmZyYWRlYWQub3JnPiB3cm90ZToNCg0KPiBPbiBUdWUs
IEF1ZyAwMSwgMjAxNyBhdCAwNTowODoxN1BNIC0wNzAwLCBOYWRhdiBBbWl0IHdyb3RlOg0KPj4g
dm9pZCB0bGJfZmluaXNoX21tdShzdHJ1Y3QgbW11X2dhdGhlciAqdGxiLA0KPj4gCQl1bnNpZ25l
ZCBsb25nIHN0YXJ0LCB1bnNpZ25lZCBsb25nIGVuZCkNCj4+IHsNCj4+IC0JYXJjaF90bGJfZmlu
aXNoX21tdSh0bGIsIHN0YXJ0LCBlbmQpOw0KPj4gKwkvKg0KPj4gKwkgKiBJZiB0aGVyZSBhcmUg
cGFyYWxsZWwgdGhyZWFkcyBhcmUgZG9pbmcgUFRFIGNoYW5nZXMgb24gc2FtZSByYW5nZQ0KPj4g
KwkgKiB1bmRlciBub24tZXhjbHVzaXZlIGxvY2soZS5nLiwgbW1hcF9zZW0gcmVhZC1zaWRlKSBi
dXQgZGVmZXIgVExCDQo+PiArCSAqIGZsdXNoIGJ5IGJhdGNoaW5nLCBhIHRocmVhZCBoYXMgc3Rh
YmxlIFRMQiBlbnRyeSBjYW4gZmFpbCB0byBmbHVzaA0KPj4gKwkgKiB0aGUgVExCIGJ5IG9ic2Vy
dmluZyBwdGVfbm9uZXwhcHRlX2RpcnR5LCBmb3IgZXhhbXBsZSBzbyBmbHVzaCBUTEINCj4+ICsJ
ICogZm9yY2VmdWxseSBpZiB3ZSBkZXRlY3QgcGFyYWxsZWwgUFRFIGJhdGNoaW5nIHRocmVhZHMu
DQo+PiArCSAqLw0KPj4gKwlib29sIGZvcmNlID0gbW1fdGxiX2ZsdXNoX25lc3RlZCh0bGItPm1t
KTsNCj4+ICsNCj4+ICsJYXJjaF90bGJfZmluaXNoX21tdSh0bGIsIHN0YXJ0LCBlbmQsIGZvcmNl
KTsNCj4+IH0NCj4gDQo+IEkgZG9uJ3QgdW5kZXJzdGFuZCB0aGUgY29tbWVudCBub3IgdGhlIG9y
ZGVyaW5nLiBXaGF0IGd1YXJhbnRlZXMgd2Ugc2VlDQo+IHRoZSBpbmNyZW1lbnQgaWYgd2UgbmVl
ZCB0bz8NCg0KVGhlIGNvbW1lbnQgcmVnYXJkcyB0aGUgcHJvYmxlbSB0aGF0IGlzIGRlc2NyaWJl
ZCBpbiB0aGUgY2hhbmdlLWxvZywgYW5kIGENCmxvbmcgdGhyZWFkIHRoYXQgaXMgcmVmZXJlbmNl
ZCBpbiBpdC4gU28gdGhlIHF1ZXN0aW9uIGlzIHdoZXRoZXIg4oCcSSBkb27igJl0DQp1bmRlcnN0
YW5k4oCdIG1lYW5zIOKAnEkgZG9u4oCZdCB1bmRlcnN0YW5k4oCdIG9yIOKAnGl0IGlzIG5vdCBj
bGVhciBlbm91Z2jigJ0uIEnigJlsbA0KYmUgZ2xhZCB0byBhZGRyZXNzIGVpdGhlciBvbmUgLSBq
dXN0IHNheSB3aGljaC4NCg0KQXMgZm9yIHRoZSBvcmRlcmluZyAtIEkgdHJpZWQgdG8gY2xhcmlm
eSBpdCBpbiB0aGUgdGhyZWFkIG9mIHRoZSBjb21taXQuIExldA0KbWUga25vdyBpZiBpdCBpcyBj
bGVhciBub3cuDQoNClJlZ2FyZHMsDQpOYWRhdg0KDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
