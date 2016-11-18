Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 738186B039B
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 23:24:52 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id b202so198963773oii.3
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 20:24:52 -0800 (PST)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0101.outbound.protection.outlook.com. [104.47.38.101])
        by mx.google.com with ESMTPS id u136si2431285oie.38.2016.11.17.20.24.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 17 Nov 2016 20:24:51 -0800 (PST)
From: Matthew Wilcox <mawilcox@microsoft.com>
Subject: RE: [PATCH 00/29] Improve radix tree for 4.10
Date: Fri, 18 Nov 2016 04:24:49 +0000
Message-ID: <SN1PR21MB007739A54B36636114561FB4CBB00@SN1PR21MB0077.namprd21.prod.outlook.com>
References: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
 <1479341856-30320-37-git-send-email-mawilcox@linuxonhyperv.com>
 <20161117221738.GA2738@linux.intel.com>
In-Reply-To: <20161117221738.GA2738@linux.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <mawilcox@linuxonhyperv.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew
 Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

RnJvbTogUm9zcyBad2lzbGVyIFttYWlsdG86cm9zcy56d2lzbGVyQGxpbnV4LmludGVsLmNvbV0N
Cj4gT24gV2VkLCBOb3YgMTYsIDIwMTYgYXQgMDQ6MTc6MDFQTSAtMDgwMCwgTWF0dGhldyBXaWxj
b3ggd3JvdGU6DQo+ID4gRnJvbTogTWF0dGhldyBXaWxjb3ggPG1hd2lsY294QG1pY3Jvc29mdC5j
b20+DQo+ID4NCj4gPiBIaSBBbmRyZXcsDQo+ID4NCj4gPiBQbGVhc2UgaW5jbHVkZSB0aGVzZSBw
YXRjaGVzIGluIHRoZSAtbW0gdHJlZSBmb3IgNC4xMC4gIE1vc3RseSB0aGVzZSBhcmUNCj4gPiBp
bXByb3ZlbWVudHM7IHRoZSBvbmx5IGJ1ZyBmaXhlcyBpbiBoZXJlIHJlbGF0ZSB0byBtdWx0aW9y
ZGVyIGVudHJpZXMNCj4gPiAod2hpY2ggYXMgZmFyIGFzIEknbSBhd2FyZSByZW1haW4gdW51c2Vk
KS4NCj4gDQo+IE15IERBWCBQTUQgcGF0Y2hlcyB1c2UgbXVsdGlvcmRlciBlbnRyaWVzLCBhbmQg
YXJlIHF1ZXVlZCBmb3IgdjQuMTAgbWVyZ2U6DQoNClRoYXQncyBncmVhdDsgdGhlIHBvaW50IHRo
YXQgSSB3YXMgdHJ5aW5nIHRvIG1ha2Ugd2FzIHRoYXQgd2hpbGUgdGhlcmUgYXJlIGluZGVlZCBi
dWcgZml4ZXMgaW4gdGhlIHBhdGNoZXMsIHRoZXkncmUgbGF0ZW50IGJ1Z3MgYmVjYXVzZSB0aGVy
ZSBhcmUgbm8gY3VycmVudCB1c2VycyBpbiB0aGUgdHJlZS4gIFNvIHRoZXJlJ3Mgbm8gbmVlZCB0
byBodXJyeSB1cCBhbmQgZ2V0IHRoZXNlIGZpeGVzIGluLCB0aGV5IGNhbiB3YWl0IGZvciA0LjEw
LiAgSSBkb24ndCB0aGluayB5b3VyIHBhdGNoZXMgd2lsbCBydW4gaW50byB0aGVzZSBidWdzIGVp
dGhlciBiZWNhdXNlIHlvdSBkb24ndCB1c2UgdGFncy4gIEkgZG8gdGhpbmsgdGhhdCBLaXJpbGwn
cyBwYXRjaGVzIG1pZ2h0IGhpdCB0aGVtIHRob3VnaC4NCg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
