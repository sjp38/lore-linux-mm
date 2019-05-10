Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C65CC04AB3
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 08:35:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95BB220850
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 08:35:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95BB220850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D78F46B026F; Fri, 10 May 2019 04:35:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D2A286B026E; Fri, 10 May 2019 04:35:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA3C66B026F; Fri, 10 May 2019 04:35:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 564D36B026D
	for <linux-mm@kvack.org>; Fri, 10 May 2019 04:35:01 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c1so3467957edi.20
        for <linux-mm@kvack.org>; Fri, 10 May 2019 01:35:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language
         :content-transfer-encoding:mime-version;
        bh=eFewvKhne6lSo1eEL1WCPsT1BGy5lsVfjDWbkZAUdts=;
        b=pZ/mPCUMSmuzQa/nUbKnnEy/q79NJWYnHBPLvOoY1l8DTJeuVVmfCJgBN+ZquaMP05
         x+Uxl2M3oR44osQHq+w4otmimLa/8DfESIzY/TG7UdDMXZlICCh3YYR50ILgMc6rbCet
         djYoSYHhZGgoQNIc0esNBXzYz14WqkdHcNl1ig032uCmDghN60xn3bYiwqJsMCrHoga9
         L0QWryAPhPf6pxzOMDWurkDWQfDRoAEeAWYP9n7YJPJa90VtMCpPqVW/qqw3dJHEcxuk
         Do/Qn2grDd5uVlpEinWBWXum/6AUP0mTy5XjxTni/Izbeo4oZUCr7jF/NOZuGz8u5Sa7
         ljlg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of shameerali.kolothum.thodi@huawei.com designates 185.176.76.210 as permitted sender) smtp.mailfrom=shameerali.kolothum.thodi@huawei.com
X-Gm-Message-State: APjAAAWlCdGIkCq8lKqSWriAVOtnNeKsi3oeUTUTqCfnbwOOYV+stjXZ
	yw6ty3J7CxQJ6pshzcD9p59s4TdQkYJyu5Erd72UGpxL6ZECf2y8xzLsU74/jMG7EvZjhN1n61w
	qObeo7YI4jgP4+NtuRkggzFzp+pksg3YPiC38Uhs3FlCESSEOocNEbMurBWstJCmLng==
X-Received: by 2002:a17:906:5587:: with SMTP id y7mr7353700ejp.112.1557477300790;
        Fri, 10 May 2019 01:35:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyJIpBtveLNM1IyI2ZAvxVtKaC3XYR76P+VV6OCSDzJOUkhkhDqwaaCQbWnlK7CEAeQ8Cdn
X-Received: by 2002:a17:906:5587:: with SMTP id y7mr7353621ejp.112.1557477299541;
        Fri, 10 May 2019 01:34:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557477299; cv=none;
        d=google.com; s=arc-20160816;
        b=Syxsw4Zk8qHJ8xE1Vt1fSpm0Cg5FV1xLjhw+bX/jM9pbOo8eC8YgExcC/n4HOLHzhk
         4pvaq002dpOOSx1p2+RloUxA9Fn9wcCzrn4wqe4VAWIG5XiEe3L4S9dl0WaAOx0MH3xg
         h/c0Dq3aI4Q/bw7t6slSGCgdnJkMf5pNAd754APuCATzfl24thODYtgsWN1H9w7iF227
         EgPP199i2QvLo3inU8IaHVjebf1OGhs3MN1LYGaiPLl3kQTefDuBmYemSR90+IGGFqQN
         DHlRkP9dZDeELHt7wbU1roVGlMnAWYCJ6cwkgD8kgqyZD+YtSNZ7hnA9SdsDFFbGxCtm
         oJ/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=eFewvKhne6lSo1eEL1WCPsT1BGy5lsVfjDWbkZAUdts=;
        b=tWhVyKYJ8j8yLK7HW25PSMvQpRrqpr1nftZJPjrPxaQNAeP6hLcKPC0/XDG2VwbZfS
         PqeaQ6JfyTVJpKu8zgMpCWIcV4LN1b5qewfuVrnfqHBggovupMreMhC4Qbi4XAtJkYsf
         CFAw98Elc7K5VFw7IizNPwnQNz+DqFGEYcvKDqIv7KTyYUGWKVxcbSXRGGKmOZFVS9hu
         Llny0gBNc2HfSFwHGAD/0/1pxtBijs3kfl53q0AA99zJcE/tzjXWgOSzL47BN8sBXwlK
         SgrTSENvIrc4VoanEWIEP0rfFXIPYx/OqAeuQ67cSmKR/3k6mfnZ0WnnlFis1B9GK75k
         pniA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of shameerali.kolothum.thodi@huawei.com designates 185.176.76.210 as permitted sender) smtp.mailfrom=shameerali.kolothum.thodi@huawei.com
