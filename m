Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6E5F96B0069
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 10:30:01 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x7so3589273pfa.19
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 07:30:01 -0700 (PDT)
Received: from esa4.hgst.iphmx.com (esa4.hgst.iphmx.com. [216.71.154.42])
        by mx.google.com with ESMTPS id r84si7501994pfa.352.2017.10.18.07.29.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 07:30:00 -0700 (PDT)
From: Bart Van Assche <Bart.VanAssche@wdc.com>
Subject: Re: Fix false positive by LOCKDEP_CROSSRELEASE
Date: Wed, 18 Oct 2017 14:29:56 +0000
Message-ID: <1508336995.2923.2.camel@wdc.com>
References: <1508319532-24655-1-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1508319532-24655-1-git-send-email-byungchul.park@lge.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <BA1A9EAFF803F749BFC56F3492D9FC98@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "mingo@kernel.org" <mingo@kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "byungchul.park@lge.com" <byungchul.park@lge.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "amir73il@gmail.com" <amir73il@gmail.com>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "hch@infradead.org" <hch@infradead.org>, "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "oleg@redhat.com" <oleg@redhat.com>, "darrick.wong@oracle.com" <darrick.wong@oracle.com>, "johannes.berg@intel.com" <johannes.berg@intel.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "idryomov@gmail.com" <idryomov@gmail.com>, "tj@kernel.org" <tj@kernel.org>, "kernel-team@lge.com" <kernel-team@lge.com>, "david@fromorbit.com" <david@fromorbit.com>

T24gV2VkLCAyMDE3LTEwLTE4IGF0IDE4OjM4ICswOTAwLCBCeXVuZ2NodWwgUGFyayB3cm90ZToN
Cj4gU2V2ZXJhbCBmYWxzZSBwb3NpdGl2ZXMgd2VyZSByZXBvcnRlZCwgc28gSSB0cmllZCB0byBm
aXggdGhlbS4NCj4gDQo+IEl0IHdvdWxkIGJlIGFwcHJlY2lhdGVkIGlmIHlvdSB0ZWxsIG1lIGlm
IGl0IHdvcmtzIGFzIGV4cGVjdGVkLCBvciBsZXQNCj4gbWUga25vdyB5b3VyIG9waW5pb24uDQoN
CldoYXQgSSBoYXZlIGJlZW4gd29uZGVyaW5nIGFib3V0IGlzIHdoZXRoZXIgdGhlIGNyb3NzbG9j
ayBjaGVja2luZyBtYWtlcw0Kc2Vuc2UgZnJvbSBhIGNvbmNlcHR1YWwgcG9pbnQgb2Ygdmlldy4g
SSB0cmllZCB0byBmaW5kIGRvY3VtZW50YXRpb24gZm9yIHRoZQ0KY3Jvc3Nsb2NrIGNoZWNraW5n
IGluIERvY3VtZW50YXRpb24vbG9ja2luZy9sb2NrZGVwLWRlc2lnbi50eHQgYnV0DQpjb3VsZG4n
dCBmaW5kIGEgZGVzY3JpcHRpb24gb2YgdGhlIGNyb3NzbG9jayBjaGVja2luZy4gU2hvdWxkbid0
IGl0IGJlDQpkb2N1bWVudGVkIHNvbWV3aGVyZSB3aGF0IHRoZSBjcm9zc2xvY2sgY2hlY2tzIGRv
IGFuZCB3aGF0IHRoZSB0aGVvcnkgaXMNCmJlaGluZCB0aGVzZSBjaGVja3M/DQoNCkJhcnQuDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
