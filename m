Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 514046B0005
	for <linux-mm@kvack.org>; Sun, 14 Oct 2018 18:07:30 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id y6-v6so16916741ioc.10
        for <linux-mm@kvack.org>; Sun, 14 Oct 2018 15:07:30 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-oln040092008075.outbound.protection.outlook.com. [40.92.8.75])
        by mx.google.com with ESMTPS id i21-v6si6575682jam.118.2018.10.14.15.07.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Oct 2018 15:07:29 -0700 (PDT)
From: =?utf-8?B?TGVvbmFyZG8gU29hcmVzIE3DvGxsZXI=?= <leozinho29_eu@hotmail.com>
Subject: Re: [Bug 201377] New: Kernel BUG under memory pressure: unable to
 handle kernel NULL pointer dereference at 00000000000000f0
Date: Sun, 14 Oct 2018 22:07:27 +0000
Message-ID: <RO1P152MB14831EA376200DF11577691D97FC0@RO1P152MB1483.LAMP152.PROD.OUTLOOK.COM>
References: <bug-201377-27@https.bugzilla.kernel.org/>
 <20181012155533.2f15a8bb35103aa1fa87962e@linux-foundation.org>
 <20181012155641.b3a1610b4ddcd37e374115d4@linux-foundation.org>
 <9f77da23-2a46-29a5-6aa7-fe9e7cca1056@suse.cz>
 <555fbd1f-4ac9-0b58-dcd4-5dc4380ff7ca@suse.cz>
 <RO1P152MB14838EBA2F5ACD64A1CD3C3697FC0@RO1P152MB1483.LAMP152.PROD.OUTLOOK.COM>
 <863182da-4302-07a5-7280-0c017561b7eb@suse.cz>
In-Reply-To: <863182da-4302-07a5-7280-0c017561b7eb@suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <7EB3526B32A0D947862AC5D5F08F0CA2@LAMP152.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Daniel Colascione <dancol@google.com>, Alexey
 Dobriyan <adobriyan@gmail.com>

SSBtZWFudCBlaWdodGVlbiwgdGhpcyBpcyByaWdodC4gV2hpbGUgSSBza2lwcGVkIDQuMTggZm9y
IG5vcm1hbCB1c2UsIHRvDQpkbyB0ZXN0cyB3aGVuIHRoaXMgaXNzdWUgYXBwZWFyZWQgSSB0ZXN0
ZWQgd2l0aCA0LjE4IHRvbyBhbmQgbm90aWNlZA0KdGhhdCBzaW5jZSA0LjE4LXJjNCB0aGUgaXNz
dWUgZXhpc3QuDQoNClllcywgeW91IGNhbiBhZGQgbWUgdG8gVGVzdGVkLWJ5LCBhcyB0aGlzIHBh
dGNoIHNvbHZlZCB0aGUgaXNzdWUgdG8gbWU6DQpubyBwcm9ibGVtcyB3aXRoIGtlcm5lbCBhbmQg
dGhlIHNjcmlwdCBydW5zIG5vcm1hbGx5LiBUaGFuayB5b3UuDQoNCkVtIDE0LzEwLzIwMTggMTc6
MTQsIFZsYXN0aW1pbCBCYWJrYSBlc2NyZXZldToNCj4gT24gMTAvMTQvMTggODowNyBQTSwgTGVv
bmFyZG8gU29hcmVzIE3DvGxsZXIgd3JvdGU6DQo+PiBUaGlzIHBhdGNoIGFwcGxpZWQgb24gNC4x
OS1yYzcgY29ycmVjdGVkIHRoZSBwcm9ibGVtIHRvIG1lIGFuZCB0aGUNCj4+IHNjcmlwdCBpcyBu
byBsb25nZXIgdHJpZ2dlcmluZyB0aGUga2VybmVsIGJ1Zy4NCj4gDQo+IEdyZWF0ISBDYW4gd2Ug
YWRkIHlvdXIgVGVzdGVkLWJ5OiB0aGVuPw0KPiANCj4+IEkgY29tcGxldGVseSBza2lwcGVkIDQu
MTggYmVjYXVzZSB0aGVyZSB3ZXJlIG11bHRpcGxlIHJlZ3Jlc3Npb25zDQo+PiBhZmZlY3Rpbmcg
bXkgY29tcHV0ZXIuIDQuMTktcmM2IGFuZCA0LjE5LXJjNyBoYXZlIG1vc3QgcmVncmVzc2lvbnMg
Zml4ZWQNCj4+IGJ1dCB0aGVuIHRoaXMgaXNzdWUgYXBwZWFyZWQuDQo+Pg0KPj4gVGhlIGZpcnN0
IGtlcm5lbCB2ZXJzaW9uIHJlbGVhc2VkIEkgZm91bmQgd2l0aCB0aGlzIHByb2JsZW0gaXMgNC4x
OC1yYzQsDQo+IA0KPiBPSywgdGhhdCBjb25maXJtcyB0aGUgc21hcHNfcm9sbHVwIHByb2JsZW0g
aXMgaW5kZWVkIG9sZGVyIHRoYW4gbXkNCj4gcmV3cml0ZS4gVW5sZXNzIGl0J3MgYSB0eXBvIGFu
ZCB5b3UgbWVhbiA0LjE5LXJjNCBzaW5jZSB5b3UgInNraXBwZWQgNC4xOCIuDQo+IA0KPj4gYnV0
IGJpc2VjdGluZyBiZXR3ZWVuIDQuMTgtcmMzIGFuZCA0LjE4LXJjNCBmYWlsZWQ6IG9uIGJvb3Qg
dGhlcmUgd2FzDQo+PiBvbmUgbWVzc2FnZSBzdGFydGluZyB3aXRoIFtVTlNVUFBdIGFuZCB3aXRo
IHNvbWV0aGluZyBhYm91dCAiQXJiaXRyYXJ5DQo+PiBGaWxlIFN5c3RlbSIuDQo+Pg0K
