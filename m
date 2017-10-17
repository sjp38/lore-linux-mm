Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B52476B0253
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 07:29:09 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b6so41997pff.18
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 04:29:09 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id n10si5983229plk.101.2017.10.17.04.29.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Oct 2017 04:29:08 -0700 (PDT)
From: "Liuwenliang (Lamb)" <liuwenliang@huawei.com>
Subject: Re: [PATCH 04/11] Define the virtual space of KASan's shadow region
Date: Tue, 17 Oct 2017 11:27:19 +0000
Message-ID: <B8AC3E80E903784988AB3003E3E97330C005CAC2@dggemm510-mbx.china.huawei.com>
References: <20171011082227.20546-5-liuwenliang@huawei.com>
 <201710141957.mbxeZJHB%fengguang.wu@intel.com>
 <B8AC3E80E903784988AB3003E3E97330C005B9BF@dggemm510-mbx.china.huawei.com>
 <CAKv+Gu98M9PZk3qm0PYC8nQ3zMvLZmNmOn4=hNdFE7NTBuHbgg@mail.gmail.com>
In-Reply-To: <CAKv+Gu98M9PZk3qm0PYC8nQ3zMvLZmNmOn4=hNdFE7NTBuHbgg@mail.gmail.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: kbuild test robot <lkp@intel.com>, "kbuild-all@01.org" <kbuild-all@01.org>, "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, "labbott@redhat.com" <labbott@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "cdall@linaro.org" <cdall@linaro.org>, "marc.zyngier@arm.com" <marc.zyngier@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "mingo@kernel.org" <mingo@kernel.org>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jiazhenghua <jiazhenghua@huawei.com>, Dailei <dylix.dailei@huawei.com>, Zengweilin <zengweilin@huawei.com>, Heshaoliang <heshaoliang@huawei.com>