Received: from huawei.com (lhrrgout.huawei.com. [185.176.76.210])
        by mx.google.com with ESMTPS id x51si3279129edx.75.2019.05.10.01.34.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 01:34:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of shameerali.kolothum.thodi@huawei.com designates 185.176.76.210 as permitted sender) client-ip=185.176.76.210;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of shameerali.kolothum.thodi@huawei.com designates 185.176.76.210 as permitted sender) smtp.mailfrom=shameerali.kolothum.thodi@huawei.com
Received: from lhreml701-cah.china.huawei.com (unknown [172.18.7.108])
	by Forcepoint Email with ESMTP id E16C175825FC1EB19DB1;
	Fri, 10 May 2019 09:34:58 +0100 (IST)
Received: from LHREML524-MBS.china.huawei.com ([169.254.2.137]) by
 lhreml701-cah.china.huawei.com ([10.201.108.42]) with mapi id 14.03.0415.000;
 Fri, 10 May 2019 09:34:50 +0100
From: Shameerali Kolothum Thodi <shameerali.kolothum.thodi@huawei.com>
To: Laszlo Ersek <lersek@redhat.com>, Igor Mammedov <imammedo@redhat.com>
CC: Robin Murphy <robin.murphy@arm.com>, "will.deacon@arm.com"
	<will.deacon@arm.com>, Catalin Marinas <Catalin.Marinas@arm.com>, "Anshuman
 Khandual" <anshuman.khandual@arm.com>, "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, linux-mm <linux-mm@kvack.org>,
	"qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "qemu-arm@nongnu.org"
	<qemu-arm@nongnu.org>, "eric.auger@redhat.com" <eric.auger@redhat.com>,
	"peter.maydell@linaro.org" <peter.maydell@linaro.org>, Linuxarm
	<linuxarm@huawei.com>, "ard.biesheuvel@linaro.org"
	<ard.biesheuvel@linaro.org>, Jonathan Cameron <jonathan.cameron@huawei.com>,
	"xuwei (O)" <xuwei5@huawei.com>
Subject: RE: [Question] Memory hotplug clarification for Qemu ARM/virt
Thread-Topic: [Question] Memory hotplug clarification for Qemu ARM/virt
Thread-Index: AQHVBZyqsUtUKaKFrky+uGhe7FD3haZhnJEAgAFR1ACAAFdrgIAAw4ww
Date: Fri, 10 May 2019 08:34:50 +0000
Message-ID: <5FC3163CFD30C246ABAA99954A238FA83F1DDFE5@lhreml524-mbs.china.huawei.com>
References: <5FC3163CFD30C246ABAA99954A238FA83F1B6A66@lhreml524-mbs.china.huawei.com>
 <ca5f7231-6924-0720-73a5-766eb13ee331@arm.com>
 <190831a5-297d-addb-ea56-645afb169efb@redhat.com>
 <20190509183520.6dc47f2e@Igors-MacBook-Pro>
 <cd2aa867-5367-b470-0a2b-33897697c23f@redhat.com>
