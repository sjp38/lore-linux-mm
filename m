Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A53E76B0009
	for <linux-mm@kvack.org>; Sun, 25 Mar 2018 21:13:50 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id g22so8663257pgv.16
        for <linux-mm@kvack.org>; Sun, 25 Mar 2018 18:13:50 -0700 (PDT)
Received: from huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id 69-v6si13782777pla.390.2018.03.25.18.13.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Mar 2018 18:13:49 -0700 (PDT)
From: "Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com>
Subject: Re: [PATCH v2 0/7] KASan for arm
Date: Mon, 26 Mar 2018 01:13:45 +0000
Message-ID: <B8AC3E80E903784988AB3003E3E97330C0077579@dggemm510-mbs.china.huawei.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Stanley <joel@jms.id.au>
Cc: Russell King <linux@armlinux.org.uk>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, Marc Zyngier <marc.zyngier@arm.com>, "kstewart@linuxfoundation.org" <kstewart@linuxfoundation.org>, Greg KH <gregkh@linuxfoundation.org>, Florian Fainelli <f.fainelli@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Afzal Mohammed <afzal.mohd.ma@gmail.com>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, Christoffer Dall <christoffer.dall@linaro.org>, "linux@rasmusvillemoes.dk" <linux@rasmusvillemoes.dk>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, Philippe Ombredanne <pombredanne@nexb.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "nicolas.pitre@linaro.org" <nicolas.pitre@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "dhowells@redhat.com" <dhowells@redhat.com>, Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, "Jon Medhurst (Tixy)" <tixy@linaro.org>, Mark Rutland <mark.rutland@arm.com>, "james.morse@arm.com" <james.morse@arm.com>, "zhichao.huang@linaro.org" <zhichao.huang@linaro.org>, "jinb.park7@gmail.com" <jinb.park7@gmail.com>, "labbott@redhat.com" <labbott@redhat.com>, "philip@cog.systems" <philip@cog.systems>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, Linux
 ARM <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "kvmarm@lists.cs.columbia.edu" <kvmarm@lists.cs.columbia.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>

T24gMjYgTWFyY2ggMjAxOCBhdCA3OjU5LCBKb2VsIFN0YW5sZXkgIDxqb2VsLnN0YW5AZ21haWwu
Y29tPiB3cm90ZToNCj5PbiAxOCBNYXJjaCAyMDE4IGF0IDIzOjIzLCBBYmJvdHQgTGl1IDxsaXV3
ZW5saWFuZ0BodWF3ZWkuY29tPiB3cm90ZToNCj4NCj4+ICAgIFRoZXNlIHBhdGNoZXMgYWRkIGFy
Y2ggc3BlY2lmaWMgY29kZSBmb3Iga2VybmVsIGFkZHJlc3Mgc2FuaXRpemVyIA0KPj4gKHNlZSBE
b2N1bWVudGF0aW9uL2thc2FuLnR4dCkuDQo+DQo+VGhhbmtzIGZvciBpbXBsZW1lbnRpbmcgdGhp
cy4gSSBnYXZlIHRoZSBzZXJpZXMgYSBzcGluIG9uIGFuIEFTUEVFRA0KPmFzdDI1MDAgKEFSTXY1
KSBzeXN0ZW0gd2l0aCBhc3BlZWRfZzVfZGVmY29uZmlnLg0KPg0KPkl0IGZvdW5kIGEgYnVnIGlu
IHRoZSBOQ1NJIGNvZGUgKGh0dHBzOi8vZ2l0aHViLmNvbS9vcGVuYm1jL2xpbnV4L2lzc3Vlcy8x
NDYpLg0KPg0KPlRlc3RlZC1ieTogSm9lbCBTdGFubGV5IDxqb2VsQGptcy5pZC5hdT4NCj4NCj5D
aGVlcnMsDQo+DQo+Sm9lbA0KDQpUaGFua3MgZm9yIHlvdXIgdGVzdC4NCg==
