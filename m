Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 819E26B0AB5
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 12:55:25 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id a9so772029pla.2
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 09:55:25 -0800 (PST)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-eopbgr760083.outbound.protection.outlook.com. [40.107.76.83])
        by mx.google.com with ESMTPS id k5si30314358pgr.69.2018.11.16.09.55.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 16 Nov 2018 09:55:24 -0800 (PST)
From: Slavomir Kaslev <kaslevs@vmware.com>
Subject: Re: [PATCH 1/9] mm: Introduce new vm_insert_range API
Date: Fri, 16 Nov 2018 17:55:22 +0000
Message-ID: 
 <CAE0o1NuTR1x2u9aJVo3-u9yPAESQqLRZNrjxDJSugTF6qo+pbA@mail.gmail.com>
References: <20181115154530.GA27872@jordon-HP-15-Notebook-PC>
In-Reply-To: <20181115154530.GA27872@jordon-HP-15-Notebook-PC>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <243495D8FC4F0848823B570DD3CCEA8B@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "jrdr.linux@gmail.com" <jrdr.linux@gmail.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "willy@infradead.org" <willy@infradead.org>, "mhocko@suse.com" <mhocko@suse.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "riel@surriel.com" <riel@surriel.com>, "sfr@canb.auug.org.au" <sfr@canb.auug.org.au>, "rppt@linux.vnet.ibm.com" <rppt@linux.vnet.ibm.com>, "peterz@infradead.org" <peterz@infradead.org>, "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "treding@nvidia.com" <treding@nvidia.com>, "keescook@chromium.org" <keescook@chromium.org>, "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "stefanr@s5r6.in-berlin.de" <stefanr@s5r6.in-berlin.de>, "hjc@rock-chips.com" <hjc@rock-chips.com>, "heiko@sntech.de" <heiko@sntech.de>, "airlied@linux.ie" <airlied@linux.ie>, "oleksandr_andrushchenko@epam.com" <oleksandr_andrushchenko@epam.com>, "joro@8bytes.org" <joro@8bytes.org>, "pawel@osciak.com" <pawel@osciak.com>, "kyungmin.park@samsung.com" <kyungmin.park@samsung.com>, "mchehab@kernel.org" <mchehab@kernel.org>, "boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>, "jgross@suse.com" <jgross@suse.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux1394-devel@lists.sourceforge.net" <linux1394-devel@lists.sourceforge.net>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, "linux-rockchip@lists.infradead.org" <linux-rockchip@lists.infradead.org>, "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>

