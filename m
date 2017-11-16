Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B961B280254
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 22:08:39 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id i15so7181955pfa.15
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 19:08:39 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id h13si98148pgp.334.2017.11.15.19.08.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Nov 2017 19:08:38 -0800 (PST)
From: "Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com>
Subject: Re: [PATCH 01/11] Initialize the mapping of KASan shadow memory
Date: Thu, 16 Nov 2017 03:07:54 +0000
Message-ID: <B8AC3E80E903784988AB3003E3E97330C00635F3@dggemm510-mbs.china.huawei.com>
References: <20171011082227.20546-1-liuwenliang@huawei.com>
 <20171011082227.20546-2-liuwenliang@huawei.com>
 <227e2c6e-f479-849d-8942-1d5ff4ccd440@arm.com>
 <B8AC3E80E903784988AB3003E3E97330C0063172@dggemm510-mbs.china.huawei.com>
 <8e959f69-a578-793b-6c32-18b5b0cd08c2@arm.com>
 <B8AC3E80E903784988AB3003E3E97330C0063545@dggemm510-mbs.china.huawei.com>
 <87a7znsubp.fsf@on-the-bus.cambridge.arm.com>
 <B8AC3E80E903784988AB3003E3E97330C0063587@dggemm510-mbs.china.huawei.com>
 <bbf43f92-3d0c-940d-b66b-68f92eb9b282@arm.com>
In-Reply-To: <bbf43f92-3d0c-940d-b66b-68f92eb9b282@arm.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Zyngier <marc.zyngier@arm.com>
Cc: "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, "labbott@redhat.com" <labbott@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "cdall@linaro.org" <cdall@linaro.org>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "mingo@kernel.org" <mingo@kernel.org>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jiazhenghua <jiazhenghua@huawei.com>, Dailei <dylix.dailei@huawei.com>, Zengweilin <zengweilin@huawei.com>, Heshaoliang <heshaoliang@huawei.com>

