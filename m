Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1B9916B0010
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 21:11:00 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id f4so3173446plo.11
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 18:11:00 -0800 (PST)
Received: from huawei.com (szxga01-in.huawei.com. [45.249.212.187])
        by mx.google.com with ESMTPS id y67si809682pgb.728.2018.02.22.18.10.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 18:10:59 -0800 (PST)
From: "Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com>
Subject: Re: [PATCH 00/11] KASan for arm
Date: Fri, 23 Feb 2018 02:10:52 +0000
Message-ID: <B8AC3E80E903784988AB3003E3E97330C0072D47@dggemm510-mbs.china.huawei.com>
References: <20171011082227.20546-1-liuwenliang@huawei.com>
 <09f86876-2247-1d2c-b195-76d8b34d0aff@gmail.com>
In-Reply-To: <09f86876-2247-1d2c-b195-76d8b34d0aff@gmail.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Fainelli <f.fainelli@gmail.com>, "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "labbott@redhat.com" <labbott@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "cdall@linaro.org" <cdall@linaro.org>, "marc.zyngier@arm.com" <marc.zyngier@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "mingo@kernel.org" <mingo@kernel.org>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>
Cc: "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

T24gMjAxOC8yLzE0ICAyOjQxIEFNLCBGbG9yaWFuIEZhaW5lbGxpIFtmLmZhaW5lbGxpQGdtYWls
LmNvbV0gd3JvdGU6DQo+SGkgQWJib3R0LA0KPg0KPkFyZSB5b3UgcGxhbm5pbmcgb24gcGlja2lu
ZyB1cCB0aGVzZSBwYXRjaGVzIGFuZCBzZW5kaW5nIGEgc2Vjb25kDQo+dmVyc2lvbj8gSSB3b3Vs
ZCBiZSBtb3JlIHRoYW4gaGFwcHkgdG8gcHJvdmlkZSB0ZXN0IHJlc3VsdHMgb25jZSB5b3UNCj5o
YXZlIHNvbWV0aGluZywgdGhpcyBpcyB2ZXJ5IHVzZWZ1bCwgdGhhbmsgeW91IQ0KPi0tIA0KPkZs
b3JpYW4NCg0KSSdtIHNvcnJ5IHRvIHJlcGx5IHlvdSBzbyBsYXRlLiBJIGhhZCBhIGhvbGlkYXkg
b24gbGFzdCBmZXcgZGF5cy4NClllcywgSSB3aWxsIHNlbmQgdGhlIHNlY29uZCB2ZXJzaW9uLCBt
YXliZSBvbiBuZXh0IHR3byB3ZWVrcy4NCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
