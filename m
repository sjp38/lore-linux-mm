Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B38FB6B0033
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 11:47:08 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id t10so7144547pgo.20
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 08:47:08 -0700 (PDT)
Received: from esa5.hgst.iphmx.com (esa5.hgst.iphmx.com. [216.71.153.144])
        by mx.google.com with ESMTPS id k24si289008pff.616.2017.10.19.08.47.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 08:47:06 -0700 (PDT)
From: Bart Van Assche <Bart.VanAssche@wdc.com>
Subject: Re: [PATCH v2 2/3] lockdep: Remove BROKEN flag of
 LOCKDEP_CROSSRELEASE
Date: Thu, 19 Oct 2017 15:47:03 +0000
Message-ID: <1508428021.2429.22.camel@wdc.com>
References: <1508392531-11284-1-git-send-email-byungchul.park@lge.com>
	 <1508392531-11284-3-git-send-email-byungchul.park@lge.com>
	 <1508425527.2429.11.camel@wdc.com>
	 <alpine.DEB.2.20.1710191718260.1971@nanos>
In-Reply-To: <alpine.DEB.2.20.1710191718260.1971@nanos>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <39530C4220687A418C2E4D18327AB09C@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "tglx@linutronix.de" <tglx@linutronix.de>
Cc: "mingo@kernel.org" <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "byungchul.park@lge.com" <byungchul.park@lge.com>, "kernel-team@lge.com" <kernel-team@lge.com>

