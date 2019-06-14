Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95E2EC31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 15:16:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5257C2168B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 15:16:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5257C2168B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ACULAB.COM
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D1ADA6B0007; Fri, 14 Jun 2019 11:16:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC9B56B0008; Fri, 14 Jun 2019 11:16:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B91566B000A; Fri, 14 Jun 2019 11:16:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7F7E06B0007
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 11:16:48 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id g11so1754743plt.23
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 08:16:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:mime-version
         :content-transfer-encoding;
        bh=Gb6T1fb5J0MknZh0ASfAhdSNUmdYCIB4rfTEC91ltYA=;
        b=f13Ros9puSLAmLAZ1f851sqFIKdJPoIWCskMocQzoyOSg4inH0PxFrnldmm64zsG15
         kYmkLMFTqCLeVYLLPs6mnc/8Ue8FCIKuc+9eEtq3cncPbniRZHV8ZmrjmBulLuISUMD7
         pNU3o8snhGUk6AIK9KW/A4eeHOiIuKSCMvCwl3lD+pfKSC3ZUVdwfo1FMH6SDV5HADHC
         q3kqwQ0/ONvVLfNTlH0LrWbcu0i7DY2K61Ol1TQJkBGOm1gsaUk0MYMtmB+UqL6JX/J+
         +PD+Um8QbCST3OiJ7idAxD97C19hTYKjrB5dsWWgJPNNRfdtO+dMheu07IVlweBEpgHt
         BI2w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david.laight@aculab.com designates 207.82.80.151 as permitted sender) smtp.mailfrom=david.laight@aculab.com
X-Gm-Message-State: APjAAAX6lmj1tg3Y8hbEquY7RCMmlRZpSHydnWvGyqygvBmerSPZs2j/
	06QQD88u6hhQRoCbwkoL+/sUI5g+RjH4D3Xy3pYjfhEoISdr/uTtoZVpBBJDPC+6jdncRUOMa5s
	CYAQjQODIpt9MX6NZHKM1f9mN2Cj+ijIu0AmfDUyNtIfSO6ppVjqaWWFfJzhJxFfI5w==
X-Received: by 2002:aa7:9293:: with SMTP id j19mr55579231pfa.190.1560525408191;
        Fri, 14 Jun 2019 08:16:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxV/JujB1vGEZLQR/Vt1aI7UUYYhAGQZqQRgb0KB5yVUvITI1MKK+xk4dip8byeFtNU3QAT
X-Received: by 2002:aa7:9293:: with SMTP id j19mr55579163pfa.190.1560525407490;
        Fri, 14 Jun 2019 08:16:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560525407; cv=none;
        d=google.com; s=arc-20160816;
        b=D5LBxhc6LsCsdw0yFT96EiGowJ3MZP79EuLOdxQM1l7saSkUV5xXlsnaLaKcaeQdDf
         ZXGV7eG/lPpdph70fIoRSTJKtX2TNqGChWfs+Pv9pmkp7fx/r/RSMIebVcqp9CRBrvNW
         znDMHY4HCJ27jYScZsOgoezgxrUrsSYWMCt8jpWt0uGLAMS82ALfcvn4VPnxltkN2Lmj
         6E0xXasneej+SPPI8X93leEc70STCkBp7YiWapAoEQPrSpYEB7hiCHvCbeSJHgpe7WTi
         IUzXwZfzW4XYE2k+DEK163IhiJbaPWfbe3CebRq4ccmqlTEqghDQJeT28TQdd9TcSHeo
         aDaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=Gb6T1fb5J0MknZh0ASfAhdSNUmdYCIB4rfTEC91ltYA=;
        b=oUgqO0ZhisR1MFR80OXha2YRqgS08MVlTYDZMztXA3RlXB0zqeh6ayO5seCNRtoocf
         Vux2KYZTVP/5yUln8NgmPevgXDhU75gTQZRiEghpUR64HFvYOaqKy01YI9FL5+eqjncl
         JfoA/Yu4rBTIPTKHoiVBu4Rl0R2D25MGuRZYht1b6FL83N5SynVi4/2epv7KWEFRO2Ba
         /WqtFj8xiqF83Sk8ZSLhJMtYEiY2rd6FpFtLuaJ2vI/kRWSqH2t7hlBUvyUw2xLeI3gF
         sRfM6FBMxecd8w5+6ZnpUdcu1UyWqyeFPhh91JOTRB3WMimBu8Ho5IgA8RRJO1c/qjk6
         cTqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david.laight@aculab.com designates 207.82.80.151 as permitted sender) smtp.mailfrom=david.laight@aculab.com
