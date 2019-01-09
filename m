Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3A7D88E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 16:48:45 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id w15so8734584ita.1
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 13:48:45 -0800 (PST)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-eopbgr790082.outbound.protection.outlook.com. [40.107.79.82])
        by mx.google.com with ESMTPS id v197si6332016ita.138.2019.01.09.13.48.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 09 Jan 2019 13:48:43 -0800 (PST)
From: "Grodzovsky, Andrey" <Andrey.Grodzovsky@amd.com>
Subject: Re: After Vega 56/64 GPU hang I unable reboot system
Date: Wed, 9 Jan 2019 21:48:40 +0000
Message-ID: <44411354-0f2d-8c4d-ac6b-beff18db1252@amd.com>
References: 
 <CABXGCsPu3g8WZXV1RpggLFuL3bgofmXMs1SiPyYnPyEOW7t3Dg@mail.gmail.com>
 <24702c72-cc06-1b54-0ab9-6d2409362c27@amd.com>
 <CABXGCsMPjKnCb7hpuenL5q3_HJgoGW=VB9FRrBpJsZMtA7LxpA@mail.gmail.com>
 <3ffe451b-1f17-23a5-985b-28d26fbaf7da@amd.com>
 <09781f6e-5ea3-ccfd-1aa2-79941b089863@amd.com>
 <CABXGCsPCACOhOo4DTCiOam65SiOiudrKpn5vKAL72bV6iGo9vA@mail.gmail.com>
 <CABXGCsMMSMJuURyhBQC3GuZc7m6Wq7FH=8_rpSWHrZT-0dJeGA@mail.gmail.com>
 <e1ced25f-4f35-320b-5208-7e1ca3565a3a@amd.com>
 <CABXGCsPPjz57=Et-V-_iGyY0GrEwfcK2QcRJcqiujUp90zaz-g@mail.gmail.com>
 <5a53e55f-91cf-759e-b52b-f4681083d639@amd.com>
 <CABXGCsMKMgzQBr4_QchVyc9JaN64cqDEY5dv29oRE5qhkaHH3g@mail.gmail.com>
In-Reply-To: 
 <CABXGCsMKMgzQBr4_QchVyc9JaN64cqDEY5dv29oRE5qhkaHH3g@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <E482844C298557409E4F959676ED1267@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: "Wentland, Harry" <Harry.Wentland@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Koenig, Christian" <Christian.Koenig@amd.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>

Q2FuIHlvdSBsYXVuY2ggUG90b24gZnJvbSBjb21tYW5kIGxpbmUgYXBwZW5kaW5nIEdBTExJVU1f
RERFQlVHPTEwMDAgDQpiZWZvcmUgdGhlIGNvbW1hbmQgPyBUaGlzIHNob3VsZCBjcmVhdGUgTUVT
QSBkZWJ1ZyBpbmZvIGluIH4vZGRlYnVnX2R1bXBzLw0KDQpBbmRyZXkNCg0KDQpPbiAwMS8wOS8y
MDE5IDA0OjEyIFBNLCBNaWtoYWlsIEdhdnJpbG92IHdyb3RlOg0KPiBPbiBUaHUsIDEwIEphbiAy
MDE5IGF0IDAxOjM1LCBHcm9kem92c2t5LCBBbmRyZXkNCj4gPEFuZHJleS5Hcm9kem92c2t5QGFt
ZC5jb20+IHdyb3RlOg0KPj4gSSB0aGluayB0aGUgJ3ZlcmJvc2UnIGZsYWcgY2F1c2VzIGl0IGRv
IGR1bXAgc28gbXVjaCBvdXRwdXQsIG1heWJlIHRyeSB3aXRob3V0IGl0IGluIEFMTCB0aGUgY29t
bWFuZHMgYWJvdmUuDQo+PiBBcmUgeW91IGFyZSBhd2FyZSBvZiBhbnkgcGFydGljdWxhciBhcHBs
aWNhdGlvbiBkdXJpbmcgd2hpY2ggcnVuIHRoaXMgaGFwcGVucyA/DQo+Pg0KPiBMYXN0IGxvZ3Mg
cmVsYXRlZCB0byBzaXR1YXRpb24gd2hlbiBJIGxhdW5jaCB0aGUgZ2FtZSAiU2hhZG93IG9mIHRo
ZQ0KPiBUb21iIFJhaWRlciIgdmlhIHByb3RvbiAzLjE2LTE2Lg0KPiBPY2N1cnMgZXZlcnkgdGlt
ZSB3aGVuIHRoZSBnYW1lIG1lbnUgc2hvdWxkIGFwcGVhciBhZnRlciBnYW1lIGxhdW5jaGluZy4N
Cj4NCj4gLS0NCj4gQmVzdCBSZWdhcmRzLA0KPiBNaWtlIEdhdnJpbG92Lg0KDQo=
