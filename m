Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2DF0F6B000C
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 10:27:31 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 60-v6so3297657plf.19
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 07:27:31 -0700 (PDT)
Received: from g2t2353.austin.hpe.com (g2t2353.austin.hpe.com. [15.233.44.26])
        by mx.google.com with ESMTPS id t64si3516089pgc.584.2018.03.15.07.27.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 07:27:29 -0700 (PDT)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: [PATCH v2 1/2] mm/vmalloc: Add interfaces to free unmapped page
 table
Date: Thu, 15 Mar 2018 14:27:10 +0000
Message-ID: <1521124026.2693.141.camel@hpe.com>
References: <20180314180155.19492-1-toshi.kani@hpe.com>
	 <20180314180155.19492-2-toshi.kani@hpe.com>
	 <20180314153835.68e75da3fdc18b27ad0e290c@linux-foundation.org>
In-Reply-To: <20180314153835.68e75da3fdc18b27ad0e290c@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <4706C1564229854FA532B303D04DE221@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "bp@suse.de" <bp@suse.de>, "tglx@linutronix.de" <tglx@linutronix.de>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "willy@infradead.org" <willy@infradead.org>, "wxf.wang@hisilicon.com" <wxf.wang@hisilicon.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "will.deacon@arm.com" <will.deacon@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "Hocko, Michal" <mhocko@suse.com>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

T24gV2VkLCAyMDE4LTAzLTE0IGF0IDE1OjM4IC0wNzAwLCBBbmRyZXcgTW9ydG9uIHdyb3RlOg0K
PiBPbiBXZWQsIDE0IE1hciAyMDE4IDEyOjAxOjU0IC0wNjAwIFRvc2hpIEthbmkgPHRvc2hpLmth
bmlAaHBlLmNvbT4gd3JvdGU6DQogOg0KPiANCj4gd2hvb3BzLg0KPiANCj4gLS0tIGEvaW5jbHVk
ZS9hc20tZ2VuZXJpYy9wZ3RhYmxlLmh+bW0tdm1hbGxvYy1hZGQtaW50ZXJmYWNlcy10by1mcmVl
LXVubWFwcGVkLXBhZ2UtdGFibGUtZml4DQo+ICsrKyBhL2luY2x1ZGUvYXNtLWdlbmVyaWMvcGd0
YWJsZS5oDQo+IEBAIC0xMDE0LDcgKzEwMTQsNyBAQCBzdGF0aWMgaW5saW5lIGludCBwdWRfZnJl
ZV9wbWRfcGFnZShwdWRfDQo+ICB7DQo+ICAJcmV0dXJuIDA7DQo+ICB9DQo+IC1zdGF0aWMgaW5s
aW5lIGludCBwbWRfZnJlZV9wdGVfcGFnZShwdWRfdCAqcG1kKQ0KPiArc3RhdGljIGlubGluZSBp
bnQgcG1kX2ZyZWVfcHRlX3BhZ2UocG1kX3QgKnBtZCkNCj4gIHsNCj4gIAlyZXR1cm4gMDsNCj4g
IH0NCg0KVGhhbmtzIEFuZHJldyBmb3IgY2F0Y2hpbmcgdGhpcyEhDQotVG9zaGkNCg==
