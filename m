Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id A85C96B006C
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 04:51:27 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lj1so4921279pab.18
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 01:51:27 -0800 (PST)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id c3si1139445pdl.88.2014.12.08.01.51.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Dec 2014 01:51:26 -0800 (PST)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Mon, 8 Dec 2014 17:51:15 +0800
Subject: RE: [PATCH] mm:add VM_BUG_ON() for page_mapcount()
Message-ID: <35FD53F367049845BC99AC72306C23D103E688B313F8@CNBJMBX05.corpusers.net>
References: <010b01d012ca$05244060$0f6cc120$@alibaba-inc.com>
In-Reply-To: <010b01d012ca$05244060$0f6cc120$@alibaba-inc.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Hillf Danton' <hillf.zj@alibaba-inc.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Andrew Morton <akpm@linux-foundation.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBIaWxsZiBEYW50b24gW21haWx0
bzpoaWxsZi56akBhbGliYWJhLWluYy5jb21dDQo+IFNlbnQ6IE1vbmRheSwgRGVjZW1iZXIgMDgs
IDIwMTQgNTozMyBQTQ0KPiBUbzogV2FuZywgWWFsaW4NCj4gQ2M6IGxpbnV4LWtlcm5lbDsgbGlu
dXgtbW1Aa3ZhY2sub3JnOyBsaW51eC1hcm0ta2VybmVsQGxpc3RzLmluZnJhZGVhZC5vcmc7DQo+
IEFuZHJldyBNb3J0b247IEhpbGxmIERhbnRvbg0KPiBTdWJqZWN0OiBSZTogW1BBVENIXSBtbTph
ZGQgVk1fQlVHX09OKCkgZm9yIHBhZ2VfbWFwY291bnQoKQ0KPiANCj4gPg0KPiA+IFRoaXMgcGF0
Y2ggYWRkIFZNX0JVR19PTigpIGZvciBzbGFiIHBhZ2UsIGJlY2F1c2UgX21hcGNvdW50IGlzIGFu
DQo+ID4gdW5pb24gd2l0aCBzbGFiIHN0cnVjdCBpbiBzdHJ1Y3QgcGFnZSwgYXZvaWQgYWNjZXNz
IF9tYXBjb3VudCBpZiB0aGlzDQo+ID4gcGFnZSBpcyBhIHNsYWIgcGFnZS4NCj4gPiBBbHNvIHJl
bW92ZSB0aGUgdW5uZWVkZWQgYnJhY2tldC4NCj4gPg0KPiA+IFNpZ25lZC1vZmYtYnk6IFlhbGlu
IFdhbmcgPHlhbGluLndhbmdAc29ueW1vYmlsZS5jb20+DQo+ID4gLS0tDQo+ID4gIGluY2x1ZGUv
bGludXgvbW0uaCB8IDMgKystDQo+ID4gIDEgZmlsZSBjaGFuZ2VkLCAyIGluc2VydGlvbnMoKyks
IDEgZGVsZXRpb24oLSkNCj4gPg0KPiA+IGRpZmYgLS1naXQgYS9pbmNsdWRlL2xpbnV4L21tLmgg
Yi9pbmNsdWRlL2xpbnV4L21tLmggaW5kZXgNCj4gPiAxMWI2NWNmLi4zNDEyNGM0IDEwMDY0NA0K
PiA+IC0tLSBhL2luY2x1ZGUvbGludXgvbW0uaA0KPiA+ICsrKyBiL2luY2x1ZGUvbGludXgvbW0u
aA0KPiA+IEBAIC0zNzMsNyArMzczLDggQEAgc3RhdGljIGlubGluZSB2b2lkIHJlc2V0X3BhZ2Vf
bWFwY291bnQoc3RydWN0IHBhZ2UNCj4gPiAqcGFnZSkNCj4gPg0KPiA+ICBzdGF0aWMgaW5saW5l
IGludCBwYWdlX21hcGNvdW50KHN0cnVjdCBwYWdlICpwYWdlKSAgew0KPiA+IC0JcmV0dXJuIGF0
b21pY19yZWFkKCYocGFnZSktPl9tYXBjb3VudCkgKyAxOw0KPiA+ICsJVk1fQlVHX09OKFBhZ2VT
bGFiKHBhZ2UpKTsNCj4gDQo+IHMvIFZNX0JVR19PTi8gVk1fQlVHX09OX1BBR0UvID8NClllcywg
SSB3aWxsIHNlbmQgYWdhaW4gLg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
