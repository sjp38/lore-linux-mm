Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id EFC946B0038
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 03:40:01 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id d25so9835870otc.1
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 00:40:01 -0800 (PST)
Received: from huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id o13si719409ota.178.2018.01.16.00.39.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 00:40:01 -0800 (PST)
From: "Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com>
Subject: Re: [PATCH 06/11] change memory_is_poisoned_16 for aligned error
Date: Tue, 16 Jan 2018 08:39:45 +0000
Message-ID: <B8AC3E80E903784988AB3003E3E97330C0070E96@dggemm510-mbs.china.huawei.com>
References: <20171011082227.20546-1-liuwenliang@huawei.com>
 <20171011082227.20546-7-liuwenliang@huawei.com>
 <20171011162345.f601c29d12c81af85bf38565@linux-foundation.org>
 <CACT4Y+Ym3kq5RZ-4F=f97bvT2pNpzDf0kerf6tebzLOY_crR8Q@mail.gmail.com>
 <B8AC3E80E903784988AB3003E3E97330B2528234@dggemm510-mbs.china.huawei.com>
 <20171019125133.GA20805@n2100.armlinux.org.uk>
 <B8AC3E80E903784988AB3003E3E97330C006EF9B@dggemm510-mbs.china.huawei.com>
 <CAKv+Gu94wgvC-yNHdpOr-Jyo6kC_ovA94=ik0mQYUMNV9Miahg@mail.gmail.com>
In-Reply-To: <CAKv+Gu94wgvC-yNHdpOr-Jyo6kC_ovA94=ik0mQYUMNV9Miahg@mail.gmail.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Russell King - ARM Linux <linux@armlinux.org.uk>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey
 Ryabinin <aryabinin@virtuozzo.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, Laura Abbott <labbott@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, "cdall@linaro.org" <cdall@linaro.org>, "marc.zyngier@arm.com" <marc.zyngier@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Matthew
 Wilcox <mawilcox@microsoft.com>, Thomas Gleixner <tglx@linutronix.de>, Thomas Garnier <thgarnie@google.com>, Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>, Vladimir Murzin <vladimir.murzin@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, Ingo Molnar <mingo@kernel.org>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, Alexander
 Potapenko <glider@google.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jiazhenghua <jiazhenghua@huawei.com>, Dailei <dylix.dailei@huawei.com>, Zengweilin <zengweilin@huawei.com>, Heshaoliang <heshaoliang@huawei.com>