DQo+T24gMTUvMTEvMTcgMTM6MTYsIExpdXdlbmxpYW5nIChBYmJvdHQgTGl1KSB3cm90ZToNCj4+
IE9uIDA5LzExLzE3ICAxODozNiBNYXJjIFp5bmdpZXIgW21haWx0bzptYXJjLnp5bmdpZXJAYXJt
LmNvbV0gd3JvdGU6DQo+Pj4gT24gV2VkLCBOb3YgMTUgMjAxNyBhdCAxMDoyMDowMiBhbSBHTVQs
ICJMaXV3ZW5saWFuZyAoQWJib3R0IExpdSkiIDxsaXV3ZW5saWFuZ0BodWF3ZWkuY29tPiB3cm90
ZToNCj4+Pj4gZGlmZiAtLWdpdCBhL2FyY2gvYXJtL2luY2x1ZGUvYXNtL2NwMTUuaCBiL2FyY2gv
YXJtL2luY2x1ZGUvYXNtL2NwMTUuaA0KPj4+PiBpbmRleCBkYmRiY2UxLi42ZGIxZjUxIDEwMDY0
NA0KPj4+PiAtLS0gYS9hcmNoL2FybS9pbmNsdWRlL2FzbS9jcDE1LmgNCj4+Pj4gKysrIGIvYXJj
aC9hcm0vaW5jbHVkZS9hc20vY3AxNS5oDQo+Pj4+IEBAIC02NCw2ICs2NCw0MyBAQA0KPj4+PiAg
I2RlZmluZSBfX3dyaXRlX3N5c3JlZyh2LCByLCB3LCBjLCB0KSAgYXNtIHZvbGF0aWxlKHcgIiAi
IGMgOiA6ICJyIiAoKHQpKHYpKSkNCj4+Pj4gICNkZWZpbmUgd3JpdGVfc3lzcmVnKHYsIC4uLikg
ICAgICAgICAgIF9fd3JpdGVfc3lzcmVnKHYsIF9fVkFfQVJHU19fKQ0KPj4+Pg0KPj4+PiArI2lm
ZGVmIENPTkZJR19BUk1fTFBBRQ0KPj4+PiArI2RlZmluZSBUVEJSMCAgICAgICAgICAgX19BQ0NF
U1NfQ1AxNV82NCgwLCBjMikNCj4+Pj4gKyNkZWZpbmUgVFRCUjEgICAgICAgICAgIF9fQUNDRVNT
X0NQMTVfNjQoMSwgYzIpDQo+Pj4+ICsjZGVmaW5lIFBBUiAgICAgICAgICAgICBfX0FDQ0VTU19D
UDE1XzY0KDAsIGM3KQ0KPj4+PiArI2Vsc2UNCj4+Pj4gKyNkZWZpbmUgVFRCUjAgICAgICAgICAg
IF9fQUNDRVNTX0NQMTUoYzIsIDAsIGMwLCAwKQ0KPj4+PiArI2RlZmluZSBUVEJSMSAgICAgICAg
ICAgX19BQ0NFU1NfQ1AxNShjMiwgMCwgYzAsIDEpDQo+Pj4+ICsjZGVmaW5lIFBBUiAgICAgICAg
ICAgICBfX0FDQ0VTU19DUDE1KGM3LCAwLCBjNCwgMCkNCj4+Pj4gKyNlbmRpZg0KPj4+IEFnYWlu
OiB0aGVyZSBpcyBubyBwb2ludCBpbiBub3QgaGF2aW5nIHRoZXNlIHJlZ2lzdGVyIGVuY29kaW5n
cw0KPj4+IGNvaGFiaXRpbmcuIFRoZXkgYXJlIGJvdGggcGVyZmVjdGx5IGRlZmluZWQgaW4gdGhl
IGFyY2hpdGVjdHVyZS4gSnVzdA0KPj4+IHN1ZmZpeCBvbmUgKG9yIGV2ZW4gYm90aCkgd2l0aCB0
aGVpciByZXNwZWN0aXZlIHNpemUsIG1ha2luZyBpdCBvYnZpb3VzDQo+Pj4gd2hpY2ggb25lIHlv
dSdyZSB0YWxraW5nIGFib3V0Lg0KPj4gDQo+PiBJIGFtIHNvcnJ5IHRoYXQgSSBkaWRuJ3QgcG9p
bnQgd2h5IEkgbmVlZCB0byBkZWZpbmUgVFRCUjAvIFRUQlIxL1BBUiBpbiB0byBkaWZmZXJlbnQg
d2F5DQo+PiBiZXR3ZWVuIENPTkZJR19BUk1fTFBBRSBhbmQgbm9uIENPTkZJR19BUk1fTFBBRS4N
Cj4+IFRoZSBmb2xsb3dpbmcgZGVzY3JpcHRpb24gaXMgdGhlIHJlYXNvbjoNCj4+IEhlcmUgaXMg
dGhlIGRlc2NyaXB0aW9uIGNvbWUgZnJvbSBEREkwNDA2QzJjX2FybV9hcmNoaXRlY3R1cmVfcmVm
ZXJlbmNlX21hbnVhbC5wZGY6DQo+Wy4uLl0NCj4NCj5Zb3UncmUgbWlzc2luZyB0aGUgcG9pbnQu
IFRUQlIwIGV4aXN0ZW5jZSBhcyBhIDY0Yml0IENQMTUgcmVnaXN0ZXIgaGFzDQo+bm90aGluZyB0
byBkbyB0aGUga2VybmVsIGJlaW5nIGNvbXBpbGVkIHdpdGggTFBBRSBvciBub3QuIEl0IGhhcw0K
PmV2ZXJ5dGhpbmcgdG8gZG8gd2l0aCB0aGUgSFcgc3VwcG9ydGluZyBMUEFFLCBhbmQgaXQgaXMg
dGhlIGtlcm5lbCdzIGpvYg0KPnRvIHVzZSB0aGUgcmlnaHQgYWNjZXNzb3IgZGVwZW5kaW5nIG9u
IGhvdyBpdCBpcyBjb21waWxlZC4gT24gYSBDUFUNCj5zdXBwb3J0aW5nIExQQUUsIGJvdGggVFRC
UjAgYWNjZXNzb3JzIGFyZSB2YWxpZC4gSXQgaXMgdGhlIGtlcm5lbCB0aGF0DQo+Y2hvb3NlcyB0
byB1c2Ugb25lIHJhdGhlciB0aGFuIHRoZSBvdGhlci4NCg0KVGhhbmtzIGZvciB5b3VyIHJldmll
dy4NCkkgZG9uJ3QgdGhpbmsgYm90aCBUVEJSMCBhY2Nlc3NvcnMoNjRiaXQgYWNjZXNzb3IgYW5k
IDMyYml0IGFjY2Vzc29yKSBhcmUgdmFsaWQgb24gYSBDUFUgc3VwcG9ydGluZw0KTFBBRSB3aGlj
aCB0aGUgTFBBRSBpcyBlbmFibGVkLiBIZXJlIGlzIHRoZSBkZXNjcmlwdGlvbiBjb21lIGZvcm0g
RERJMDQwNkMyY19hcm1fYXJjaGl0ZWN0dXJlX3JlZmVyZW5jZV9tYW51YWwucGRmDQooPUFSTcKu
IEFyY2hpdGVjdHVyZSBSZWZlcmVuY2UgTWFudWFsIEFSTXY3LUEgYW5kIEFSTXY3LVIgZWRpdGlv
bikgd2hpY2ggeW91IGNhbiBnZXQgdGhlIGRvY3VtZW50DQpieSBnb29nbGUgIkFSTcKuIEFyY2hp
dGVjdHVyZSBSZWZlcmVuY2UgTWFudWFsIEFSTXY3LUEgYW5kIEFSTXY3LVIgZWRpdGlvbiIuIA0K
DQo2NC1iaXQgVFRCUjAgYW5kIFRUQlIxIGZvcm1hdA0KVGhlIGJpdCBhc3NpZ25tZW50cyBmb3Ig
dGhlIDY0LWJpdCBpbXBsZW1lbnRhdGlvbnMgb2YgVFRCUjAgYW5kIFRUQlIxIGFyZSBpZGVudGlj
YWwsIGFuZCBhcmU6DQpCaXRzWzYzOjU2XSBVTksvU0JaUC4NCkFTSUQsIGJpdHNbNTU6NDhdOg0K
ICBBbiBBU0lEIGZvciB0aGUgdHJhbnNsYXRpb24gdGFibGUgYmFzZSBhZGRyZXNzLiBUaGUgVFRC
Q1IuQTEgZmllbGQgc2VsZWN0cyBlaXRoZXIgVFRCUjAuQVNJRA0Kb3IgVFRCUjEuQVNJRC4NCkJp
dHNbNDc6NDBdIFVOSy9TQlpQLg0KQkFERFIsIGJpdHNbMzk6eF06DQogICBUcmFuc2xhdGlvbiB0
YWJsZSBiYXNlIGFkZHJlc3MsIGJpdHNbMzk6eF0uIERlZmluaW5nIHRoZSB0cmFuc2xhdGlvbiB0
YWJsZSBiYXNlIGFkZHJlc3Mgd2lkdGggb24NCnBhZ2UgQjQtMTY5OCBkZXNjcmliZXMgaG93IHgg
aXMgZGVmaW5lZC4NClRoZSB2YWx1ZSBvZiB4IGRldGVybWluZXMgdGhlIHJlcXVpcmVkIGFsaWdu
bWVudCBvZiB0aGUgdHJhbnNsYXRpb24gdGFibGUsIHdoaWNoIG11c3QgYmUgYWxpZ25lZCB0bw0K
MnggYnl0ZXMuDQoNCkJpdHNbeC0xOjBdIFVOSy9TQlpQLg0KLi4uDQpUbyBhY2Nlc3MgYSA2NC1i
aXQgVFRCUjAsIHNvZnR3YXJlIHBlcmZvcm1zIGEgNjQtYml0IHJlYWQgb3Igd3JpdGUgb2YgdGhl
IENQMTUgcmVnaXN0ZXJzIHdpdGggPENSbT4gc2V0IHRvIGMyIGFuZA0KPG9wYzE+IHNldCB0byAw
LiBGb3IgZXhhbXBsZToNCk1SUkMgcDE1LDAsPFJ0Piw8UnQyPiwgYzIgOyBSZWFkIDY0LWJpdCBU
VEJSMCBpbnRvIFJ0IChsb3cgd29yZCkgYW5kIFJ0MiAoaGlnaCB3b3JkKQ0KTUNSUiBwMTUsMCw8
UnQ+LDxSdDI+LCBjMiA7IFdyaXRlIFJ0IChsb3cgd29yZCkgYW5kIFJ0MiAoaGlnaCB3b3JkKSB0
byA2NC1iaXQgVFRCUjANCg0KU28sIEkgdGhpbmsgaWYgeW91IGFjY2VzcyBUVEJSMC9UVEJSMSBv
biBDUFUgc3VwcG9ydGluZyBMUEFFLCB5b3UgbXVzdCB1c2UgIm1jcnIvbXJyYyIgaW5zdHJ1Y3Rp
b24NCihfX0FDQ0VTU19DUDE1XzY0KS4gSWYgeW91IGFjY2VzcyBUVEJSMC9UVEJSMSBvbiBDUFUg
c3VwcG9ydGluZyBMUEFFIGJ5ICJtY3IvbXJjIiBpbnN0cnVjdGlvbiANCndoaWNoIGlzIDMyYml0
IHZlcnNpb24gKF9fQUNDRVNTX0NQMTUpLCBldmVuIGlmIHRoZSBDUFUgZG9lc24ndCByZXBvcnQg
ZXJyb3IsIHlvdSBhbHNvIGxvc2UgdGhlIGhpZ2gNCm9yIGxvdyAzMmJpdCBvZiB0aGUgVFRCUjAv
VFRCUjEuDQoNCj5BbHNvLCBpZiBJIGZvbGxvdyB5b3VyIHJlYXNvbmluZywgd2h5IGFyZSB5b3Ug
Ym90aGVyaW5nIGRlZmluaW5nIFBBUiBpbg0KPnRoZSBub24tTFBBRSBjYXNlPyBJdCBpcyBub3Qg
dXNlZCBieSBhbnl0aGluZywgYXMgZmFyIGFzIEkgY2FuIHNlZS4uLg0KDQpJIGRvbid0IHVzZSB0
aGUgUEFSLCBJIGNoYW5nZSB0aGUgZGVmaW5pbmcgUEFSIGp1c3QgYmVjYXVzZSBJIHRoaW5rIGl0
IHdpbGwgYmUgd3JvbmcgaW4NCmEgbm9uIExQQUUgQ1BVLg0KDQoNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
