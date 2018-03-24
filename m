Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 254116B0003
	for <linux-mm@kvack.org>; Sat, 24 Mar 2018 08:24:31 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id q6so7193471pgv.12
        for <linux-mm@kvack.org>; Sat, 24 Mar 2018 05:24:31 -0700 (PDT)
Received: from huawei.com (szxga01-in.huawei.com. [45.249.212.187])
        by mx.google.com with ESMTPS id f3-v6si7170248pld.687.2018.03.24.05.24.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Mar 2018 05:24:29 -0700 (PDT)
From: "Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com>
Subject: Re: [PATCH v2 0/7] KASan for arm
Date: Sat, 24 Mar 2018 12:24:22 +0000
Message-ID: <B8AC3E80E903784988AB3003E3E97330C00774B7@dggemm510-mbs.china.huawei.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "marc.zyngier@arm.com" <marc.zyngier@arm.com>, "kstewart@linuxfoundation.org" <kstewart@linuxfoundation.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "glider@google.com" <glider@google.com>, "christoffer.dall@linaro.org" <christoffer.dall@linaro.org>, "linux@rasmusvillemoes.dk" <linux@rasmusvillemoes.dk>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "pombredanne@nexb.com" <pombredanne@nexb.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "nicolas.pitre@linaro.org" <nicolas.pitre@linaro.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "dhowells@redhat.com" <dhowells@redhat.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "geert@linux-m68k.org" <geert@linux-m68k.org>, "tixy@linaro.org" <tixy@linaro.org>, "mark.rutland@arm.com" <mark.rutland@arm.com>, "james.morse@arm.com" <james.morse@arm.com>, "zhichao.huang@linaro.org" <zhichao.huang@linaro.org>, "jinb.park7@gmail.com" <jinb.park7@gmail.com>, "labbott@redhat.com" <labbott@redhat.com>, "philip@cog.systems" <philip@cog.systems>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "kvmarm@lists.cs.columbia.edu" <kvmarm@lists.cs.columbia.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>

T24gTW9uLCBNYXIgMTksIDIwMTggYXQgMTY6NDQgLCBEbWl0cnkgVnl1a292IHdyb3RlOg0KPkhp
IEFiYm90dCwNCj4NCj5JJ3ZlIHNraW1tZWQgdGhyb3VnaCB0aGUgY2hhbmdlcyBhbmQgdGhleSBn
ZW5lcmFsbHkgbG9vayBnb29kIHRvIG1lLiBJDQo+YW0gbm90IGFuIGV4cGVjdCBpbiBhcm0sIHNv
IEkgZGlkIG5vdCBsb29rIHRvbyBjbG9zZWx5IG9uIHRoZXNlIHBhcnRzDQo+KHdoaWNoIGlzIGFj
dHVhbGx5IG1vc3Qgb2YgdGhlIGNoYW5nZXMpLg0KPg0KPkZXSVcNCj5BY2tlZC1ieTogRG1pdHJ5
IFZ5dWtvdiA8ZHZ5dWtvdkBnb29nbGUuY29tPg0KPg0KPlBsZWFzZSBhbHNvIHVwZGF0ZSBzZXQg
b2Ygc3VwcG9ydGVkIGFyY2hzIGF0IHRoZSB0b3Agb2YNCj5Eb2N1bWVudGF0aW9uL2Rldi10b29s
cy9rYXNhbi5yc3QNCj4NCj5UaGFua3MgZm9yIHdvcmtpbmcgb24gdXBzdHJlYW1pbmcgdGhpcyEN
Cg0KVGhhbmtzIGZvciB5b3VyIHJldmlldy4NCkkgd2lsbCB1cGRhdGUgc2V0IG9mIHN1cHBvcnRl
ZCBhcmNocyBqdXN0IGxpa2UgdGhpczoNCmRpZmYgLS1naXQgYS9Eb2N1bWVudGF0aW9uL2Rldi10
b29scy9rYXNhbi5yc3QgYi9Eb2N1bWVudGF0aW9uL2Rldi10b29scy9rYXNhbi5yc3QNCmluZGV4
IGY3YTE4ZjIuLmQ5MjEyMGQgMTAwNjQ0DQotLS0gYS9Eb2N1bWVudGF0aW9uL2Rldi10b29scy9r
YXNhbi5yc3QNCisrKyBiL0RvY3VtZW50YXRpb24vZGV2LXRvb2xzL2thc2FuLnJzdA0KQEAgLTEy
LDcgKzEyLDcgQEAgS0FTQU4gdXNlcyBjb21waWxlLXRpbWUgaW5zdHJ1bWVudGF0aW9uIGZvciBj
aGVja2luZyBldmVyeSBtZW1vcnkgYWNjZXNzLA0KIHRoZXJlZm9yZSB5b3Ugd2lsbCBuZWVkIGEg
R0NDIHZlcnNpb24gNC45LjIgb3IgbGF0ZXIuIEdDQyA1LjAgb3IgbGF0ZXIgaXMNCiByZXF1aXJl
ZCBmb3IgZGV0ZWN0aW9uIG9mIG91dC1vZi1ib3VuZHMgYWNjZXNzZXMgdG8gc3RhY2sgb3IgZ2xv
YmFsIHZhcmlhYmxlcy4NCg0KLUN1cnJlbnRseSBLQVNBTiBpcyBzdXBwb3J0ZWQgb25seSBmb3Ig
dGhlIHg4Nl82NCBhbmQgYXJtNjQgYXJjaGl0ZWN0dXJlcy4NCitDdXJyZW50bHkgS0FTQU4gaXMg
c3VwcG9ydGVkIG9ubHkgZm9yIHRoZSB4ODZfNjQsIGFybTY0IGFuZCBhcm0gYXJjaGl0ZWN0dXJl
cy4NCg0K