Received: from eu-smtp-delivery-151.mimecast.com (eu-smtp-delivery-151.mimecast.com. [207.82.80.151])
        by mx.google.com with ESMTPS id u71si2804536pgd.455.2019.06.14.08.16.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 08:16:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of david.laight@aculab.com designates 207.82.80.151 as permitted sender) client-ip=207.82.80.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david.laight@aculab.com designates 207.82.80.151 as permitted sender) smtp.mailfrom=david.laight@aculab.com
Received: from AcuMS.aculab.com (156.67.243.126 [156.67.243.126]) (Using
 TLS) by relay.mimecast.com with ESMTP id
 uk-mta-68-X-FdWeQ3PqmiCOAg4_EgNg-1; Fri, 14 Jun 2019 16:16:44 +0100
Received: from AcuMS.Aculab.com (fd9f:af1c:a25b:0:43c:695e:880f:8750) by
 AcuMS.aculab.com (fd9f:af1c:a25b:0:43c:695e:880f:8750) with Microsoft SMTP
 Server (TLS) id 15.0.1347.2; Fri, 14 Jun 2019 16:16:43 +0100
Received: from AcuMS.Aculab.com ([fe80::43c:695e:880f:8750]) by
 AcuMS.aculab.com ([fe80::43c:695e:880f:8750%12]) with mapi id 15.00.1347.000;
 Fri, 14 Jun 2019 16:16:43 +0100
From: David Laight <David.Laight@ACULAB.COM>
To: 'Robin Murphy' <robin.murphy@arm.com>, 'Christoph Hellwig' <hch@lst.de>
CC: Maxime Ripard <maxime.ripard@bootlin.com>, Joonas Lahtinen
	<joonas.lahtinen@linux.intel.com>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
	"linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, David Airlie
	<airlied@linux.ie>, "linux-media@vger.kernel.org"
	<linux-media@vger.kernel.org>, Intel Linux Wireless <linuxwifi@intel.com>,
	"intel-gfx@lists.freedesktop.org" <intel-gfx@lists.freedesktop.org>, "Maarten
 Lankhorst" <maarten.lankhorst@linux.intel.com>, Jani Nikula
	<jani.nikula@linux.intel.com>, Ian Abbott <abbotti@mev.co.uk>, Rodrigo Vivi
	<rodrigo.vivi@intel.com>, Sean Paul <sean@poorly.run>, "moderated list:ARM
 PORT" <linux-arm-kernel@lists.infradead.org>, "netdev@vger.kernel.org"
	<netdev@vger.kernel.org>, "linux-wireless@vger.kernel.org"
	<linux-wireless@vger.kernel.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, H Hartley Sweeten
	<hsweeten@visionengravers.com>, "iommu@lists.linux-foundation.org"
	<iommu@lists.linux-foundation.org>, Daniel Vetter <daniel@ffwll.ch>
Subject: RE: [PATCH 16/16] dma-mapping: use exact allocation in
 dma_alloc_contiguous
Thread-Topic: [PATCH 16/16] dma-mapping: use exact allocation in
 dma_alloc_contiguous