T24gVGh1LCBOb3YgMTUsIDIwMTggYXQgNTo0MiBQTSBTb3VwdGljayBKb2FyZGVyIDxqcmRyLmxp
bnV4QGdtYWlsLmNvbT4gd3JvdGU6DQo+DQo+IFByZXZpb3VseSBkcml2ZXJzIGhhdmUgdGhlaXIg
b3duIHdheSBvZiBtYXBwaW5nIHJhbmdlIG9mDQo+IGtlcm5lbCBwYWdlcy9tZW1vcnkgaW50byB1
c2VyIHZtYSBhbmQgdGhpcyB3YXMgZG9uZSBieQ0KPiBpbnZva2luZyB2bV9pbnNlcnRfcGFnZSgp
IHdpdGhpbiBhIGxvb3AuDQo+DQo+IEFzIHRoaXMgcGF0dGVybiBpcyBjb21tb24gYWNyb3NzIGRp
ZmZlcmVudCBkcml2ZXJzLCBpdCBjYW4NCj4gYmUgZ2VuZXJhbGl6ZWQgYnkgY3JlYXRpbmcgYSBu
ZXcgZnVuY3Rpb24gYW5kIHVzZSBpdCBhY3Jvc3MNCj4gdGhlIGRyaXZlcnMuDQo+DQo+IHZtX2lu
c2VydF9yYW5nZSBpcyB0aGUgbmV3IEFQSSB3aGljaCB3aWxsIGJlIHVzZWQgdG8gbWFwIGENCj4g
cmFuZ2Ugb2Yga2VybmVsIG1lbW9yeS9wYWdlcyB0byB1c2VyIHZtYS4NCj4NCj4gU2lnbmVkLW9m
Zi1ieTogU291cHRpY2sgSm9hcmRlciA8anJkci5saW51eEBnbWFpbC5jb20+DQo+IFJldmlld2Vk
LWJ5OiBNYXR0aGV3IFdpbGNveCA8d2lsbHlAaW5mcmFkZWFkLm9yZz4NCj4gLS0tDQo+ICBpbmNs
dWRlL2xpbnV4L21tX3R5cGVzLmggfCAgMyArKysNCj4gIG1tL21lbW9yeS5jICAgICAgICAgICAg
ICB8IDI4ICsrKysrKysrKysrKysrKysrKysrKysrKysrKysNCj4gIG1tL25vbW11LmMgICAgICAg
ICAgICAgICB8ICA3ICsrKysrKysNCj4gIDMgZmlsZXMgY2hhbmdlZCwgMzggaW5zZXJ0aW9ucygr
KQ0KPg0KPiBkaWZmIC0tZ2l0IGEvaW5jbHVkZS9saW51eC9tbV90eXBlcy5oIGIvaW5jbHVkZS9s
aW51eC9tbV90eXBlcy5oDQo+IGluZGV4IDVlZDhmNjIuLjE1YWUyNGYgMTAwNjQ0DQo+IC0tLSBh
L2luY2x1ZGUvbGludXgvbW1fdHlwZXMuaA0KPiArKysgYi9pbmNsdWRlL2xpbnV4L21tX3R5cGVz
LmgNCj4gQEAgLTUyMyw2ICs1MjMsOSBAQCBleHRlcm4gdm9pZCB0bGJfZ2F0aGVyX21tdShzdHJ1
Y3QgbW11X2dhdGhlciAqdGxiLCBzdHJ1Y3QgbW1fc3RydWN0ICptbSwNCj4gIGV4dGVybiB2b2lk
IHRsYl9maW5pc2hfbW11KHN0cnVjdCBtbXVfZ2F0aGVyICp0bGIsDQo+ICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgdW5zaWduZWQgbG9uZyBzdGFydCwgdW5zaWduZWQgbG9uZyBlbmQp
Ow0KPg0KPiAraW50IHZtX2luc2VydF9yYW5nZShzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnZtYSwg
dW5zaWduZWQgbG9uZyBhZGRyLA0KPiArICAgICAgICAgICAgICAgICAgICAgICBzdHJ1Y3QgcGFn
ZSAqKnBhZ2VzLCB1bnNpZ25lZCBsb25nIHBhZ2VfY291bnQpOw0KPiArDQo+ICBzdGF0aWMgaW5s
aW5lIHZvaWQgaW5pdF90bGJfZmx1c2hfcGVuZGluZyhzdHJ1Y3QgbW1fc3RydWN0ICptbSkNCj4g
IHsNCj4gICAgICAgICBhdG9taWNfc2V0KCZtbS0+dGxiX2ZsdXNoX3BlbmRpbmcsIDApOw0KPiBk
aWZmIC0tZ2l0IGEvbW0vbWVtb3J5LmMgYi9tbS9tZW1vcnkuYw0KPiBpbmRleCAxNWM0MTdlLi5k
YTkwNGVkIDEwMDY0NA0KPiAtLS0gYS9tbS9tZW1vcnkuYw0KPiArKysgYi9tbS9tZW1vcnkuYw0K
PiBAQCAtMTQ3OCw2ICsxNDc4LDM0IEBAIHN0YXRpYyBpbnQgaW5zZXJ0X3BhZ2Uoc3RydWN0IHZt
X2FyZWFfc3RydWN0ICp2bWEsIHVuc2lnbmVkIGxvbmcgYWRkciwNCj4gIH0NCj4NCj4gIC8qKg0K
PiArICogdm1faW5zZXJ0X3JhbmdlIC0gaW5zZXJ0IHJhbmdlIG9mIGtlcm5lbCBwYWdlcyBpbnRv
IHVzZXIgdm1hDQo+ICsgKiBAdm1hOiB1c2VyIHZtYSB0byBtYXAgdG8NCj4gKyAqIEBhZGRyOiB0
YXJnZXQgdXNlciBhZGRyZXNzIG9mIHRoaXMgcGFnZQ0KPiArICogQHBhZ2VzOiBwb2ludGVyIHRv
IGFycmF5IG9mIHNvdXJjZSBrZXJuZWwgcGFnZXMNCj4gKyAqIEBwYWdlX2NvdW50OiBuby4gb2Yg
cGFnZXMgbmVlZCB0byBpbnNlcnQgaW50byB1c2VyIHZtYQ0KPiArICoNCj4gKyAqIFRoaXMgYWxs
b3dzIGRyaXZlcnMgdG8gaW5zZXJ0IHJhbmdlIG9mIGtlcm5lbCBwYWdlcyB0aGV5J3ZlIGFsbG9j
YXRlZA0KPiArICogaW50byBhIHVzZXIgdm1hLiBUaGlzIGlzIGEgZ2VuZXJpYyBmdW5jdGlvbiB3
aGljaCBkcml2ZXJzIGNhbiB1c2UNCj4gKyAqIHJhdGhlciB0aGFuIHVzaW5nIHRoZWlyIG93biB3
YXkgb2YgbWFwcGluZyByYW5nZSBvZiBrZXJuZWwgcGFnZXMgaW50bw0KPiArICogdXNlciB2bWEu
DQo+ICsgKi8NCj4gK2ludCB2bV9pbnNlcnRfcmFuZ2Uoc3RydWN0IHZtX2FyZWFfc3RydWN0ICp2
bWEsIHVuc2lnbmVkIGxvbmcgYWRkciwNCj4gKyAgICAgICAgICAgICAgICAgICAgICAgc3RydWN0
IHBhZ2UgKipwYWdlcywgdW5zaWduZWQgbG9uZyBwYWdlX2NvdW50KQ0KPiArew0KPiArICAgICAg
IHVuc2lnbmVkIGxvbmcgdWFkZHIgPSBhZGRyOw0KPiArICAgICAgIGludCByZXQgPSAwLCBpOw0K
PiArDQo+ICsgICAgICAgZm9yIChpID0gMDsgaSA8IHBhZ2VfY291bnQ7IGkrKykgew0KPiArICAg
ICAgICAgICAgICAgcmV0ID0gdm1faW5zZXJ0X3BhZ2Uodm1hLCB1YWRkciwgcGFnZXNbaV0pOw0K
PiArICAgICAgICAgICAgICAgaWYgKHJldCA8IDApDQo+ICsgICAgICAgICAgICAgICAgICAgICAg
IHJldHVybiByZXQ7DQo+ICsgICAgICAgICAgICAgICB1YWRkciArPSBQQUdFX1NJWkU7DQo+ICsg
ICAgICAgfQ0KPiArDQo+ICsgICAgICAgcmV0dXJuIHJldDsNCj4gK30NCg0KKyBFWFBPUlRfU1lN
Qk9MKHZtX2luc2VydF9yYW5nZSk7DQoNCj4gKw0KPiArLyoqDQo+ICAgKiB2bV9pbnNlcnRfcGFn
ZSAtIGluc2VydCBzaW5nbGUgcGFnZSBpbnRvIHVzZXIgdm1hDQo+ICAgKiBAdm1hOiB1c2VyIHZt
YSB0byBtYXAgdG8NCj4gICAqIEBhZGRyOiB0YXJnZXQgdXNlciBhZGRyZXNzIG9mIHRoaXMgcGFn
ZQ0KPiBkaWZmIC0tZ2l0IGEvbW0vbm9tbXUuYyBiL21tL25vbW11LmMNCj4gaW5kZXggNzQ5Mjc2
Yi4uZDZlZjVjNyAxMDA2NDQNCj4gLS0tIGEvbW0vbm9tbXUuYw0KPiArKysgYi9tbS9ub21tdS5j
DQo+IEBAIC00NzMsNiArNDczLDEzIEBAIGludCB2bV9pbnNlcnRfcGFnZShzdHJ1Y3Qgdm1fYXJl
YV9zdHJ1Y3QgKnZtYSwgdW5zaWduZWQgbG9uZyBhZGRyLA0KPiAgfQ0KPiAgRVhQT1JUX1NZTUJP
TCh2bV9pbnNlcnRfcGFnZSk7DQo+DQo+ICtpbnQgdm1faW5zZXJ0X3JhbmdlKHN0cnVjdCB2bV9h
cmVhX3N0cnVjdCAqdm1hLCB1bnNpZ25lZCBsb25nIGFkZHIsDQo+ICsgICAgICAgICAgICAgICAg
ICAgICAgIHN0cnVjdCBwYWdlICoqcGFnZXMsIHVuc2lnbmVkIGxvbmcgcGFnZV9jb3VudCkNCj4g
K3sNCj4gKyAgICAgICByZXR1cm4gLUVJTlZBTDsNCj4gK30NCj4gK0VYUE9SVF9TWU1CT0wodm1f
aW5zZXJ0X3JhbmdlKTsNCj4gKw0KPiAgLyoNCj4gICAqICBzeXNfYnJrKCkgZm9yIHRoZSBtb3N0
IHBhcnQgZG9lc24ndCBuZWVkIHRoZSBnbG9iYWwga2VybmVsDQo+ICAgKiAgbG9jaywgZXhjZXB0
IHdoZW4gYW4gYXBwbGljYXRpb24gaXMgZG9pbmcgc29tZXRoaW5nIG5hc3R5DQo+IC0tDQo+IDEu
OS4xDQo+DQo=
