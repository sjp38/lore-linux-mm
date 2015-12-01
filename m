Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id F16036B0253
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 15:35:21 -0500 (EST)
Received: by pacej9 with SMTP id ej9so15912643pac.2
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 12:35:21 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id n88si10661999pfb.56.2015.12.01.12.35.20
        for <linux-mm@kvack.org>;
        Tue, 01 Dec 2015 12:35:21 -0800 (PST)
Date: Tue, 01 Dec 2015 15:35:17 -0500 (EST)
Message-Id: <20151201.153517.224543138214404348.davem@davemloft.net>
Subject: Re: [PATCH] Improve Atheros ethernet driver not to do order 4
 GFP_ATOMIC allocation
From: David Miller <davem@davemloft.net>
In-Reply-To: <20151130132129.GB21950@dhcp22.suse.cz>
References: <20151127082010.GA2500@dhcp22.suse.cz>
	<20151128145113.GB4135@amd>
	<20151130132129.GB21950@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: pavel@ucw.cz, akpm@osdl.org, linux-kernel@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com, netdev@vger.kernel.org, rjw@rjwysocki.net, linux-mm@kvack.org, nic-devel@qualcomm.com, ronangeles@gmail.com, ebiederm@xmission.com

RnJvbTogTWljaGFsIEhvY2tvIDxtaG9ja29Aa2VybmVsLm9yZz4NCkRhdGU6IE1vbiwgMzAgTm92
IDIwMTUgMTQ6MjE6MjkgKzAxMDANCg0KPiBPbiBTYXQgMjgtMTEtMTUgMTU6NTE6MTMsIFBhdmVs
IE1hY2hlayB3cm90ZToNCj4+IA0KPj4gYXRsMWMgZHJpdmVyIGlzIGRvaW5nIG9yZGVyLTQgYWxs
b2NhdGlvbiB3aXRoIEdGUF9BVE9NSUMNCj4+IHByaW9yaXR5LiBUaGF0IG9mdGVuIGJyZWFrcyAg
bmV0d29ya2luZyBhZnRlciByZXN1bWUuIFN3aXRjaCB0bw0KPj4gR0ZQX0tFUk5FTC4gU3RpbGwg
bm90IGlkZWFsLCBidXQgc2hvdWxkIGJlIHNpZ25pZmljYW50bHkgYmV0dGVyLg0KPiANCj4gSXQg
aXMgbm90IGNsZWFyIHdoeSBHRlBfS0VSTkVMIGNhbiByZXBsYWNlIEdGUF9BVE9NSUMgc2FmZWx5
IG5laXRoZXINCj4gZnJvbSB0aGUgY2hhbmdlbG9nIG5vciBmcm9tIHRoZSBwYXRjaCBjb250ZXh0
Lg0KDQpFYXJsaWVyIGluIHRoZSBmdW5jdGlvbiB3ZSBkbyBhIEdGUF9LRVJORUwga21hbGxvYyBz
bzogDQoNCsKvXF8o44OEKV8vwq8NCg0KSXQgc2hvdWxkIGJlIGZpbmUuDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
