Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 3C885900021
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 01:20:24 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id fa1so2398719pad.11
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 22:20:23 -0700 (PDT)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id wm7si2471522pab.216.2014.10.28.22.20.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Oct 2014 22:20:23 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Wed, 29 Oct 2014 13:20:14 +0800
Subject: RE: [RFC V2] arm/arm64:add CONFIG_HAVE_ARCH_BITREVERSE to support
 rbit instruction
Message-ID: <35FD53F367049845BC99AC72306C23D103E010D18262@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E010D18254@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18257@CNBJMBX05.corpusers.net>
 <1414392371.8884.2.camel@perches.com>
 <CAL_JsqJYBoG+nrr7R3UWz1wrZ--Xjw5X31RkpCrTWMJAePBgRg@mail.gmail.com>
In-Reply-To: <CAL_JsqJYBoG+nrr7R3UWz1wrZ--Xjw5X31RkpCrTWMJAePBgRg@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Rob Herring' <robherring2@gmail.com>, Joe Perches <joe@perches.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Will Deacon <Will.Deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akinobu.mita@gmail.com" <akinobu.mita@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

PiBGcm9tOiBSb2IgSGVycmluZyBbbWFpbHRvOnJvYmhlcnJpbmcyQGdtYWlsLmNvbV0NCj4gPj4g
ZGlmZiAtLWdpdCBhL2FyY2gvYXJtNjQvS2NvbmZpZyBiL2FyY2gvYXJtNjQvS2NvbmZpZyBpbmRl
eA0KPiA+PiA5NTMyZjhkLi4yNjNjMjhjIDEwMDY0NA0KPiA+PiAtLS0gYS9hcmNoL2FybTY0L0tj
b25maWcNCj4gPj4gKysrIGIvYXJjaC9hcm02NC9LY29uZmlnDQo+ID4+IEBAIC0zNiw2ICszNiw3
IEBAIGNvbmZpZyBBUk02NA0KPiA+PiAgICAgICBzZWxlY3QgSEFSRElSUVNfU1dfUkVTRU5EDQo+
ID4+ICAgICAgIHNlbGVjdCBIQVZFX0FSQ0hfQVVESVRTWVNDQUxMDQo+ID4+ICAgICAgIHNlbGVj
dCBIQVZFX0FSQ0hfSlVNUF9MQUJFTA0KPiA+PiArICAgICBzZWxlY3QgSEFWRV9BUkNIX0JJVFJF
VkVSU0UNCj4gPj4gICAgICAgc2VsZWN0IEhBVkVfQVJDSF9LR0RCDQo+ID4+ICAgICAgIHNlbGVj
dCBIQVZFX0FSQ0hfVFJBQ0VIT09LDQo+ID4+ICAgICAgIHNlbGVjdCBIQVZFX0JQRl9KSVQNCj4g
DQo+IFRoZSBrY29uZmlnIGxpc3RzIHNob3VsZCBiZSBzb3J0ZWQuDQo+IA0KPiBSb2INCg0KR290
IGl0ICwNClRoYW5rcyBmb3IgeW91ciByZW1pbmQuDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
