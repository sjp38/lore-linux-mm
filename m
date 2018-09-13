Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 374D88E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 17:24:16 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id n23-v6so5931277qkn.19
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 14:24:16 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0116.outbound.protection.outlook.com. [104.47.33.116])
        by mx.google.com with ESMTPS id x67-v6si2065466qka.168.2018.09.13.14.24.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 13 Sep 2018 14:24:15 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH V7 1/2] xxHash: create arch dependent 32/64-bit xxhash()
Date: Thu, 13 Sep 2018 21:24:13 +0000
Message-ID: <4626ba3c-3f7e-b574-d7b0-dc092b026db1@microsoft.com>
References: <20180913211923.7696-1-timofey.titovets@synesis.ru>
 <20180913211923.7696-2-timofey.titovets@synesis.ru>
In-Reply-To: <20180913211923.7696-2-timofey.titovets@synesis.ru>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <64E7A354FDC00E45BA880187C90A01CB@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timofey Titovets <timofey.titovets@synesis.ru>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "rppt@linux.vnet.ibm.com" <rppt@linux.vnet.ibm.com>, Timofey Titovets <nefelim4ag@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, leesioh <solee@os.korea.ac.kr>

DQoNCk9uIDkvMTMvMTggNToxOSBQTSwgVGltb2ZleSBUaXRvdmV0cyB3cm90ZToNCj4gRnJvbTog
VGltb2ZleSBUaXRvdmV0cyA8bmVmZWxpbTRhZ0BnbWFpbC5jb20+DQo+IA0KPiB4eGgzMigpIC0g
ZmFzdCBvbiBib3RoIDMyLzY0LWJpdCBwbGF0Zm9ybXMNCj4geHhoNjQoKSAtIGZhc3Qgb25seSBv
biA2NC1iaXQgcGxhdGZvcm0NCj4gDQo+IENyZWF0ZSB4eGhhc2goKSB3aGljaCB3aWxsIHBpY2t1
cCBmYXN0ZXN0IHZlcnNpb24NCj4gb24gY29tcGlsZSB0aW1lLg0KPiANCj4gQXMgcmVzdWx0IGRl
cGVuZHMgb24gY3B1IHdvcmQgc2l6ZSwNCj4gdGhlIG1haW4gcHJvcG9yc2Ugb2YgdGhhdCAtIGlu
IG1lbW9yeSBoYXNoaW5nLg0KPiANCj4gQ2hhbmdlczoNCj4gICB2MjoNCj4gICAgIC0gQ3JlYXRl
IHRoYXQgcGF0Y2gNCj4gICB2MyAtPiB2NjoNCj4gICAgIC0gTm90aGluZywgd2hvbGUgcGF0Y2hz
ZXQgdmVyc2lvbiBidW1wDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBUaW1vZmV5IFRpdG92ZXRzIDxu
ZWZlbGltNGFnQGdtYWlsLmNvbT4NCg0KUmV2aWV3ZWQtYnk6IFBhdmVsIFRhdGFzaGluIDxwYXZl
bC50YXRhc2hpbkBtaWNyb3NvZnQuY29tPg==