T24gVGh1LCAyMDE3LTEwLTE5IGF0IDE3OjM0ICswMjAwLCBUaG9tYXMgR2xlaXhuZXIgd3JvdGU6
DQo+IEkgcmVhbGx5IGRpc2FncmVlIHdpdGggeW91ciByZWFzb25pbmcgY29tcGxldGVseQ0KPiAN
Cj4gMSkgV2hlbiBsb2NrZGVwIHdhcyBpbnRyb2R1Y2VkIG1vcmUgdGhhbiB0ZW4geWVhcnMgYWdv
IGl0IHdhcyBmYXIgZnJvbQ0KPiAgICBwZXJmZWN0IGFuZCB3ZSBzcGVudCBhIHJlYXNvbmFibGUg
YW1vdW50IG9mIHRpbWUgdG8gaW1wcm92ZSBpdCwgYW5hbHl6ZQ0KPiAgICBmYWxzZSBwb3NpdGl2
ZXMgYW5kIGFkZCB0aGUgbWlzc2luZyBhbm5vdGF0aW9ucyBhbGwgb3ZlciB0aGUgdHJlZS4gVGhh
dA0KPiAgICB3YXMgYSBwcm9jZXNzIHdoaWNoIHRvb2sgeWVhcnMuDQo+IA0KPiAyKSBTdXJlbHkg
bm9ib2R5IGlzIGludGVyZXN0ZWQgaW4gd2FzdGluZyB0aW1lIG9uIGFuYWx5emluZyBmYWxzZQ0K
PiAgICBwb3NpdGl2ZXMsIGJ1dCB5b3VyIChhbmQgb3RoZXIgcGVvcGxlcykgYXR0aWR1dGUgb2Yg
J25vbmUgb2YgbXkNCj4gICAgYnVzaW5lc3MnIGlzIHdoYXQgbWFrZXMga2VybmVsIGRldmVsb3Bt
ZW50IGV4dHJlbWx5IGZydXN0cmF0aW5nLg0KPiANCj4gICAgSXQgc2hvdWxkIGJlIGluIHRoZSBp
bnRlcmVzdCBvZiBldmVyeWJvZHkgaW52b2x2ZWQgaW4ga2VybmVsIGRldmVsb3BtZW50DQo+ICAg
IHRvIGhlbHAgd2l0aCBpbXByb3Zpbmcgc3VjaCBmZWF0dXJlcyBhbmQgbm90IHRvIGxlYW4gYmFj
ayBhbmQgd2FpdCBmb3INCj4gICAgb3RoZXJzIHRvIGJyaW5nIGl0IGludG8gYSBzaGFwZSB3aGlj
aCBhbGxvd3MgeW91IHRvIHVzZSBpdCBhcyB5b3Ugc2VlDQo+ICAgIGZpdC4NCj4gDQo+IFRoYXQn
cyBub3QgaG93IGNvbW11bml0eSB3b3JrcyBhbmQgbG9ja2RlcCB3b3VsZCBub3QgYmUgaW4gdGhl
IHNoYXBlIGl0IGlzDQo+IHRvZGF5LCBpZiBvbmx5IGEgaGFuZGZ1bCBvZiBwZW9wbGUgd291bGQg
aGF2ZSB1c2VkIGFuZCBpbXByb3ZlZCBpdC4gU3VjaA0KPiB0aGluZ3Mgb25seSB3b3JrIHdoZW4g
dXNlZCB3aWRlbHkgYW5kIHdoZW4gd2UgZ2V0IGVub3VnaCBpbmZvcm1hdGlvbiBzbyB3ZQ0KPiBj
YW4gYWRkcmVzcyB0aGUgd2VhayBzcG90cy4NCg0KSGVsbG8gVGhvbWFzLA0KDQpJdCBzZWVtcyBs
aWtlIHlvdSBhcmUgbWlzc2luZyBteSBwb2ludC4gQ3Jvc3MtcmVsZWFzZSBjaGVja2luZyBpcyBy
ZWFsbHkNCipicm9rZW4qIGFzIGEgY29uY2VwdC4gSXQgaXMgaW1wb3NzaWJsZSB0byBpbXByb3Zl
IGl0IHRvIHRoZSBzYW1lIHJlbGlhYmlsaXR5DQpsZXZlbCBhcyB0aGUga2VybmVsIHY0LjEzIGxv
Y2tkZXAgY29kZS4gSGVuY2UgbXkgcmVxdWVzdCB0byBtYWtlIGl0IHBvc3NpYmxlDQp0byBkaXNh
YmxlIGNyb3NzLXJlbGVhc2UgY2hlY2tpbmcgaWYgUFJPVkVfTE9DS0lORyBpcyBlbmFibGVkLg0K
DQpDb25zaWRlciB0aGUgZm9sbG93aW5nIGV4YW1wbGUgZnJvbSB0aGUgY3Jvc3MtcmVsZWFzZSBk
b2N1bWVudGF0aW9uOg0KDQogICBUQVNLIFgJCQkgICBUQVNLIFkNCiAgIC0tLS0tLQkJCSAgIC0t
LS0tLQ0KCQkJCSAgIGFjcXVpcmUgQVgNCiAgIGFjcXVpcmUgQiAvKiBBIGRlcGVuZGVuY3kgJ0FY
IC0+IEInIGV4aXN0cyAqLw0KICAgcmVsZWFzZSBCDQogICByZWxlYXNlIEFYIGhlbGQgYnkgWQ0K
DQpNeSB1bmRlcnN0YW5kaW5nIGlzIHRoYXQgdGhlIGNyb3NzLXJlbGVhc2UgY29kZSB3aWxsIGFk
ZCAoQVgsIEIpIHRvIHRoZSBsb2NrDQpvcmRlciBncmFwaCBhZnRlciBoYXZpbmcgZW5jb3VudGVy
ZWQgdGhlIGFib3ZlIGNvZGUuIEkgdGhpbmsgdGhhdCdzIHdyb25nDQpiZWNhdXNlIGlmIHRoZSBm
b2xsb3dpbmcgc2VxdWVuY2UgKFk6IGFjcXVpcmUgQVgsIFg6IGFjcXVpcmUgQiwgWDogcmVsZWFz
ZSBCKQ0KaXMgZW5jb3VudGVyZWQgYWdhaW4gdGhhdCB0aGVyZSBpcyBubyBndWFyYW50ZWUgdGhh
dCBBWCBjYW4gb25seSBiZSByZWxlYXNlZA0KYnkgWC4gQW55IHRhc2sgb3RoZXIgdGhhbiBYIGNv
dWxkIHJlbGVhc2UgdGhhdCBzeW5jaHJvbml6YXRpb24gb2JqZWN0IHRvby4NCg0KQmFydC4=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