T24gMTAvMTcvMjAxNyAxMjo0MCBBTSwgQWJib3R0IExpdSB3cm90ZToNCj4gQXJkIEJpZXNoZXV2
ZWwgW2FyZC5iaWVzaGV1dmVsQGxpbmFyby5vcmddIHdyb3RlDQo+VGhpcyBpcyB1bm5lY2Vzc2Fy
eToNCj4NCj5sZHIgcjEsID1UQVNLX1NJWkUNCj4NCj53aWxsIGJlIGNvbnZlcnRlZCB0byBhIG1v
diBpbnN0cnVjdGlvbiBieSB0aGUgYXNzZW1ibGVyIGlmIHRoZSB2YWx1ZSBvZiBUQVNLX1NJWkUg
Zml0cyBpdHMgMTItYml0IGltbWVkaWF0ZSBmaWVsZC4NCj4NCj5TbyBwbGVhc2UgcmVtb3ZlIHRo
ZSB3aG9sZSAjaWZkZWYsIGFuZCBqdXN0IHVzZSBsZHIgcjEsID14eHgNCg0KVGhhbmtzIGZvciB5
b3VyIHJldmlldy4gDQoNClRoZSBhc3NlbWJsZXIgb24gbXkgY29tcHV0ZXIgZG9uJ3QgY29udmVy
dCBsZHIgcjEsPXh4eCBpbnRvIG1vdiBpbnN0cnVjdGlvbi4gSGVyZSBpcyB0aGUgb2JqZHVtcCBm
b3Igdm1saW51eDoNCg0KYzBhM2IxMDAgPF9faXJxX3N2Yz46DQpjMGEzYjEwMDogICAgICAgZTI0
ZGQwNGMgICAgICAgIHN1YiAgICAgc3AsIHNwLCAjNzYgICAgIDsgMHg0Yw0KYzBhM2IxMDQ6ICAg
ICAgIGUzMWQwMDA0ICAgICAgICB0c3QgICAgIHNwLCAjNA0KYzBhM2IxMDg6ICAgICAgIDAyNGRk
MDA0ICAgICAgICBzdWJlcSAgIHNwLCBzcCwgIzQNCmMwYTNiMTBjOiAgICAgICBlODhkMWZmZSAg
ICAgICAgc3RtICAgICBzcCwge3IxLCByMiwgcjMsIHI0LCByNSwgcjYsIHI3LCByOCwgcjksIHNs
LCBmcCwgaXB9DQpjMGEzYjExMDogICAgICAgZTg5MDAwMzggICAgICAgIGxkbSAgICAgcjAsIHty
MywgcjQsIHI1fQ0KYzBhM2IxMTQ6ICAgICAgIGUyOGQ3MDMwICAgICAgICBhZGQgICAgIHI3LCBz
cCwgIzQ4ICAgICA7IDB4MzANCmMwYTNiMTE4OiAgICAgICBlM2UwNjAwMCAgICAgICAgbXZuICAg
ICByNiwgIzANCmMwYTNiMTFjOiAgICAgICBlMjhkMjA0YyAgICAgICAgYWRkICAgICByMiwgc3As
ICM3NiAgICAgOyAweDRjDQpjMGEzYjEyMDogICAgICAgMDI4MjIwMDQgICAgICAgIGFkZGVxICAg
cjIsIHIyLCAjNA0KYzBhM2IxMjQ6ICAgICAgIGU1MmQzMDA0ICAgICAgICBwdXNoICAgIHtyM30g
ICAgICAgICAgICA7IChzdHIgcjMsIFtzcCwgIy00XSEpDQpjMGEzYjEyODogICAgICAgZTFhMDMw
MGUgICAgICAgIG1vdiAgICAgcjMsIGxyDQpjMGEzYjEyYzogICAgICAgZTg4NzAwN2MgICAgICAg
IHN0bSAgICAgcjcsIHtyMiwgcjMsIHI0LCByNSwgcjZ9DQpjMGEzYjEzMDogICAgICAgZTFhMDk3
MmQgICAgICAgIGxzciAgICAgcjksIHNwLCAjMTQNCmMwYTNiMTM0OiAgICAgICBlMWEwOTcwOSAg
ICAgICAgbHNsICAgICByOSwgcjksICMxNA0KYzBhM2IxMzg6ICAgICAgIGU1OTkwMDA4ICAgICAg
ICBsZHIgICAgIHIwLCBbcjksICM4XQ0KLS0tYzBhM2IxM2M6ICAgICAgIGU1OWYxMDU0ICAgICAg
ICBsZHIgICAgIHIxLCBbcGMsICM4NF0gICA7IGMwYTNiMTk4IDxfX2lycV9zdmMrMHg5OD4gIC8v
bGRyIHIxLCA9VEFTS19TSVpFDQpjMGEzYjE0MDogICAgICAgZTU4OTEwMDggICAgICAgIHN0ciAg
ICAgcjEsIFtyOSwgIzhdDQpjMGEzYjE0NDogICAgICAgZTU4ZDAwNGMgICAgICAgIHN0ciAgICAg
cjAsIFtzcCwgIzc2XSAgIDsgMHg0Yw0KYzBhM2IxNDg6ICAgICAgIGVlMTMwZjEwICAgICAgICBt
cmMgICAgIDE1LCAwLCByMCwgY3IzLCBjcjAsIHswfQ0KYzBhM2IxNGM6ICAgICAgIGU1OGQwMDQ4
ICAgICAgICBzdHIgICAgIHIwLCBbc3AsICM3Ml0gICA7IDB4NDgNCmMwYTNiMTUwOiAgICAgICBl
M2EwMDA1MSAgICAgICAgbW92ICAgICByMCwgIzgxIDsgMHg1MQ0KYzBhM2IxNTQ6ICAgICAgIGVl
MDMwZjEwICAgICAgICBtY3IgICAgIDE1LCAwLCByMCwgY3IzLCBjcjAsIHswfQ0KLS0tYzBhM2Ix
NTg6ICAgICAgIGU1OWYxMDNjICAgICAgICBsZHIgICAgIHIxLCBbcGMsICM2MF0gICA7IGMwYTNi
MTljIDxfX2lycV9zdmMrMHg5Yz4gIC8vb3JnaW5hbCBpcnFfc3ZjIGFsc28gdXNlZCBzYW1lIGlu
c3RydWN0aW9uDQpjMGEzYjE1YzogICAgICAgZTFhMDAwMGQgICAgICAgIG1vdiAgICAgcjAsIHNw
DQpjMGEzYjE2MDogICAgICAgZTI4ZmUwMDAgICAgICAgIGFkZCAgICAgbHIsIHBjLCAjMA0KYzBh
M2IxNjQ6ICAgICAgIGU1OTFmMDAwICAgICAgICBsZHIgICAgIHBjLCBbcjFdDQpjMGEzYjE2ODog
ICAgICAgZTU5OTgwMDQgICAgICAgIGxkciAgICAgcjgsIFtyOSwgIzRdDQpjMGEzYjE2YzogICAg
ICAgZTU5OTAwMDAgICAgICAgIGxkciAgICAgcjAsIFtyOV0NCmMwYTNiMTcwOiAgICAgICBlMzM4
MDAwMCAgICAgICAgdGVxICAgICByOCwgIzANCmMwYTNiMTc0OiAgICAgICAxM2EwMDAwMCAgICAg
ICAgbW92bmUgICByMCwgIzANCmMwYTNiMTc4OiAgICAgICBlMzEwMDAwMiAgICAgICAgdHN0ICAg
ICByMCwgIzINCmMwYTNiMTdjOiAgICAgICAxYjAwMDAwNyAgICAgICAgYmxuZSAgICBjMGEzYjFh
MCA8c3ZjX3ByZWVtcHQ+DQpjMGEzYjE4MDogICAgICAgZTU5ZDEwNGMgICAgICAgIGxkciAgICAg
cjEsIFtzcCwgIzc2XSAgIDsgMHg0Yw0KYzBhM2IxODQ6ICAgICAgIGU1OWQwMDQ4ICAgICAgICBs
ZHIgICAgIHIwLCBbc3AsICM3Ml0gICA7IDB4NDgNCmMwYTNiMTg4OiAgICAgICBlZTAzMGYxMCAg
ICAgICAgbWNyICAgICAxNSwgMCwgcjAsIGNyMywgY3IwLCB7MH0NCmMwYTNiMThjOiAgICAgICBl
NTg5MTAwOCAgICAgICAgc3RyICAgICByMSwgW3I5LCAjOF0NCmMwYTNiMTkwOiAgICAgICBlMTZm
ZjAwNSAgICAgICAgbXNyICAgICBTUFNSX2ZzeGMsIHI1DQpjMGEzYjE5NDogICAgICAgZThkZGZm
ZmYgICAgICAgIGxkbSAgICAgc3AsIHtyMCwgcjEsIHIyLCByMywgcjQsIHI1LCByNiwgcjcsIHI4
LCByOSwgc2wsIGZwLCBpcCwgc3AsIGxyLCBwY31eDQotLS1jMGEzYjE5ODogICAgICAgYjZlMDAw
MDAgICAgICAgIC53b3JkICAgMHhiNmUwMDAwMCAgIC8vVEFTS19TSVpFOjB4YjZlMDAwMDANCmMw
YTNiMTljOiAgICAgICBjMGNjY2NmMCAgICAgICAgLndvcmQgICAweGMwY2NjY2YwDQoNCg0KDQpF
dmVuICJsZHIgcjEsID1UQVNLX1NJWkUiICB3b24ndCBiZSBjb252ZXJ0ZWQgdG8gYSBtb3YgaW5z
dHJ1Y3Rpb24gYnkgc29tZSBhc3NlbWJsZXIsIEkgYWxzbyB0aGluayBpdCBpcyBiZXR0ZXINCnRv
IHJlbW92ZSB0aGUgd2hvbGUgI2lmZGVmIGJlY2F1c2UgdGhlIGluZmx1ZW5jZSBvZiBwZXJmb3Jt
YW5jZSBieSBsZHIgaXMgdmVyeSBsaW1pdGVkLiANCg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