T24gNiBEZWNlbWJlciAyMDE3IGF0IDE6MDkgIEFyZCBCaWVzaGV1dmVsIFthcmQuYmllc2hldXZl
bEBsaW5hcm8ub3JnXSB3cm90ZToNCj5PbiA1IERlY2VtYmVyIDIwMTcgYXQgMTQ6MTksIExpdXdl
bmxpYW5nIChBYmJvdHQgTGl1KQ0KPjxsaXV3ZW5saWFuZ0BodWF3ZWkuY29tPiB3cm90ZToNCj4+
IE9uIE5vdiAyMywgMjAxNyAgMjA6MzAgIFJ1c3NlbGwgS2luZyAtIEFSTSBMaW51eCBbbWFpbHRv
OmxpbnV4QGFybWxpbnV4Lm9yZy51a10gIHdyb3RlOg0KPj4+T24gVGh1LCBPY3QgMTIsIDIwMTcg
YXQgMTE6Mjc6NDBBTSArMDAwMCwgTGl1d2VubGlhbmcgKExhbWIpIHdyb3RlOg0KPj4+PiA+PiAt
IEkgZG9uJ3QgdW5kZXJzdGFuZCB3aHkgdGhpcyBpcyBuZWNlc3NhcnkuICBtZW1vcnlfaXNfcG9p
c29uZWRfMTYoKQ0KPj4+PiA+PiAgIGFscmVhZHkgaGFuZGxlcyB1bmFsaWduZWQgYWRkcmVzc2Vz
Pw0KPj4+PiA+Pg0KPj4+PiA+PiAtIElmIGl0J3MgbmVlZGVkIG9uIEFSTSB0aGVuIHByZXN1bWFi
bHkgaXQgd2lsbCBiZSBuZWVkZWQgb24gb3RoZXINCj4+Pj4gPj4gICBhcmNoaXRlY3R1cmVzLCBz
byBDT05GSUdfQVJNIGlzIGluc3VmZmljaWVudGx5IGdlbmVyYWwuDQo+Pj4+ID4+DQo+Pj4+ID4+
IC0gSWYgdGhlIHByZXNlbnQgbWVtb3J5X2lzX3BvaXNvbmVkXzE2KCkgaW5kZWVkIGRvZXNuJ3Qg
d29yayBvbiBBUk0sDQo+Pj4+ID4+ICAgaXQgd291bGQgYmUgYmV0dGVyIHRvIGdlbmVyYWxpemUv
Zml4IGl0IGluIHNvbWUgZmFzaGlvbiByYXRoZXIgdGhhbg0KPj4+PiA+PiAgIGNyZWF0aW5nIGEg
bmV3IHZhcmlhbnQgb2YgdGhlIGZ1bmN0aW9uLg0KPj4+Pg0KPj4+Pg0KPj4+PiA+WWVzLCBJIHRo
aW5rIGl0IHdpbGwgYmUgYmV0dGVyIHRvIGZpeCB0aGUgY3VycmVudCBmdW5jdGlvbiByYXRoZXIg
dGhlbg0KPj4+PiA+aGF2ZSAyIHNsaWdodGx5IGRpZmZlcmVudCBjb3BpZXMgd2l0aCBpZmRlZidz
Lg0KPj4+PiA+V2lsbCBzb21ldGhpbmcgYWxvbmcgdGhlc2UgbGluZXMgd29yayBmb3IgYXJtPyAx
Ni1ieXRlIGFjY2Vzc2VzIGFyZQ0KPj4+PiA+bm90IHRvbyBjb21tb24sIHNvIGl0IHNob3VsZCBu
b3QgYmUgYSBwZXJmb3JtYW5jZSBwcm9ibGVtLiBBbmQNCj4+Pj4gPnByb2JhYmx5IG1vZGVybiBj
b21waWxlcnMgY2FuIHR1cm4gMiAxLWJ5dGUgY2hlY2tzIGludG8gYSAyLWJ5dGUgY2hlY2sNCj4+
Pj4gPndoZXJlIHNhZmUgKHg4NikuDQo+Pj4+DQo+Pj4+ID5zdGF0aWMgX19hbHdheXNfaW5saW5l
IGJvb2wgbWVtb3J5X2lzX3BvaXNvbmVkXzE2KHVuc2lnbmVkIGxvbmcgYWRkcikNCj4+Pj4gPnsN
Cj4+Pj4gPiAgICAgICAgdTggKnNoYWRvd19hZGRyID0gKHU4ICopa2FzYW5fbWVtX3RvX3NoYWRv
dygodm9pZCAqKWFkZHIpOw0KPj4+PiA+DQo+Pj4+ID4gICAgICAgIGlmIChzaGFkb3dfYWRkclsw
XSB8fCBzaGFkb3dfYWRkclsxXSkNCj4+Pj4gPiAgICAgICAgICAgICAgICByZXR1cm4gdHJ1ZTsN
Cj4+Pj4gPiAgICAgICAgLyogVW5hbGlnbmVkIDE2LWJ5dGVzIGFjY2VzcyBtYXBzIGludG8gMyBz
aGFkb3cgYnl0ZXMuICovDQo+Pj4+ID4gICAgICAgIGlmICh1bmxpa2VseSghSVNfQUxJR05FRChh
ZGRyLCBLQVNBTl9TSEFET1dfU0NBTEVfU0laRSkpKQ0KPj4+PiA+ICAgICAgICAgICAgICAgIHJl
dHVybiBtZW1vcnlfaXNfcG9pc29uZWRfMShhZGRyICsgMTUpOw0KPj4+PiA+ICAgICAgICByZXR1
cm4gZmFsc2U7DQo+Pj4+ID59DQo+Pj4+DQo+Pj4+IFRoYW5rcyBmb3IgQW5kcmV3IE1vcnRvbiBh
bmQgRG1pdHJ5IFZ5dWtvdidzIHJldmlldy4NCj4+Pj4gSWYgdGhlIHBhcmFtZXRlciBhZGRyPTB4
YzAwMDAwMDgsIG5vdyBpbiBmdW5jdGlvbjoNCj4+Pj4gc3RhdGljIF9fYWx3YXlzX2lubGluZSBi
b29sIG1lbW9yeV9pc19wb2lzb25lZF8xNih1bnNpZ25lZCBsb25nIGFkZHIpDQo+Pj4+IHsNCj4+
Pj4gIC0tLSAgICAgLy9zaGFkb3dfYWRkciA9ICh1MTYgKikoS0FTQU5fT0ZGU0VUKzB4MTgwMDAw
MDEoPTB4YzAwMDAwMDg+PjMpKSBpcyBub3QNCj4+Pj4gIC0tLSAgICAgLy8gdW5zaWduZWQgYnkg
MiBieXRlcy4NCj4+Pj4gICAgICAgICB1MTYgKnNoYWRvd19hZGRyID0gKHUxNiAqKWthc2FuX21l
bV90b19zaGFkb3coKHZvaWQgKilhZGRyKTsNCj4+Pj4NCj4+Pj4gICAgICAgICAvKiBVbmFsaWdu
ZWQgMTYtYnl0ZXMgYWNjZXNzIG1hcHMgaW50byAzIHNoYWRvdyBieXRlcy4gKi8NCj4+Pj4gICAg
ICAgICBpZiAodW5saWtlbHkoIUlTX0FMSUdORUQoYWRkciwgS0FTQU5fU0hBRE9XX1NDQUxFX1NJ
WkUpKSkNCj4+Pj4gICAgICAgICAgICAgICAgIHJldHVybiAqc2hhZG93X2FkZHIgfHwgbWVtb3J5
X2lzX3BvaXNvbmVkXzEoYWRkciArIDE1KTsNCj4+Pj4gLS0tLSAgICAgIC8vaGVyZSBpcyBnb2lu
ZyB0byBiZSBlcnJvciBvbiBhcm0sIHNwZWNpYWxseSB3aGVuIGtlcm5lbCBoYXMgbm90IGZpbmlz
aGVkIHlldC4NCj4+Pj4gLS0tLSAgICAgIC8vQmVjYXVzZSB0aGUgdW5zaWduZWQgYWNjZXNzaW5n
IGNhdXNlIERhdGFBYm9ydCBFeGNlcHRpb24gd2hpY2ggaXMgbm90DQo+Pj4+IC0tLS0gICAgICAv
L2luaXRpYWxpemVkIHdoZW4ga2VybmVsIGlzIHN0YXJ0aW5nLg0KPj4+PiAgICAgICAgIHJldHVy
biAqc2hhZG93X2FkZHI7DQo+Pj4+IH0NCj4+Pj4NCj4+Pj4gSSBhbHNvIHRoaW5rIGl0IGlzIGJl
dHRlciB0byBmaXggdGhpcyBwcm9ibGVtLg0KPj4NCj4+PldoYXQgYWJvdXQgdXNpbmcgZ2V0X3Vu
YWxpZ25lZCgpID8NCj4+DQo+PiBUaGFua3MgZm9yIHlvdXIgcmV2aWV3Lg0KPj4NCj4+IEkgdGhp
bmsgaXQgaXMgZ29vZCBpZGVhIHRvIHVzZSBnZXRfdW5hbGlnbmVkLiBCdXQgQVJNdjcgc3VwcG9y
dCBDT05GSUdfIEhBVkVfRUZGSUNJRU5UX1VOQUxJR05FRF9BQ0NFU1MNCj4+IChhcmNoL2FybS9L
Y29uZmlnIDogc2VsZWN0IEhBVkVfRUZGSUNJRU5UX1VOQUxJR05FRF9BQ0NFU1MgaWYgKENQVV9W
NiB8fCBDUFVfVjZLIHx8IENQVV9WNykgJiYgTU1VKS4NCj4+IFNvIG9uIEFSTXY3LCB0aGUgY29k
ZToNCj4+IHUxNiAqc2hhZG93X2FkZHIgPSBnZXRfdW5hbGlnbmVkKCh1MTYgKilrYXNhbl9tZW1f
dG9fc2hhZG93KCh2b2lkICopYWRkcikpOw0KPj4gZXF1YWxzIHRoZSBjb2RlOjAwMA0KPj4gdTE2
ICpzaGFkb3dfYWRkciA9ICh1MTYgKilrYXNhbl9tZW1fdG9fc2hhZG93KCh2b2lkICopYWRkcik7
DQo+Pg0KPg0KPk5vIGl0IGRvZXMgbm90LiBUaGUgY29tcGlsZXIgbWF5IG1lcmdlIGFkamFjZW50
IGFjY2Vzc2VzIGludG8gbGRtIG9yDQo+bGRyZCBpbnN0cnVjdGlvbnMsIHdoaWNoIGRvIG5vdCB0
b2xlcmF0ZSBtaXNhbGlnbm1lbnQgcmVnYXJkbGVzcyBvZg0KPnRoZSBTQ1RMUi5BIGJpdC4NCj4N
Cj5UaGlzIGlzIGFjdHVhbGx5IHNvbWV0aGluZyB3ZSBtYXkgbmVlZCB0byBmaXggZm9yIEFSTSwg
aS5lLiwgZHJvcA0KPkhBVkVfRUZGSUNJRU5UX1VOQUxJR05FRF9BQ0NFU1MgYWx0b2dldGhlciwg
b3IgY2FyZWZ1bGx5IHJldmlldyB0aGUNCj53YXkgaXQgaXMgdXNlZCBjdXJyZW50bHkuDQo+DQo+
PiBPbiBBUk12NywgaWYgU0NSTFIuQSBpcyAwLCB1bmFsaWduZWQgYWNjZXNzIGlzIE9LLiAgSGVy
ZSBpcyB0aGUgZGVzY3JpcHRpb24gY29tZXMgZnJvbSBBUk0ocikgQXJjaGl0ZWN0dXJlIFJlZmVy
ZW5jZQ0KPj4gTWFudWFsIEFSTXY3LUEgYW5kIEFSTXY3LVIgZWRpdGlvbiA6DQo+Pg0KPjxzbmlw
Pg0KPg0KPkNvdWxkIHlvdSAqcGxlYXNlKiBzdG9wIHF1b3RpbmcgdGhlIEFSTSBBUk0gYXQgdXM/
IFBlb3BsZSB3aG8gYXJlDQo+c2Vla2luZyBkZXRhaWxlZCBpbmZvcm1hdGlvbiBsaWtlIHRoYXQg
d2lsbCBrbm93IHdoZXJlIHRvIGZpbmQgaXQuDQo+DQo+LS0NCj5BcmQuDQoNClRoYW5rcyBmb3Ig
QXJkIEJpZXNoZXV2ZWwncyByZXZpZXcuDQpVc2luZyBnZXRfdW5hbGlnbmVkIGRvZXMgbm90IGdp
dmUgdXMgdG9vIG11Y2ggYmVuZWZpdCwgYW5kIGdldF91bmFsaWduZWQgbWF5IGhhdmUgc29tZSBw
cm9ibGVtLg0KU28gaXQgbWF5IGJlIGJldHRlciB0byBub3QgdXNlIGdldF91bmFsaWduZWQuDQoN
Cg0KDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
