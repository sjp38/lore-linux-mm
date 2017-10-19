Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A14B06B0038
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 16:41:26 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r6so6846043pfj.14
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 13:41:26 -0700 (PDT)
Received: from esa1.hgst.iphmx.com (esa1.hgst.iphmx.com. [68.232.141.245])
        by mx.google.com with ESMTPS id h128si9851638pfb.194.2017.10.19.13.41.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 13:41:25 -0700 (PDT)
From: Bart Van Assche <Bart.VanAssche@wdc.com>
Subject: Re: [PATCH v2 2/3] lockdep: Remove BROKEN flag of
 LOCKDEP_CROSSRELEASE
Date: Thu, 19 Oct 2017 20:41:23 +0000
Message-ID: <1508445681.2429.61.camel@wdc.com>
References: <1508392531-11284-1-git-send-email-byungchul.park@lge.com>
	 <1508392531-11284-3-git-send-email-byungchul.park@lge.com>
	 <1508425527.2429.11.camel@wdc.com>
	 <alpine.DEB.2.20.1710191718260.1971@nanos>
	 <1508428021.2429.22.camel@wdc.com>
	 <alpine.DEB.2.20.1710192021480.2054@nanos>
	 <alpine.DEB.2.20.1710192107000.2054@nanos>
	 <1508444515.2429.55.camel@wdc.com>
	 <20171019203313.GA10538@bombadil.infradead.org>
In-Reply-To: <20171019203313.GA10538@bombadil.infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <5669043A0A1EFD49A4B7E512BF71109B@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "willy@infradead.org" <willy@infradead.org>
Cc: "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@kernel.org" <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "byungchul.park@lge.com" <byungchul.park@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kernel-team@lge.com" <kernel-team@lge.com>

T24gVGh1LCAyMDE3LTEwLTE5IGF0IDEzOjMzIC0wNzAwLCBNYXR0aGV3IFdpbGNveCB3cm90ZToN
Cj4gRm9yIGV4YW1wbGUsIHRoZSBwYWdlIGxvY2sgaXMgbm90IGFubm90YXRhYmxlIHdpdGggbG9j
a2RlcCAtLSB3ZSByZXR1cm4NCj4gdG8gdXNlcnNwYWNlIHdpdGggaXQgaGVsZCwgZm9yIGhlYXZl
bidzIHNha2UhICBTbyBpdCBpcyBxdWl0ZSBlYXN5IGZvcg0KPiBzb21lb25lIG5vdCBmYW1pbGlh
ciB3aXRoIHRoZSBNTSBsb2NraW5nIGhpZXJhcmNoeSB0byBpbmFkdmVydGVudGx5DQo+IGludHJv
ZHVjZSBhbiBBQkJBIGRlYWRsb2NrIGFnYWluc3QgdGhlIHBhZ2UgbG9jay4gIChpZSBtZS4gIEkg
ZGlkIHRoYXQuKQ0KPiBSaWdodCBub3csIHRoYXQgaGFzIHRvIGJlIGNhdWdodCBieSBhIGh1bWFu
IHJldmlld2VyOyBpZiBjcm9zcy1yZWxlYXNlDQo+IGNoZWNraW5nIGNhbiBjYXRjaCB0aGF0LCB0
aGVuIGl0J3Mgd29ydGggaGF2aW5nLg0KDQpIZWxsbyBNYXR0aGV3LA0KDQpBbHRob3VnaCBJIGFn
cmVlIHRoYXQgZW5hYmxpbmcgbG9jayBpbnZlcnNpb24gY2hlY2tpbmcgZm9yIHBhZ2UgbG9ja3Mg
aXMNCnVzZWZ1bCwgSSB0aGluayBteSBxdWVzdGlvbnMgc3RpbGwgYXBwbHkgdG8gb3RoZXIgbG9j
a2luZyBvYmplY3RzIHRoYW4gcGFnZQ0KbG9ja3MuDQoNClRoYW5rcywNCg0KQmFydC4=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
