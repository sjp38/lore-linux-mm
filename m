Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0C63C6B0253
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 09:07:31 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p87so1260206pfj.21
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 06:07:31 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [45.249.212.187])
        by mx.google.com with ESMTPS id u127si5433651pgc.803.2017.10.17.06.07.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Oct 2017 06:07:29 -0700 (PDT)
From: "Liuwenliang (Lamb)" <liuwenliang@huawei.com>
Subject: Re:  [PATCH 04/11] Define the virtual space of KASan's shadow region
Date: Tue, 17 Oct 2017 13:02:06 +0000
Message-ID: <B8AC3E80E903784988AB3003E3E97330C005CB08@dggemm510-mbx.china.huawei.com>
References: <20171011082227.20546-5-liuwenliang@huawei.com>
 <201710141957.mbxeZJHB%fengguang.wu@intel.com>
 <B8AC3E80E903784988AB3003E3E97330C005B9BF@dggemm510-mbx.china.huawei.com>
 <CAKv+Gu98M9PZk3qm0PYC8nQ3zMvLZmNmOn4=hNdFE7NTBuHbgg@mail.gmail.com>
 <B8AC3E80E903784988AB3003E3E97330C005CAC2@dggemm510-mbx.china.huawei.com>
 <CAKv+Gu-+yOyAC4R_JNNy7NqWiSQ=HwfR=uTr1Ntt=2cDzAZ5nw@mail.gmail.com>
In-Reply-To: <CAKv+Gu-+yOyAC4R_JNNy7NqWiSQ=HwfR=uTr1Ntt=2cDzAZ5nw@mail.gmail.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: kbuild test robot <lkp@intel.com>, "kbuild-all@01.org" <kbuild-all@01.org>, "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, "labbott@redhat.com" <labbott@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "cdall@linaro.org" <cdall@linaro.org>, "marc.zyngier@arm.com" <marc.zyngier@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "mingo@kernel.org" <mingo@kernel.org>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jiazhenghua <jiazhenghua@huawei.com>, Dailei <dylix.dailei@huawei.com>, Zengweilin <zengweilin@huawei.com>, Heshaoliang <heshaoliang@huawei.com>

T24gMTAvMTcvMjAxNyA4OjQ1IFBNLCBBYmJvdHQgTGl1IHdyb3RlOg0KPldoYXQgSSBzYWlkIHdh
cw0KPg0KPidpZiB0aGUgdmFsdWUgb2YgVEFTS19TSVpFIGZpdHMgaXRzIDEyLWJpdCBpbW1lZGlh
dGUgZmllbGQnDQo+DQo+YW5kIHlvdXIgdmFsdWUgb2YgVEFTS19TSVpFIGlzIDB4YjZlMDAwMDAs
IHdoaWNoIGNhbm5vdCBiZSBkZWNvbXBvc2VkIGluIHRoZSByaWdodCB3YXkuDQo+DQo+SWYgeW91
IGJ1aWxkIHdpdGggS0FTQU4gZGlzYWJsZWQsIGl0IHdpbGwgZ2VuZXJhdGUgYSBtb3YgaW5zdHJ1
Y3Rpb24gaW5zdGVhZC4NCg0KVGhhbmtzIGZvciB5b3VyIGV4cGxhaW4uIEkgdW5kZXJzdGFuZCBu
b3cuICBJIGhhcyB0ZXN0ZWQgYW5kIHRoZSB0ZXN0aW5nIHJlc3VsdCBwcm92ZXMgdGhhdCB3aGF0
IA0KeW91IHNhaWQgaXMgcmlnaHQuIA0KDQpIZXJlIGlzIHRlc3QgbG9nOg0KYzAxMGU5ZTAgPF9f
aXJxX3N2Yz46DQpjMDEwZTllMDogICAgICAgZTI0ZGQwNGMgICAgICAgIHN1YiAgICAgc3AsIHNw
LCAjNzYgICAgIDsgMHg0Yw0KYzAxMGU5ZTQ6ICAgICAgIGUzMWQwMDA0ICAgICAgICB0c3QgICAg
IHNwLCAjNA0KYzAxMGU5ZTg6ICAgICAgIDAyNGRkMDA0ICAgICAgICBzdWJlcSAgIHNwLCBzcCwg
IzQNCmMwMTBlOWVjOiAgICAgICBlODhkMWZmZSAgICAgICAgc3RtICAgICBzcCwge3IxLCByMiwg
cjMsIHI0LCByNSwgcjYsIHI3LCByOCwgcjksIHNsLCBmcCwgaXB9DQpjMDEwZTlmMDogICAgICAg
ZTg5MDAwMzggICAgICAgIGxkbSAgICAgcjAsIHtyMywgcjQsIHI1fQ0KYzAxMGU5ZjQ6ICAgICAg
IGUyOGQ3MDMwICAgICAgICBhZGQgICAgIHI3LCBzcCwgIzQ4ICAgICA7IDB4MzANCmMwMTBlOWY4
OiAgICAgICBlM2UwNjAwMCAgICAgICAgbXZuICAgICByNiwgIzANCmMwMTBlOWZjOiAgICAgICBl
MjhkMjA0YyAgICAgICAgYWRkICAgICByMiwgc3AsICM3NiAgICAgOyAweDRjDQpjMDEwZWEwMDog
ICAgICAgMDI4MjIwMDQgICAgICAgIGFkZGVxICAgcjIsIHIyLCAjNA0KYzAxMGVhMDQ6ICAgICAg
IGU1MmQzMDA0ICAgICAgICBwdXNoICAgIHtyM30gICAgICAgICAgICA7IChzdHIgcjMsIFtzcCwg
Iy00XSEpDQpjMDEwZWEwODogICAgICAgZTFhMDMwMGUgICAgICAgIG1vdiAgICAgcjMsIGxyDQpj
MDEwZWEwYzogICAgICAgZTg4NzAwN2MgICAgICAgIHN0bSAgICAgcjcsIHtyMiwgcjMsIHI0LCBy
NSwgcjZ9DQpjMDEwZWExMDogICAgICAgZTFhMDk3MmQgICAgICAgIGxzciAgICAgcjksIHNwLCAj
MTQNCmMwMTBlYTE0OiAgICAgICBlMWEwOTcwOSAgICAgICAgbHNsICAgICByOSwgcjksICMxNA0K
YzAxMGVhMTg6ICAgICAgIGU1OTkwMDA4ICAgICAgICBsZHIgICAgIHIwLCBbcjksICM4XQ0KYzAx
MGVhMWM6ICAgICAgIGUzYTAxNGJmICAgICAgICBtb3YgICAgIHIxLCAjLTEwOTA1MTkwNDAgICAg
ICAgIDsgMHhiZjAwMDAwMCAgLy8gbGRyIHIxLD0weGJmMDAwMDAwDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
