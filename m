Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id A49B928027E
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 17:16:05 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id 31so3872630plk.20
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 14:16:05 -0800 (PST)
Received: from g2t2353.austin.hpe.com (g2t2353.austin.hpe.com. [15.233.44.26])
        by mx.google.com with ESMTPS id c30si4076180pgn.357.2018.01.05.14.16.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jan 2018 14:16:04 -0800 (PST)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: [RFC patch] ioremap: don't set up huge I/O mappings when
 p4d/pud/pmd is zero
Date: Fri, 5 Jan 2018 22:15:57 +0000
Message-ID: <1515193319.2108.24.camel@hpe.com>
References: <1514460261-65222-1-git-send-email-guohanjun@huawei.com>
In-Reply-To: <1514460261-65222-1-git-send-email-guohanjun@huawei.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <15BE780802C69043B7029400C0B34517@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "guohanjun@huawei.com" <guohanjun@huawei.com>
Cc: "linuxarm@huawei.com" <linuxarm@huawei.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "wxf.wang@hisilicon.com" <wxf.wang@hisilicon.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mark.rutland@arm.com" <mark.rutland@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "will.deacon@arm.com" <will.deacon@arm.com>, "Hocko, Michal" <MHocko@suse.com>, "hanjun.guo@linaro.org" <hanjun.guo@linaro.org>

T24gVGh1LCAyMDE3LTEyLTI4IGF0IDE5OjI0ICswODAwLCBIYW5qdW4gR3VvIHdyb3RlOg0KPiBG
cm9tOiBIYW5qdW4gR3VvIDxoYW5qdW4uZ3VvQGxpbmFyby5vcmc+DQo+IA0KPiBXaGVuIHdlIHVz
aW5nIGlvdW5tYXAoKSB0byBmcmVlIHRoZSA0SyBtYXBwaW5nLCBpdCBqdXN0IGNsZWFyIHRoZSBQ
VEVzDQo+IGJ1dCBsZWF2ZSBQNEQvUFVEL1BNRCB1bmNoYW5nZWQsIGFsc28gd2lsbCBub3QgZnJl
ZSB0aGUgbWVtb3J5IG9mIHBhZ2UNCj4gdGFibGVzLg0KPiANCj4gVGhpcyB3aWxsIGNhdXNlIGlz
c3VlcyBvbiBBUk02NCBwbGF0Zm9ybSAobm90IHN1cmUgaWYgb3RoZXIgYXJjaHMgaGF2ZQ0KPiB0
aGUgc2FtZSBpc3N1ZSkgZm9yIHRoaXMgY2FzZToNCj4gDQo+IDEuIGlvcmVtYXAgYSA0SyBzaXpl
LCB2YWxpZCBwYWdlIHRhYmxlIHdpbGwgYnVpbGQsDQo+IDIuIGlvdW5tYXAgaXQsIHB0ZTAgd2ls
bCBzZXQgdG8gMDsNCj4gMy4gaW9yZW1hcCB0aGUgc2FtZSBhZGRyZXNzIHdpdGggMk0gc2l6ZSwg
cGdkL3BtZCBpcyB1bmNoYW5nZWQsDQo+ICAgIHRoZW4gc2V0IHRoZSBhIG5ldyB2YWx1ZSBmb3Ig
cG1kOw0KPiA0LiBwdGUwIGlzIGxlYWtlZDsNCj4gNS4gQ1BVIG1heSBtZWV0IGV4Y2VwdGlvbiBi
ZWNhdXNlIHRoZSBvbGQgcG1kIGlzIHN0aWxsIGluIFRMQiwNCj4gICAgd2hpY2ggd2lsbCBsZWFk
IHRvIGtlcm5lbCBwYW5pYy4NCj4gDQo+IEZpeCBpdCBieSBza2lwIHNldHRpbmcgdXAgdGhlIGh1
Z2UgSS9PIG1hcHBpbmdzIHdoZW4gcDRkL3B1ZC9wbWQgaXMNCj4gemVyby4NCg0KSGkgSGFuanVu
LA0KDQpJIHRlc3RlZCB0aGUgYWJvdmUgc3RlcHMgb24gbXkgeDg2IGJveCwgYnV0IHdhcyBub3Qg
YWJsZSB0byByZXByb2R1Y2UNCnlvdXIga2VybmVsIHBhbmljLiAgT24geDg2LCBhIDRLIHZhZGRy
IGdldHMgYWxsb2NhdGVkIGZyb20gYSBzbWFsbA0KZnJhZ21lbnRlZCBmcmVlIHJhbmdlLCB3aGVy
ZWFzIGEgMk1CIHZhZGRyIGlzIGZyb20gYSBsYXJnZXIgZnJlZSByYW5nZS4gDQpUaGVpciBhZGRy
cyBoYXZlIGRpZmZlcmVudCBhbGlnbm1lbnRzICg0S0IgJiAyTUIpIGFzIHdlbGwuICBTbywgdGhl
DQpzdGVwcyBkaWQgbm90IGxlYWQgdG8gdXNlIGEgc2FtZSBwbWQgZW50cnkuDQoNCkhvd2V2ZXIs
IEkgYWdyZWUgdGhhdCB6ZXJvJ2QgcHRlIGVudHJpZXMgd2lsbCBiZSBsZWFrZWQgd2hlbiBhIHBt
ZCBtYXANCmlzIHNldCBpZiB0aGV5IGFyZSBwcmVzZW50IHVuZGVyIHRoZSBwbWQuDQoNCkkgYWxz
byB0ZXN0ZWQgeW91ciBwYXRjaCBvbiBteSB4ODYgYm94LiAgVW5mb3J0dW5hdGVseSwgaXQgZWZm
ZWN0aXZlbHkNCmRpc2FibGVkIDJNQiBtYXBwaW5ncy4gIFdoaWxlIGEgMk1CIHZhZGRyIGdldHMg
YWxsb2NhdGVkIGZyb20gYSBsYXJnZXINCmZyZWUgcmFuZ2UsIGl0IHNpbGwgY29tZXMgZnJvbSBh
IGZyZWUgcmFuZ2UgY292ZXJlZCBieSB6ZXJvJ2QgcHRlDQplbnRyaWVzLiAgU28sIGl0IGVuZHMg
dXAgd2l0aCA0S0IgbWFwcGluZ3Mgd2l0aCB5b3VyIGNoYW5nZXMuDQoNCkkgdGhpbmsgd2UgbmVl
ZCB0byBjb21lIHVwIHdpdGggb3RoZXIgYXBwcm9hY2guDQpUaGFua3MsDQotVG9zaGkNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
