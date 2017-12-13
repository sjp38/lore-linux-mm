Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 886706B0033
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 10:23:09 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id 7so1275382plb.19
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 07:23:09 -0800 (PST)
Received: from esa4.hgst.iphmx.com (esa4.hgst.iphmx.com. [216.71.154.42])
        by mx.google.com with ESMTPS id i136si1424228pgc.293.2017.12.13.07.23.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 07:23:08 -0800 (PST)
From: Bart Van Assche <Bart.VanAssche@wdc.com>
Subject: Re: About the try to remove cross-release feature entirely by Ingo
Date: Wed, 13 Dec 2017 15:23:04 +0000
Message-ID: <1513178583.3296.2.camel@wdc.com>
References: <CANrsvRPQcWz-p_3TYfNf+Waek3bcNNPniXhFzyyS=7qbCqzGyg@mail.gmail.com>
	 <CANrsvRMAci5Vxj0kKsgW4-cgK4X4BAvq9jOwkAx0TWHqBjogVw@mail.gmail.com>
In-Reply-To: <CANrsvRMAci5Vxj0kKsgW4-cgK4X4BAvq9jOwkAx0TWHqBjogVw@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <FDAC4B80D9774F498AC76273C584566B@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "mingo@kernel.org" <mingo@kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "amir73il@gmail.com" <amir73il@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "willy@infradead.org" <willy@infradead.org>, "oleg@redhat.com" <oleg@redhat.com>, "max.byungchul.park@gmail.com" <max.byungchul.park@gmail.com>, "byungchul.park@lge.com" <byungchul.park@lge.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "david@fromorbit.com" <david@fromorbit.com>

T24gV2VkLCAyMDE3LTEyLTEzIGF0IDE2OjEzICswOTAwLCBCeXVuZ2NodWwgUGFyayB3cm90ZToN
Cj4gSW4gYWRkaXRpb24sIEkgd2FudCB0byBzYXkgdGhhdCB0aGUgY3VycmVudCBsZXZlbCBvZg0K
PiBjbGFzc2lmaWNhdGlvbiBpcyBtdWNoIGxlc3MgdGhhbiAxMDAlIGJ1dCwgc2luY2Ugd2UNCj4g
aGF2ZSBhbm5vdGF0ZWQgd2VsbCB0byBzdXBwcmVzcyB3cm9uZyByZXBvcnRzIGJ5DQo+IHJvdWdo
IGNsYXNzaWZpY2F0aW9ucywgZmluYWxseSBpdCBkb2VzIG5vdCBjb21lIGludG8NCj4gdmlldyBi
eSBvcmlnaW5hbCBsb2NrZGVwIGZvciBub3cuDQoNClRoZSBMaW51eCBrZXJuZWwgaXMgbm90IGEg
dmVoaWNsZSBmb3IgZXhwZXJpbWVudHMuIFRoZSBtYWpvcml0eSBvZiBmYWxzZQ0KcG9zaXRpdmVz
IHNob3VsZCBoYXZlIGJlZW4gZml4ZWQgYmVmb3JlIHRoZSBjcm9zc3JlbGVhc2UgcGF0Y2hlcyB3
ZXJlIHNlbnQNCnRvIExpbnVzLg0KDQpCYXJ0Lg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