Thread-Index: AQHVIrfpTFjppS25RkWUhwqPPyqZ4qabLzdwgAAQm/2AAAIJEA==
Date: Fri, 14 Jun 2019 15:16:43 +0000
Message-ID: <d8009432a10549bbbda802021562a28b@AcuMS.aculab.com>
References: <20190614134726.3827-1-hch@lst.de>
 <20190614134726.3827-17-hch@lst.de>
 <a90cf7ec5f1c4166b53c40e06d4d832a@AcuMS.aculab.com>
 <20190614145001.GB9088@lst.de> <4113cd5f-5c13-e9c7-bc5e-dcf0b60e7054@arm.com>
In-Reply-To: <4113cd5f-5c13-e9c7-bc5e-dcf0b60e7054@arm.com>
Accept-Language: en-GB, en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-ms-exchange-transport-fromentityheader: Hosted
x-originating-ip: [10.202.205.107]
MIME-Version: 1.0
X-MC-Unique: X-FdWeQ3PqmiCOAg4_EgNg-1
X-Mimecast-Spam-Score: 0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000270, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

RnJvbTogUm9iaW4gTXVycGh5DQo+IFNlbnQ6IDE0IEp1bmUgMjAxOSAxNjowNg0KLi4uDQo+IFdl
bGwsIGFwYXJ0IGZyb20gdGhlIGJpdCBpbiBETUEtQVBJLUhPV1RPIHdoaWNoIGhhcyBzYWlkIHRo
aXMgc2luY2UNCj4gZm9yZXZlciAod2VsbCwgYmVmb3JlIEdpdCBoaXN0b3J5LCBhdCBsZWFzdCk6
DQo+IA0KPiAiVGhlIENQVSB2aXJ0dWFsIGFkZHJlc3MgYW5kIHRoZSBETUEgYWRkcmVzcyBhcmUg
Ym90aA0KPiBndWFyYW50ZWVkIHRvIGJlIGFsaWduZWQgdG8gdGhlIHNtYWxsZXN0IFBBR0VfU0la
RSBvcmRlciB3aGljaA0KPiBpcyBncmVhdGVyIHRoYW4gb3IgZXF1YWwgdG8gdGhlIHJlcXVlc3Rl
ZCBzaXplLiAgVGhpcyBpbnZhcmlhbnQNCj4gZXhpc3RzIChmb3IgZXhhbXBsZSkgdG8gZ3VhcmFu
dGVlIHRoYXQgaWYgeW91IGFsbG9jYXRlIGEgY2h1bmsNCj4gd2hpY2ggaXMgc21hbGxlciB0aGFu
IG9yIGVxdWFsIHRvIDY0IGtpbG9ieXRlcywgdGhlIGV4dGVudCBvZiB0aGUNCj4gYnVmZmVyIHlv
dSByZWNlaXZlIHdpbGwgbm90IGNyb3NzIGEgNjRLIGJvdW5kYXJ5LiINCg0KSSBrbmV3IGl0IHdh
cyBzb21ld2hlcmUgOi0pDQpJbnRlcmVzdGluZ2x5IHRoYXQgYWxzbyBpbXBsaWVzIHRoYXQgdGhl
IGFkZHJlc3MgcmV0dXJuZWQgZm9yIGEgc2l6ZQ0Kb2YgKHNheSkgMTI4IHdpbGwgYWxzbyBiZSBw
YWdlIGFsaWduZWQuDQpJbiB0aGF0IGNhc2UgMTI4IGJ5dGUgYWxpZ25tZW50IHNob3VsZCBwcm9i
YWJseSBiZSBvayAtIGJ1dCBpdCBpcyBzdGlsbA0KYW4gQVBJIGNoYW5nZSB0aGF0IGNvdWxkIGhh
dmUgaG9ycmlkIGNvbnNlcXVlbmNlcy4NCg0KCURhdmlkDQoNCi0NClJlZ2lzdGVyZWQgQWRkcmVz
cyBMYWtlc2lkZSwgQnJhbWxleSBSb2FkLCBNb3VudCBGYXJtLCBNaWx0b24gS2V5bmVzLCBNSzEg
MVBULCBVSw0KUmVnaXN0cmF0aW9uIE5vOiAxMzk3Mzg2IChXYWxlcykNCg==

