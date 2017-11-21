Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id CC11D6B0286
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 03:00:00 -0500 (EST)
Received: by mail-vk0-f71.google.com with SMTP id j67so7017442vkd.16
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 00:00:00 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id g24si4872595uaa.312.2017.11.20.23.59.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 20 Nov 2017 23:59:59 -0800 (PST)
From: "Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com>
Subject: =?gb2312?B?tPC4tDogW1BBVENIIDAxLzExXSBJbml0aWFsaXplIHRoZSBtYXBwaW5nIG9m?=
 =?gb2312?Q?_KASan_shadow_memory?=
Date: Tue, 21 Nov 2017 07:59:01 +0000
Message-ID: <B8AC3E80E903784988AB3003E3E97330C0068F12@dggemm510-mbx.china.huawei.com>
References: <8e959f69-a578-793b-6c32-18b5b0cd08c2@arm.com>
	<B8AC3E80E903784988AB3003E3E97330C0063545@dggemm510-mbs.china.huawei.com>
	<87a7znsubp.fsf@on-the-bus.cambridge.arm.com>
	<B8AC3E80E903784988AB3003E3E97330C0063587@dggemm510-mbs.china.huawei.com>
	<bbf43f92-3d0c-940d-b66b-68f92eb9b282@arm.com>
	<B8AC3E80E903784988AB3003E3E97330C00635F3@dggemm510-mbs.china.huawei.com>
	<87po8ir1kg.fsf@on-the-bus.cambridge.arm.com>
	<B8AC3E80E903784988AB3003E3E97330C006371B@dggemm510-mbs.china.huawei.com>
	<87375eqobb.fsf@on-the-bus.cambridge.arm.com>
	<B8AC3E80E903784988AB3003E3E97330C0063816@dggemm510-mbs.china.huawei.com>
	<20171117073556.GB28855@cbox>
	<B8AC3E80E903784988AB3003E3E97330C00638D4@dggemm510-mbs.china.huawei.com>
 <20171118134841.3f6c9183@why.wild-wind.fr.eu.org>
In-Reply-To: <20171118134841.3f6c9183@why.wild-wind.fr.eu.org>
Content-Language: zh-CN
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Zyngier <marc.zyngier@arm.com>
Cc: Christoffer Dall <cdall@linaro.org>, "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, "labbott@redhat.com" <labbott@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "mingo@kernel.org" <mingo@kernel.org>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jiazhenghua <jiazhenghua@huawei.com>, Dailei <dylix.dailei@huawei.com>, Zengweilin <zengweilin@huawei.com>, Heshaoliang <heshaoliang@huawei.com>

