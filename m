Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6DD346B0038
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 20:42:17 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id h6so508286oia.17
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 17:42:17 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id a22si767209oib.192.2017.11.16.17.42.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Nov 2017 17:42:15 -0800 (PST)
From: "Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com>
Subject: =?utf-8?B?562U5aSNOiBbUEFUQ0ggMDEvMTFdIEluaXRpYWxpemUgdGhlIG1hcHBpbmcg?=
 =?utf-8?Q?of_KASan_shadow_memory?=
Date: Fri, 17 Nov 2017 01:39:40 +0000
Message-ID: <B8AC3E80E903784988AB3003E3E97330C0063786@dggemm510-mbs.china.huawei.com>
References: <20171011082227.20546-1-liuwenliang@huawei.com>
	<20171011082227.20546-2-liuwenliang@huawei.com>
	<227e2c6e-f479-849d-8942-1d5ff4ccd440@arm.com>
	<B8AC3E80E903784988AB3003E3E97330C0063172@dggemm510-mbs.china.huawei.com>
	<8e959f69-a578-793b-6c32-18b5b0cd08c2@arm.com>
	<B8AC3E80E903784988AB3003E3E97330C0063545@dggemm510-mbs.china.huawei.com>
	<87a7znsubp.fsf@on-the-bus.cambridge.arm.com>
	<B8AC3E80E903784988AB3003E3E97330C0063587@dggemm510-mbs.china.huawei.com>
	<bbf43f92-3d0c-940d-b66b-68f92eb9b282@arm.com>
	<B8AC3E80E903784988AB3003E3E97330C00635F3@dggemm510-mbs.china.huawei.com>
	<87po8ir1kg.fsf@on-the-bus.cambridge.arm.com>
	<B8AC3E80E903784988AB3003E3E97330C006371B@dggemm510-mbs.china.huawei.com>
 <87375eqobb.fsf@on-the-bus.cambridge.arm.com>
In-Reply-To: <87375eqobb.fsf@on-the-bus.cambridge.arm.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Zyngier <marc.zyngier@arm.com>
Cc: "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, "labbott@redhat.com" <labbott@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "cdall@linaro.org" <cdall@linaro.org>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "mingo@kernel.org" <mingo@kernel.org>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jiazhenghua <jiazhenghua@huawei.com>, Dailei <dylix.dailei@huawei.com>, Zengweilin <zengweilin@huawei.com>, Heshaoliang <heshaoliang@huawei.com>

DQpPbiAxNi8xMS8xNyAgMjI6NDEgTWFyYyBaeW5naWVyIFttYWlsdG86bWFyYy56eW5naWVyQGFy
bS5jb21dIHdyb3RlOg0KPi0gSWYgdGhlIENQVSBzdXBwb3J0cyBMUEFFLCB0aGVuIGJvdGggMzIg
YW5kIDY0Yml0IGFjY2Vzc29ycyB3b3JrDQoNCg0KSSBkb24ndCBob3cgMzJiaXQgYWNjZXNzb3Ig
Y2FuIHdvcmsgb24gQ1BVIHN1cHBvcnRpbmcgTFBBRSwgZ2l2ZSBtZSB5b3VyIHNvbHV0aW9uLg0K
DQpUaGFua3MuDQoNCg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