In-Reply-To: <cd2aa867-5367-b470-0a2b-33897697c23f@redhat.com>
Accept-Language: en-GB, en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.202.227.237]
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogTGFzemxvIEVyc2VrIFtt
YWlsdG86bGVyc2VrQHJlZGhhdC5jb21dDQo+IFNlbnQ6IDA5IE1heSAyMDE5IDIyOjQ4DQo+IFRv
OiBJZ29yIE1hbW1lZG92IDxpbWFtbWVkb0ByZWRoYXQuY29tPg0KPiBDYzogUm9iaW4gTXVycGh5
IDxyb2Jpbi5tdXJwaHlAYXJtLmNvbT47IFNoYW1lZXJhbGkgS29sb3RodW0gVGhvZGkNCj4gPHNo
YW1lZXJhbGkua29sb3RodW0udGhvZGlAaHVhd2VpLmNvbT47IHdpbGwuZGVhY29uQGFybS5jb207
IENhdGFsaW4NCj4gTWFyaW5hcyA8Q2F0YWxpbi5NYXJpbmFzQGFybS5jb20+OyBBbnNodW1hbiBL
aGFuZHVhbA0KPiA8YW5zaHVtYW4ua2hhbmR1YWxAYXJtLmNvbT47IGxpbnV4LWFybS1rZXJuZWxA
bGlzdHMuaW5mcmFkZWFkLm9yZzsNCj4gbGludXgtbW0gPGxpbnV4LW1tQGt2YWNrLm9yZz47IHFl
bXUtZGV2ZWxAbm9uZ251Lm9yZzsNCj4gcWVtdS1hcm1Abm9uZ251Lm9yZzsgZXJpYy5hdWdlckBy
ZWRoYXQuY29tOyBwZXRlci5tYXlkZWxsQGxpbmFyby5vcmc7DQo+IExpbnV4YXJtIDxsaW51eGFy
bUBodWF3ZWkuY29tPjsgYXJkLmJpZXNoZXV2ZWxAbGluYXJvLm9yZzsgSm9uYXRoYW4NCj4gQ2Ft
ZXJvbiA8am9uYXRoYW4uY2FtZXJvbkBodWF3ZWkuY29tPjsgeHV3ZWkgKE8pIDx4dXdlaTVAaHVh
d2VpLmNvbT4NCj4gU3ViamVjdDogUmU6IFtRdWVzdGlvbl0gTWVtb3J5IGhvdHBsdWcgY2xhcmlm
aWNhdGlvbiBmb3IgUWVtdSBBUk0vdmlydA0KPiANCj4gT24gMDUvMDkvMTkgMTg6MzUsIElnb3Ig
TWFtbWVkb3Ygd3JvdGU6DQo+ID4gT24gV2VkLCA4IE1heSAyMDE5IDIyOjI2OjEyICswMjAwDQo+
ID4gTGFzemxvIEVyc2VrIDxsZXJzZWtAcmVkaGF0LmNvbT4gd3JvdGU6DQo+ID4NCj4gPj4gT24g
MDUvMDgvMTkgMTQ6NTAsIFJvYmluIE11cnBoeSB3cm90ZToNCj4gPj4+IEhpIFNoYW1lZXIsDQo+
ID4+Pg0KPiA+Pj4gT24gMDgvMDUvMjAxOSAxMToxNSwgU2hhbWVlcmFsaSBLb2xvdGh1bSBUaG9k
aSB3cm90ZToNCj4gPj4+PiBIaSwNCj4gPj4+Pg0KPiA+Pj4+IFRoaXMgc2VyaWVzIGhlcmVbMF0g
YXR0ZW1wdHMgdG8gYWRkIHN1cHBvcnQgZm9yIFBDRElNTSBpbiBRRU1VIGZvcg0KPiA+Pj4+IEFS
TS9WaXJ0IHBsYXRmb3JtIGFuZCBoYXMgc3R1bWJsZWQgdXBvbiBhbiBpc3N1ZSBhcyBpdCBpcyBu
b3QgY2xlYXIoYXQNCj4gPj4+PiBsZWFzdA0KPiA+Pj4+IGZyb20gUWVtdS9FREsyIHBvaW50IG9m
IHZpZXcpIGhvdyBpbiBwaHlzaWNhbCB3b3JsZCB0aGUgaG90cGx1Z2dhYmxlDQo+ID4+Pj4gbWVt
b3J5IGlzIGhhbmRsZWQgYnkga2VybmVsLg0KPiA+Pj4+DQo+ID4+Pj4gVGhlIHByb3Bvc2VkIGlt
cGxlbWVudGF0aW9uIGluIFFlbXUsIGJ1aWxkcyB0aGUgU1JBVCBhbmQgRFNEVCBwYXJ0cw0KPiA+
Pj4+IGFuZCB1c2VzIEdFRCBkZXZpY2UgdG8gdHJpZ2dlciB0aGUgaG90cGx1Zy4gVGhpcyB3b3Jr
cyBmaW5lLg0KPiA+Pj4+DQo+ID4+Pj4gQnV0IHdoZW4gd2UgYWRkZWQgdGhlIERUIG5vZGUgY29y
cmVzcG9uZGluZyB0byB0aGUgUENESU1NKGNvbGQgcGx1Zw0KPiA+Pj4+IHNjZW5hcmlvKSwgd2Ug
bm90aWNlZCB0aGF0IEd1ZXN0IGtlcm5lbCBzZWUgdGhpcyBtZW1vcnkgZHVyaW5nIGVhcmx5DQo+
IGJvb3QNCj4gPj4+PiBldmVuIGlmIHdlIGFyZSBib290aW5nIHdpdGggQUNQSS4gQmVjYXVzZSBv
ZiB0aGlzLCBob3RwbHVnZ2FibGUgbWVtb3J5DQo+ID4+Pj4gbWF5IGVuZCB1cCBpbiB6b25lIG5v
cm1hbCBhbmQgbWFrZSBpdCBub24taG90LXVuLXBsdWdnYWJsZSBldmVuIGlmDQo+IEd1ZXN0DQo+
ID4+Pj4gYm9vdHMgd2l0aCBBQ1BJLg0KPiA+Pj4+DQo+ID4+Pj4gRnVydGhlciBkaXNjdXNzaW9u
c1sxXSByZXZlYWxlZCB0aGF0LCBFREsyIFVFRkkgaGFzIG5vIG1lYW5zIHRvDQo+ID4+Pj4gaW50
ZXJwcmV0IHRoZQ0KPiA+Pj4+IEFDUEkgY29udGVudCBmcm9tIFFlbXUodGhpcyBpcyBkZXNpZ25l
ZCB0byBkbyBzbykgYW5kIHVzZXMgRFQgaW5mbyB0bw0KPiA+Pj4+IGJ1aWxkIHRoZSBHZXRNZW1v
cnlNYXAoKS4gVG8gc29sdmUgdGhpcywgaW50cm9kdWNlZCAiaG90cGx1Z2dhYmxlIg0KPiA+Pj4+
IHByb3BlcnR5DQo+ID4+Pj4gdG8gRFQgbWVtb3J5IG5vZGUocGF0Y2hlcyAjNyAmICM4IGZyb20g
WzBdKSBzbyB0aGF0IFVFRkkgY2FuDQo+ID4+Pj4gZGlmZmVyZW50aWF0ZQ0KPiA+Pj4+IHRoZSBu
b2RlcyBhbmQgZXhjbHVkZSB0aGUgaG90cGx1Z2dhYmxlIG9uZXMgZnJvbSBHZXRNZW1vcnlNYXAo
KS4NCj4gPj4+Pg0KPiA+Pj4+IEJ1dCB0aGVuIExhc3psbyByaWdodGx5IHBvaW50ZWQgb3V0IHRo
YXQgaW4gb3JkZXIgdG8gYWNjb21tb2RhdGUgdGhlDQo+ID4+Pj4gY2hhbmdlcw0KPiA+Pj4+IGlu
dG8gVUVGSSB3ZSBuZWVkIHRvIGtub3cgaG93IGV4YWN0bHkgTGludXggZXhwZWN0cy9oYW5kbGVz
IGFsbCB0aGUNCj4gPj4+PiBob3RwbHVnZ2FibGUgbWVtb3J5IHNjZW5hcmlvcy4gUGxlYXNlIGZp
bmQgdGhlIGRpc2N1c3Npb24gaGVyZVsyXS4NCj4gPj4+Pg0KPiA+Pj4+IEZvciBlYXNlLCBJIGFt
IGp1c3QgY29weWluZyB0aGUgcmVsZXZhbnQgY29tbWVudCBmcm9tIExhc3psbyBiZWxvdywNCj4g
Pj4+Pg0KPiA+Pj4+IC8qKioqKioNCj4gPj4+PiAiR2l2ZW4gcGF0Y2hlcyAjNyBhbmQgIzgsIGFz
IEkgdW5kZXJzdGFuZCB0aGVtLCB0aGUgZmlybXdhcmUgY2Fubm90DQo+ID4+Pj4gZGlzdGluZ3Vp
c2gNCj4gPj4+PiDCoCBob3RwbHVnZ2FibGUgJiBwcmVzZW50LCBmcm9tIGhvdHBsdWdnYWJsZSAm
IGFic2VudC4gVGhlIGZpcm13YXJlDQo+IGNhbg0KPiA+Pj4+IG9ubHkNCj4gPj4+PiDCoCBza2lw
IGJvdGggaG90cGx1Z2dhYmxlIGNhc2VzLiBUaGF0J3MgZmluZSBpbiB0aGF0IHRoZSBmaXJtd2Fy
ZSB3aWxsDQo+ID4+Pj4gaG9nIG5laXRoZXINCj4gPj4+PiDCoCB0eXBlIC0tIGJ1dCBpcyB0aGF0
IE9LIGZvciB0aGUgT1MgYXMgd2VsbCwgZm9yIGJvdGggQUNQSSBib290IGFuZCBEVA0KPiA+Pj4+
IGJvb3Q/DQo+ID4+Pj4NCj4gPj4+PiBDb25zaWRlciBpbiBwYXJ0aWN1bGFyIHRoZSAiaG90cGx1
Z2dhYmxlICYgcHJlc2VudCwgQUNQSSBib290IiBjYXNlLg0KPiA+Pj4+IEFzc3VtaW5nDQo+ID4+
Pj4gd2UgbW9kaWZ5IHRoZSBmaXJtd2FyZSB0byBza2lwICJob3RwbHVnZ2FibGUiIGFsdG9nZXRo
ZXIsIHRoZSBVRUZJDQo+IG1lbW1hcA0KPiA+Pj4+IHdpbGwgbm90IGluY2x1ZGUgdGhlIHJhbmdl
IGRlc3BpdGUgaXQgYmVpbmcgcHJlc2VudCBhdCBib290Lg0KPiA+Pj4+IFByZXN1bWFibHksIEFD
UEkNCj4gPj4+PiB3aWxsIHJlZmVyIHRvIHRoZSByYW5nZSBzb21laG93LCBob3dldmVyLiBXaWxs
IHRoYXQgbm90IGNvbmZ1c2UgdGhlIE9TPw0KPiA+Pj4+DQo+ID4+Pj4gV2hlbiBJZ29yIHJhaXNl
ZCB0aGlzIGVhcmxpZXIsIEkgc3VnZ2VzdGVkIHRoYXQNCj4gPj4+PiBob3RwbHVnZ2FibGUtYW5k
LXByZXNlbnQgc2hvdWxkDQo+ID4+Pj4gYmUgYWRkZWQgYnkgdGhlIGZpcm13YXJlLCBidXQgYWxz
byBhbGxvY2F0ZWQgaW1tZWRpYXRlbHksIGFzDQo+ID4+Pj4gRWZpQm9vdFNlcnZpY2VzRGF0YQ0K
PiA+Pj4+IHR5cGUgbWVtb3J5LiBUaGlzIHdpbGwgcHJldmVudCBvdGhlciBkcml2ZXJzIGluIHRo
ZSBmaXJtd2FyZSBmcm9tDQo+ID4+Pj4gYWxsb2NhdGluZyBBY3BpTlZTDQo+ID4+Pj4gb3IgUmVz
ZXJ2ZWQgY2h1bmtzIGZyb20gdGhlIHNhbWUgbWVtb3J5IHJhbmdlLCB0aGUgVUVGSSBtZW1tYXAg
d2lsbA0KPiA+Pj4+IGNvbnRhaW4NCj4gPj4+PiB0aGUgcmFuZ2UgYXMgRWZpQm9vdFNlcnZpY2Vz
RGF0YSwgYW5kIHRoZW4gdGhlIE9TIGNhbiByZWxlYXNlIHRoYXQNCj4gPj4+PiBhbGxvY2F0aW9u
IGluDQo+ID4+Pj4gb25lIGdvIGVhcmx5IGR1cmluZyBib290Lg0KPiA+Pj4+DQo+ID4+Pj4gQnV0
IHRoaXMgcmVhbGx5IGhhcyB0byBiZSBjbGFyaWZpZWQgZnJvbSB0aGUgTGludXgga2VybmVsJ3MN
Cj4gPj4+PiBleHBlY3RhdGlvbnMuIFBsZWFzZQ0KPiA+Pj4+IGZvcm1hbGl6ZSBhbGwgb2YgdGhl
IGZvbGxvd2luZyBjYXNlczoNCj4gPj4+Pg0KPiA+Pj4+IE9TIGJvb3QgKERUL0FDUEkpwqAgaG90
cGx1Z2dhYmxlICYgLi4uwqAgR2V0TWVtb3J5TWFwKCkgc2hvdWxkIHJlcG9ydA0KPiA+Pj4+IGFz
wqAgRFQvQUNQSSBzaG91bGQgcmVwb3J0IGFzDQo+ID4+Pj4gLS0tLS0tLS0tLS0tLS0tLS3CoCAt
LS0tLS0tLS0tLS0tLS0tLS0NCj4gPj4+PiAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
wqAgLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tDQo+ID4+Pj4NCj4gRFTCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoCBwcmVzZW50wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgID8NCj4gwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqAgPw0KPiA+Pj4+DQo+IERUwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqAgYWJzZW50wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqAgPw0KPiDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgID8NCj4gPj4+Pg0KPiBBQ1BJwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoCBwcmVzZW50wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgID8NCj4gwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqAgPw0KPiA+Pj4+DQo+IEFDUEnCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgIGFic2VudMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgID8NCj4gwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqAgPw0KPiA+Pj4+DQo+ID4+Pj4gQWdhaW4sIHRoaXMgdGFibGUgaXMg
ZGljdGF0ZWQgYnkgTGludXguIg0KPiA+Pj4+DQo+ID4+Pj4gKioqKioqLw0KPiA+Pj4+DQo+ID4+
Pj4gQ291bGQgeW91IHBsZWFzZSB0YWtlIGEgbG9vayBhdCB0aGlzIGFuZCBsZXQgdXMga25vdyB3
aGF0IGlzIGV4cGVjdGVkDQo+ID4+Pj4gaGVyZSBmcm9tDQo+ID4+Pj4gYSBMaW51eCBrZXJuZWwg
dmlldyBwb2ludC4NCj4gPj4+DQo+ID4+PiBGb3IgYXJtNjQsIHNvIGZhciB3ZSd2ZSBub3QgZXZl
biBiZWVuIGNvbnNpZGVyaW5nIERULWJhc2VkIGhvdHBsdWcgLSBhcw0KPiA+Pj4gZmFyIGFzIEkn
bSBhd2FyZSB0aGVyZSB3b3VsZCBzdGlsbCBiZSBhIGJpZyBvcGVuIHF1ZXN0aW9uIHRoZXJlIGFy
b3VuZA0KPiA+Pj4gbm90aWZpY2F0aW9uIG1lY2hhbmlzbXMgYW5kIGhvdyB0byBkZXNjcmliZSB0
aGVtLiBUaGUgRFQgc3R1ZmYgc28gZmFyDQo+ID4+PiBoYXMgY29tZSBmcm9tIHRoZSBQb3dlclBD
IGZvbGtzLCBzbyBpdCdzIHByb2JhYmx5IHdvcnRoIHNlZWluZyB3aGF0DQo+ID4+PiB0aGVpciBp
ZGVhcyBhcmUuDQo+ID4+Pg0KPiA+Pj4gQUNQSS13aXNlIEkndmUgYWx3YXlzIGFzc3VtZWQvaG9w
ZWQgdGhhdCBob3RwbHVnLXJlbGF0ZWQgdGhpbmdzIHNob3VsZA0KPiA+Pj4gYmUgc3VmZmljaWVu
dGx5IHdlbGwtc3BlY2lmaWVkIGluIFVFRkkgdGhhdCAiZG8gd2hhdGV2ZXIgeDg2L0lBLTY0IGRv
Ig0KPiA+Pj4gd291bGQgYmUgZW5vdWdoIGZvciB1cy4NCj4gPj4NCj4gPj4gQXMgZmFyIGFzIEkg
Y2FuIHNlZSBpbiBVRUZJIHYyLjggLS0gYW5kIEkgaGFkIGNoZWNrZWQgdGhlIHNwZWMgYmVmb3Jl
DQo+ID4+IGR1bXBpbmcgdGhlIHRhYmxlIHdpdGggdGhlIG1hbnkgcXVlc3Rpb24gbWFya3Mgb24g
U2hhbWVlciAtLSwgYWxsIHRoZQ0KPiA+PiBob3QtcGx1ZyBsYW5ndWFnZSBpbiB0aGUgc3BlYyBy
ZWZlcnMgdG8gVVNCIGFuZCBQQ0kgaG90LXBsdWcgaW4gdGhlDQo+ID4+IHByZWJvb3QgZW52aXJv
bm1lbnQuIFRoZXJlIGlzIG5vdCBhIHNpbmdsZSB3b3JkIGFib3V0IGhvdC1wbHVnIGF0IE9TDQo+
ID4+IHJ1bnRpbWUgKHJlZ2FyZGluZyBhbnkgZGV2aWNlIG9yIGNvbXBvbmVudCB0eXBlKSwgbm9y
IGFib3V0IG1lbW9yeQ0KPiA+PiBob3QtcGx1ZyAoYXQgYW55IHRpbWUpLg0KPiA+Pg0KPiA+PiBM
b29raW5nIHRvIHg4NiBhcHBlYXJzIHZhbGlkIC0tIHNvIHdoYXQgZG9lcyB0aGUgTGludXgga2Vy
bmVsIGV4cGVjdCBvbg0KPiA+PiB0aGF0IGFyY2hpdGVjdHVyZSwgaW4gdGhlICJBQ1BJIiByb3dz
IG9mIHRoZSB0YWJsZT8NCj4gPg0KPiA+IEkgY291bGQgb25seSBhbnN3ZXIgZnJvbSBRRU1VIHg4
NiBwZXJzcGVjdGl2ZS4NCj4gPiBRRU1VIGZvciB4ODYgZ3Vlc3RzIGN1cnJlbnRseSBkb2Vzbid0
IGFkZCBob3QtcGx1Z2dhYmxlIFJBTSBpbnRvIEU4MjANCj4gPiBiZWNhdXNlIG9mIGRpZmZlcmVu
dCBsaW51eCBndWVzdHMgdGVuZCB0byBjYW5uaWJhbGl6ZSBpdCwgbWFraW5nIGl0IG5vbg0KPiA+
IHVucGx1Z2dhYmxlLiBUaGUgbGFzdCBjdWxwcml0IEkgcmVjYWxsIHdhcyBLQVNMUi4NCj4gPg0K
PiA+IFNvIEknZCByZWZyYWluIGZyb20gcmVwb3J0aW5nIGhvdHBsdWdnYWJsZSBSQU0gaW4gR2V0
TWVtb3J5TWFwKCkgaWYNCj4gPiBpdCdzIHBvc3NpYmxlIChpdCdzIHByb2JhYmx5IGhhY2sgKHNw
ZWMgZGVvc24ndCBzYXkgYW55dGhpbmcgYWJvdXQgaXQpDQo+ID4gYnV0IGl0IG1vc3RseSB3b3Jr
cyBmb3IgTGludXggKHBsdWcvdW5wbHVnKSBhbmQgV2luZG93cyBndWVzdCBhbHNvDQo+ID4gZmlu
ZSB3aXRoIHBsdWcgcGFydCAobm8gdW5wbHVnIHRoZXJlKSkuDQo+IA0KPiBJIGNhbiBhY2NlcHQg
dGhpcyBhcyBhIHBlcmZlY3RseSB2YWxpZCBkZXNpZ24uIFdoaWNoIHdvdWxkIG1lYW4sIFFFTVUg
c2hvdWxkDQo+IG1hcmsgZWFjaCBob3RwbHVnZ2FibGUgUkFNIHJhbmdlIGluIHRoZSBEVEIgZm9y
IHRoZSBmaXJtd2FyZSB3aXRoIHRoZQ0KPiBzcGVjaWFsIG5ldyBwcm9wZXJ0eSwgcmVnYXJkbGVz
cyBvZiBpdHMgaW5pdGlhbCAoImNvbGQiKSBwbHVnZ2VkLW5lc3MsIGFuZCB0aGVuDQo+IHRoZSBm
aXJtd2FyZSB3aWxsIG5vdCBleHBvc2UgdGhlIHJhbmdlIGluIHRoZSBHQ0QgbWVtb3J5IHNwYWNl
IG1hcCwgYW5kDQo+IGNvbnNlcXVlbnRseSBpbiB0aGUgVUVGSSBtZW1tYXAgZWl0aGVyLg0KPiAN
Cj4gSU9XLCBvdXIgdGFibGUgaXMsIHRodXMgZmFyOg0KPiANCj4gT1MgYm9vdCAoRFQvQUNQSSkg
IGhvdHBsdWdnYWJsZSAmIC4uLiAgR2V0TWVtb3J5TWFwKCkgc2hvdWxkIHJlcG9ydCBhcw0KPiBE
VC9BQ1BJIHNob3VsZCByZXBvcnQgYXMNCj4gLS0tLS0tLS0tLS0tLS0tLS0gIC0tLS0tLS0tLS0t
LS0tLS0tLSAgLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLSAgLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tDQo+IERUICAgICAgICAgICAgICAgICBwcmVzZW50DQo+IEFCU0VOVCAgICAgICAg
ICAgICAgICAgICAgICAgICAgID8NCj4gRFQgICAgICAgICAgICAgICAgIGFic2VudA0KPiBBQlNF
TlQgICAgICAgICAgICAgICAgICAgICAgICAgICA/DQo+IEFDUEkgICAgICAgICAgICAgICBwcmVz
ZW50ICAgICAgICAgICAgIEFCU0VOVA0KPiBQUkVTRU5UDQo+IEFDUEkgICAgICAgICAgICAgICBh
YnNlbnQgICAgICAgICAgICAgIEFCU0VOVA0KPiBBQlNFTlQNCj4gSW4gdGhlIGZpcm13YXJlLCBJ
IG9ubHkgbmVlZCB0byBjYXJlIGFib3V0IHRoZSBHZXRNZW1vcnlNYXAoKSBjb2x1bW4sIHNvIEkN
Cj4gY2FuIHdvcmsgd2l0aCB0aGlzLg0KDQpUaGFuayB5b3UgYWxsIGZvciB0aGUgaW5wdXRzLg0K
DQpJIGFzc3VtZSB3ZSB3aWxsIHN0aWxsIHJlcG9ydCB0aGUgRFQgY29sZCBwbHVnIGNhc2UgdG8g
a2VybmVsKGhvdHBsdWdnYWJsZSAmIHByZXNlbnQpLg0Kc28gdGhlIHRhYmxlIHdpbGwgYmUgc29t
ZXRoaW5nIGxpa2UgdGhpcywNCg0KT1MgYm9vdCAoRFQvQUNQSSkgIGhvdHBsdWdnYWJsZSAmIC4u
LiAgR2V0TWVtb3J5TWFwKCkgc2hvdWxkIHJlcG9ydCBhcyAgRFQvQUNQSSBzaG91bGQgcmVwb3J0
IGFzDQotLS0tLS0tLS0tLS0tLS0tLSAgLS0tLS0tLS0tLS0tLS0tLS0tICAtLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tICAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0NCkRUICAgICAgICAg
ICAgICAgICBwcmVzZW50ICAgICAgICAgICAgIEFCU0VOVCAgICAgICAgICAgICAgICAgICAgICAg
ICAgIFBSRVNFTlQNCkRUICAgICAgICAgICAgICAgICBhYnNlbnQgICAgICAgICAgICAgIEFCU0VO
VCAgICAgICAgICAgICAgICAgICAgICAgICAgIEFCU0VOVA0KQUNQSSAgICAgICAgICAgICAgIHBy
ZXNlbnQgICAgICAgICAgICAgQUJTRU5UICAgICAgICAgICAgICAgICAgICAgICAgICAgUFJFU0VO
VA0KQUNQSSAgICAgICAgICAgICAgIGFic2VudCAgICAgICAgICAgICAgQUJTRU5UICAgICAgICAg
ICAgICAgICAgICAgICAgICAgQUJTRU5UIA0KDQoNCiBDYW4gc29tZW9uZSBwbGVhc2UgZmlsZSBh
IGZlYXR1cmUgcmVxdWVzdCBhdA0KPiA8aHR0cHM6Ly9idWd6aWxsYS50aWFub2NvcmUub3JnLz4s
IGZvciB0aGUgQXJtVmlydFBrZyBQYWNrYWdlLCB3aXRoIHRoZXNlDQo+IGRldGFpcz8NCg0KT2su
IEkgd2lsbCBkbyB0aGF0Lg0KDQpUaGFua3MsDQpTaGFtZWVyDQoNCj4gVGhhbmtzDQo+IExhc3ps
bw0KPiANCj4gPg0KPiA+IEFzIGZvciBwaHlzaWNhbCBzeXN0ZW1zLCB0aGVyZSBhcmUgb3V0IHRo
ZXJlIG9uZXMgdGhhdCBkbyByZXBvcnQNCj4gPiBob3RwbHVnZ2FibGUgUkFNIGluIEdldE1lbW9y
eU1hcCgpLg0KPiA+DQo+ID4+IFNoYW1lZXI6IGlmIHlvdSAoSHVhd2VpKSBhcmUgcmVwcmVzZW50
ZWQgb24gdGhlIFVTV0cgLyBBU1dHLCBJIHN1Z2dlc3QNCj4gPj4gcmUtcmFpc2luZyB0aGUgcXVl
c3Rpb24gb24gdGhvc2UgbGlzdHMgdG9vOyBhdCBsZWFzdCB0aGUgIkFDUEkiIHJvd3Mgb2YNCj4g
Pj4gdGhlIHRhYmxlLg0KPiA+Pg0KPiA+PiBUaGFua3MhDQo+ID4+IExhc3psbw0KPiA+Pg0KPiA+
Pj4NCj4gPj4+IFJvYmluLg0KPiA+Pj4NCj4gPj4+PiAoSGkgTGFzemxvL0lnb3IvRXJpYywgcGxl
YXNlIGZlZWwgZnJlZSB0byBhZGQvY2hhbmdlIGlmIEkgaGF2ZSBtaXNzZWQNCj4gPj4+PiBhbnkg
dmFsaWQNCj4gPj4+PiBwb2ludHMgYWJvdmUpLg0KPiA+Pj4+DQo+ID4+Pj4gVGhhbmtzLA0KPiA+
Pj4+IFNoYW1lZXINCj4gPj4+PiBbMF0gaHR0cHM6Ly9wYXRjaHdvcmsua2VybmVsLm9yZy9jb3Zl
ci8xMDg5MDkxOS8NCj4gPj4+PiBbMV0gaHR0cHM6Ly9wYXRjaHdvcmsua2VybmVsLm9yZy9wYXRj
aC8xMDg2MzI5OS8NCj4gPj4+PiBbMl0gaHR0cHM6Ly9wYXRjaHdvcmsua2VybmVsLm9yZy9wYXRj
aC8xMDg5MDkzNy8NCj4gPj4+Pg0KPiA+Pj4+DQo+ID4+DQo+ID4NCg0K