T24gTm92IDE3LCAyMDE3ICAyMTo0OSAgTWFyYyBaeW5naWVyIFttYWlsdG86bWFyYy56eW5naWVy
QGFybS5jb21dICB3cm90ZToNCj5PbiBTYXQsIDE4IE5vdiAyMDE3IDEwOjQwOjA4ICswMDAwDQo+
IkxpdXdlbmxpYW5nIChBYmJvdHQgTGl1KSIgPGxpdXdlbmxpYW5nQGh1YXdlaS5jb20+IHdyb3Rl
Og0KDQo+PiBPbiBOb3YgMTcsIDIwMTcgIDE1OjM2IENocmlzdG9mZmVyIERhbGwgW21haWx0bzpj
ZGFsbEBsaW5hcm8ub3JnXSAgd3JvdGU6DQo+PiA+SWYgeW91ciBwcm9jZXNzb3IgZG9lcyBzdXBw
b3J0IExQQUUgKGxpa2UgYSBDb3J0ZXgtQTE1IGZvciBleGFtcGxlKSwNCj4+ID50aGVuIHlvdSBo
YXZlIGJvdGggdGhlIDMyLWJpdCBhY2Nlc3NvcnMgKE1SQyBhbmQgTUNSKSBhbmQgdGhlIDY0LWJp
dA0KPj4gPmFjY2Vzc29ycyAoTVJSQywgTUNSUiksIGFuZCB1c2luZyB0aGUgMzItYml0IGFjY2Vz
c29yIHdpbGwgc2ltcGx5IGFjY2Vzcw0KPj4gPnRoZSBsb3dlciAzMi1iaXRzIG9mIHRoZSA2NC1i
aXQgcmVnaXN0ZXIuDQo+PiA+DQo+PiA+SG9wZSB0aGlzIGhlbHBzLA0KPj4gPi1DaHJpc3RvZmZl
cg0KPj4NCj4+IElmIHlvdSBrbm93IHRoZSBoaWdoZXIgMzItYml0cyBvZiB0aGUgNjQtYml0cyBj
cDE1J3MgcmVnaXN0ZXIgaXMgbm90IHVzZWZ1bCBmb3IgeW91ciBzeXN0ZW0sDQo+PiB0aGVuIHlv
dSBjYW4gdXNlIHRoZSAzMi1iaXQgYWNjZXNzb3IgdG8gZ2V0IG9yIHNldCB0aGUgNjQtYml0IGNw
MTUncyByZWdpc3Rlci4NCj4+IEJ1dCBpZiB0aGUgaGlnaGVyIDMyLWJpdHMgb2YgdGhlIDY0LWJp
dHMgY3AxNSdzIHJlZ2lzdGVyIGlzIHVzZWZ1bCBmb3IgeW91ciBzeXN0ZW0sDQo+PiB0aGVuIHlv
dSBjYW4ndCB1c2UgdGhlIDMyLWJpdCBhY2Nlc3NvciB0byBnZXQgb3Igc2V0IHRoZSA2NC1iaXQg
Y3AxNSdzIHJlZ2lzdGVyLg0KPj4NCj4+IFRUQlIwL1RUQlIxL1BBUidzIGhpZ2hlciAzMi1iaXRz
IGlzIHVzZWZ1bCBmb3IgQ1BVIHN1cHBvcnRpbmcgTFBBRS4NCj4+IFRoZSBmb2xsb3dpbmcgZGVz
Y3JpcHRpb24gd2hpY2ggY29tZXMgZnJvbSBBUk0ocikgQXJjaGl0ZWN0dXJlIFJlZmVyZW5jZQ0K
Pj4gTWFudWFsIEFSTXY3LUEgYW5kIEFSTXY3LVIgZWRpdGlvbiB0ZWxsIHVzIHRoZSByZWFzb246
DQo+Pg0KPj4gNjQtYml0IFRUQlIwIGFuZCBUVEJSMSBmb3JtYXQ6DQo+PiAuLi4NCj4+IEJBRERS
LCBiaXRzWzM5OnhdIDoNCj4+IFRyYW5zbGF0aW9uIHRhYmxlIGJhc2UgYWRkcmVzcywgYml0c1sz
OTp4XS4gRGVmaW5pbmcgdGhlIHRyYW5zbGF0aW9uIHRhYmxlIGJhc2UgYWRkcmVzcyB3aWR0aCBv
bg0KPj4gcGFnZSBCNC0xNjk4IGRlc2NyaWJlcyBob3cgeCBpcyBkZWZpbmVkLg0KPj4gVGhlIHZh
bHVlIG9mIHggZGV0ZXJtaW5lcyB0aGUgcmVxdWlyZWQgYWxpZ25tZW50IG9mIHRoZSB0cmFuc2xh
dGlvbiB0YWJsZSwgd2hpY2ggbXVzdCBiZSBhbGlnbmVkIHRvDQo+PiAyeCBieXRlcy4NCj4+DQo+
PiBBYmJvdHQgTGl1OiBCZWNhdXNlIEJBRERSIG9uIENQVSBzdXBwb3J0aW5nIExQQUUgbWF5IGJl
IGJpZ2dlciB0aGFuIG1heCB2YWx1ZSBvZiAzMi1iaXQsIHNvIGJpdHNbMzk6MzJdIG1heQ0KPj4g
YmUgdmFsaWQgdmFsdWUgd2hpY2ggaXMgdXNlZnVsIGZvciB0aGUgc3lzdGVtLg0KPj4NCj4+IDY0
LWJpdCBQQVIgZm9ybWF0DQo+PiAuLi4NCj4+IFBBWzM5OjEyXQ0KPj4gUGh5c2ljYWwgQWRkcmVz
cy4gVGhlIHBoeXNpY2FsIGFkZHJlc3MgY29ycmVzcG9uZGluZyB0byB0aGUgc3VwcGxpZWQgdmly
dHVhbCBhZGRyZXNzLiBUaGlzIGZpZWxkDQo+PiByZXR1cm5zIGFkZHJlc3MgYml0c1szOToxMl0u
DQo+Pg0KPj4gQWJib3R0IExpdTogQmVjYXVzZSBQaHlzaWNhbCBBZGRyZXNzIG9uIENQVSBzdXBw
b3J0aW5nIExQQUUgbWF5IGJlIGJpZ2dlciB0aGFuIG1heCB2YWx1ZSBvZiAzMi1iaXQsDQo+PiBz
byBiaXRzWzM5OjMyXSBtYXkgYmUgdmFsaWQgdmFsdWUgd2hpY2ggaXMgdXNlZnVsIGZvciB0aGUg
c3lzdGVtLg0KPj4NCj4+IENvbmNsdXNpb246IERvbid0IHVzZSAzMi1iaXQgYWNjZXNzb3IgdG8g
Z2V0IG9yIHNldCBUVEJSMC9UVEJSMS9QQVIgb24gQ1BVIHN1cHBvcnRpbmcgTFBBRSwNCj4+IGlm
IHlvdSBkbyB0aGF0LCB5b3VyIHN5c3RlbSBtYXkgcnVuIGVycm9yLg0KDQo+VGhhdCdzIG5vdCBy
ZWFsbHkgdHJ1ZS4gWW91IGNhbiBydW4gYW4gbm9uLUxQQUUga2VybmVsIHRoYXQgdXNlcyB0aGUN
Cj4zMmJpdCBhY2Nlc3NvcnMgYW4gYSBDb3J0ZXgtQTE1IHRoYXQgc3VwcG9ydHMgTFBBRS4gWW91
J3JlIGp1c3QgbGltaXRlZA0KPnRvIDRHQiBvZiBwaHlzaWNhbCBzcGFjZS4gQW5kIHlvdSdyZSBw
cmV0dHkgbXVjaCBndWFyYW50ZWVkIHRvIGhhdmUNCj5zb21lIG1lbW9yeSBiZWxvdyA0R0IgKG9u
ZSB3YXkgb3IgYW5vdGhlciksIG9yIHlvdSdkIGhhdmUgYSBzbGlnaHQNCj5wcm9ibGVtIHNldHRp
bmcgdXAgeW91ciBwYWdlIHRhYmxlcy4NCg0KPiAgICAgICBNLg0KPi0tDQo+V2l0aG91dCBkZXZp
YXRpb24gZnJvbSB0aGUgbm9ybSwgcHJvZ3Jlc3MgaXMgbm90IHBvc3NpYmxlLg0KDQpUaGFua3Mg
Zm9yIHlvdXIgcmV2aWV3Lg0KUGxlYXNlIGRvbid0IGFzayBwZW9wbGUgdG8gbGltaXQgdG8gNEdC
IG9mIHBoeXNpY2FsIHNwYWNlIG9uIENQVQ0Kc3VwcG9ydGluZyBMUEFFLCBwbGVhc2UgZG9uJ3Qg
YXNrIHBlb3BsZSB0byBndWFyYW50ZWVkIHRvIGhhdmUgc29tZQ0KbWVtb3J5IGJlbG93IDRHQiBv
biBDUFUgc3VwcG9ydGluZyBMUEFFLg0KV2h5IHBlb3BsZSBzZWxlY3QgQ1BVIHN1cHBvcnRpbmcg
TFBBRShqdXN0IGxpa2UgY29ydGV4IEExNSk/IA0KQmVjYXVzZSBzb21lIG9mIHBlb3BsZSB0aGlu
ayA0R0IgcGh5c2ljYWwgc3BhY2UgaXMgbm90IGVub3VnaCBmb3IgdGhlaXIgDQpzeXN0ZW0sIG1h
eWJlIHRoZXkgd2FudCB0byB1c2UgOEdCLzE2R0IgRERSIHNwYWNlLg0KVGhlbiB5b3UgdGVsbCB0
aGVtIHRoYXQgdGhleSBtdXN0IGd1YXJhbnRlZWQgdG8gaGF2ZSBzb21lIG1lbW9yeSBiZWxvdyA0
R0IsDQpqdXN0IG9ubHkgYmVjYXVzZSB5b3UgdGhpbmsgdGhlIGNvZGUgYXMgZm9sbG93Og0KKyNk
ZWZpbmUgVFRCUjAgICAgICAgICAgIF9fQUNDRVNTX0NQMTUoYzIsIDAsIGMwLCAwKQ0KKyNkZWZp
bmUgVFRCUjEgICAgICAgICAgIF9fQUNDRVNTX0NQMTUoYzIsIDAsIGMwLCAxKQ0KKyNkZWZpbmUg
UEFSICAgICAgICAgICAgIF9fQUNDRVNTX0NQMTUoYzcsIDAsIGM0LCAwKQ0KDQppcyBiZXR0ZXIg
dGhhbiB0aGUgY29kZSBsaWtlIHRoaXM6DQoNCisjaWZkZWYgQ09ORklHX0FSTV9MUEFFDQorI2Rl
ZmluZSBUVEJSMCAgICAgICAgICAgX19BQ0NFU1NfQ1AxNV82NCgwLCBjMikNCisjZGVmaW5lIFRU
QlIxICAgICAgICAgICBfX0FDQ0VTU19DUDE1XzY0KDEsIGMyKQ0KKyNkZWZpbmUgUEFSICAgICAg
ICAgICAgIF9fQUNDRVNTX0NQMTVfNjQoMCwgYzcpDQorI2Vsc2UNCisjZGVmaW5lIFRUQlIwICAg
ICAgICAgICBfX0FDQ0VTU19DUDE1KGMyLCAwLCBjMCwgMCkNCisjZGVmaW5lIFRUQlIxICAgICAg
ICAgICBfX0FDQ0VTU19DUDE1KGMyLCAwLCBjMCwgMSkNCisjZGVmaW5lIFBBUiAgICAgICAgICAg
ICBfX0FDQ0VTU19DUDE1KGM3LCAwLCBjNCwgMCkNCisjZW5kaWYNCg0KDQpTbyxJIHRoaW5rIHRo
ZSBmb2xsb3dpbmcgY29kZTogDQorI2lmZGVmIENPTkZJR19BUk1fTFBBRQ0KKyNkZWZpbmUgVFRC
UjAgICAgICAgICAgIF9fQUNDRVNTX0NQMTVfNjQoMCwgYzIpDQorI2RlZmluZSBUVEJSMSAgICAg
ICAgICAgX19BQ0NFU1NfQ1AxNV82NCgxLCBjMikNCisjZGVmaW5lIFBBUiAgICAgICAgICAgICBf
X0FDQ0VTU19DUDE1XzY0KDAsIGM3KQ0KKyNlbHNlDQorI2RlZmluZSBUVEJSMCAgICAgICAgICAg
X19BQ0NFU1NfQ1AxNShjMiwgMCwgYzAsIDApDQorI2RlZmluZSBUVEJSMSAgICAgICAgICAgX19B
Q0NFU1NfQ1AxNShjMiwgMCwgYzAsIDEpDQorI2RlZmluZSBQQVIgICAgICAgICAgICAgX19BQ0NF
U1NfQ1AxNShjNywgMCwgYzQsIDApDQorI2VuZGlmDQoNCmlzIGJldHRlciBiZWNhdXNlIGl0J3Mg
bm90IG5lY2Vzc2FyeSB0byBhc2sgcGVvcGxlIHRvIGd1YXJhbnRlZWQgdG8NCmhhdmUgc29tZSBt
ZW1vcnkgYmVsb3cgNEdCIG9uIENQVSBzdXBwb3J0aW5nIExQQUUuIA0KSWYgd2Ugd2FudCB0byBh
c2sgcGVvcGxlIHRvIGd1YXJhbnRlZWQgdG8gaGF2ZSBzb21lIG1lbW9yeSBiZWxvdyA0R0IgDQpv
biBDUFUgc3VwcG9ydGluZyBMUEFFLCB0aGVyZSBuZWVkIHRvIG1vZGlmeSBzb21lIG90aGVyIGNv
ZGUuDQpJIHRoaW5rIGl0IG1ha2VzIHRoZSBzaW1wbGUgcHJvYmxlbSBtb3JlIGNvbXBsZXggdG8g
bW9kaWZ5IHNvbWUgb3RoZXIgY29kZSBmb3IgdGhpcy4NCg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
