Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id EB10B8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 15:35:10 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id q11so3443765otl.23
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 12:35:10 -0800 (PST)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-eopbgr810081.outbound.protection.outlook.com. [40.107.81.81])
        by mx.google.com with ESMTPS id y8si43911607otb.143.2019.01.09.12.35.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 09 Jan 2019 12:35:09 -0800 (PST)
From: "Grodzovsky, Andrey" <Andrey.Grodzovsky@amd.com>
Subject: Re: After Vega 56/64 GPU hang I unable reboot system
Date: Wed, 9 Jan 2019 20:35:07 +0000
Message-ID: <5a53e55f-91cf-759e-b52b-f4681083d639@amd.com>
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
In-Reply-To: 
 <CABXGCsPPjz57=Et-V-_iGyY0GrEwfcK2QcRJcqiujUp90zaz-g@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <8D54CDA57E413E4C901AEFA8F6000CF4@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: "Wentland, Harry" <Harry.Wentland@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Koenig, Christian" <Christian.Koenig@amd.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>

DQoNCk9uIDAxLzA5LzIwMTkgMDI6MzYgUE0sIE1pa2hhaWwgR2F2cmlsb3Ygd3JvdGU6DQo+IE9u
IE1vbiwgNyBKYW4gMjAxOSBhdCAyMzo0NywgR3JvZHpvdnNreSwgQW5kcmV5DQo+IDxBbmRyZXku
R3JvZHpvdnNreUBhbWQuY29tPiB3cm90ZToNCj4+IEkgc2VlICdubyBhY3RpdmUgd2F2ZXMnIHBy
aW50IG1lYW5pbmcgaXQncyBub3Qgc2hhZGVyIGhhbmcuDQo+Pg0KPj4gV2UgY2FuIHRyeSBhbmQg
ZXN0aW1hdGUgYXJvdW5kIHdoaWNoIGNvbW1hbmRzIHRoZSBoYW5nIG9jY3VycmVkIC0gaW4NCj4+
IGFkZGl0aW9uIHRvIHdoYXQgeW91IGFscmVhZHkgcHJpbnQgcGxlYXNlIGFsc28gZHVtcA0KPj4N
Cj4+IHN1ZG8gdW1yIC1PIG1hbnksYml0cyAgLXIgKi4qLm1tR1JCTV9TVEFUVVMqICYmIHN1ZG8g
dW1yIC1PIG1hbnksYml0cw0KPj4gLXIgKi4qLm1tQ1BfRU9QXyogJiYgc3VkbyB1bXIgLU8gbWFu
eSxiaXRzIC1yICouKi5tbUNQX1BGUF9IRUFERVJfRFVNUA0KPj4gJiYgc3VkbyB1bXIgLU8gbWFu
eSxiaXRzICAtciAqLioubW1DUF9NRV9IRUFERVJfRFVNUA0KPj4NCj4+IEFuZHJleQ0KPj4NCj4g
QWxsIG5ldyBvbmUgbG9ncyBhdHRhY2hlZCBoZXJlLg0KPg0KPiBUaGFua3MuDQo+DQo+IFAuUy4g
VGhpcyB0aW1lIEkgaGFkIHRvIHRlcm1pbmF0ZSBjb21tYW5kIGAuL3VtciAtTyB2ZXJib3NlLGZv
bGxvdyAtUg0KPiBnZnhbLl0gPiBnZngubG9nIDI+JjFgIGNhdXNlIGl0IHRyaWVkIHRvIHdyaXRl
IGxvZyBpbmZpbml0ZWx5Lg0KPiBJIGFsc28gaGFkIHRvIHRlcm1pbmF0ZSBjb21tYW5kIGAuL3Vt
ciAtTyB2ZXJib3NlLGZvbGxvdyAtUiBnZnhbLl0gPg0KPiBnZngubG9nIDI+JjFgIGNhdXNlIGl0
IHN0dWNrIGZvciBhIGxvbmcgdGltZS4NCj4NCj4NCj4gLS0NCj4gQmVzdCBSZWdhcmRzLA0KPiBN
aWtlIEdhdnJpbG92Lg0KDQpJIHRoaW5rIHRoZSAndmVyYm9zZScgZmxhZyBjYXVzZXMgaXQgZG8g
ZHVtcCBzbyBtdWNoIG91dHB1dCwgbWF5YmUgdHJ5IHdpdGhvdXQgaXQgaW4gQUxMIHRoZSBjb21t
YW5kcyBhYm92ZS4NCkFyZSB5b3UgYXJlIGF3YXJlIG9mIGFueSBwYXJ0aWN1bGFyIGFwcGxpY2F0
aW9uIGR1cmluZyB3aGljaCBydW4gdGhpcyBoYXBwZW5zID8NCg0KQW5kcmV5DQoNCg0K
