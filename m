Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8BC9E6B0071
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 11:14:29 -0400 (EDT)
Received: by payr10 with SMTP id r10so99939539pay.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 08:14:29 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id gf9si4503302pbc.213.2015.06.08.08.14.28
        for <linux-mm@kvack.org>;
        Mon, 08 Jun 2015 08:14:28 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [RFC PATCH 01/12] mm: add a new config to manage the code
Date: Mon, 8 Jun 2015 15:14:27 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F32A8E39B@ORSMSX114.amr.corp.intel.com>
References: <55704A7E.5030507@huawei.com> <55704B0C.1000308@huawei.com>
 <CALq1K=J7BuqMDkPrjioRVyRedHLhmM-gg8MOb9GSBcrmNah23g@mail.gmail.com>
In-Reply-To: <CALq1K=J7BuqMDkPrjioRVyRedHLhmM-gg8MOb9GSBcrmNah23g@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leon Romanovsky <leon@leon.nu>, Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "nao.horiguchi@gmail.com" <nao.horiguchi@gmail.com>, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

PiA+ICtjb25maWcgTUVNT1JZX01JUlJPUg0KPiA+ICsgICAgICAgYm9vbCAiQWRkcmVzcyByYW5n
ZSBtaXJyb3Jpbmcgc3VwcG9ydCINCj4gPiArICAgICAgIGRlcGVuZHMgb24gWDg2ICYmIE5VTUEN
Cj4gPiArICAgICAgIGRlZmF1bHQgeQ0KPiBJcyBpdCBjb3JyZWN0IGZvciB0aGUgc3lzdGVtcyAo
Tk9UIHhlb24pIHdpdGhvdXQgbWVtb3J5IHN1cHBvcnQgYnVpbHQgaW4/DQoNCklzIHRoZSAiJiYg
TlVNQSIgZG9pbmcgdGhhdD8gIElmIHlvdSBzdXBwb3J0IE5VTUEsIHRoZW4geW91IGFyZSBub3Qg
YSBtaW5pbWFsDQpjb25maWcgZm9yIGEgdGFibGV0IG9yIGxhcHRvcC4NCg0KSWYgeW91IHdhbnQg
YSBzeW1ib2wgdGhhdCBoYXMgYSBzdHJvbmdlciBjb3JyZWxhdGlvbiB0byBoaWdoIGVuZCBYZW9u
IGZlYXR1cmVzDQp0aGVuIHBlcmhhcHMgTUVNT1JZX0ZBSUxVUkU/DQoNCi1Ub255DQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
