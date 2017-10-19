Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 394706B025F
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 19:24:04 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id d28so7350784pfe.1
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 16:24:04 -0700 (PDT)
Received: from esa1.hgst.iphmx.com (esa1.hgst.iphmx.com. [68.232.141.245])
        by mx.google.com with ESMTPS id u125si207688pgc.776.2017.10.19.16.24.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 16:24:02 -0700 (PDT)
From: Bart Van Assche <Bart.VanAssche@wdc.com>
Subject: Re: [RESEND PATCH 1/3] completion: Add support for initializing
 completion with lockdep_map
Date: Thu, 19 Oct 2017 23:24:00 +0000
Message-ID: <1508455438.4542.4.camel@wdc.com>
References: <1508319532-24655-1-git-send-email-byungchul.park@lge.com>
	 <1508319532-24655-2-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1508319532-24655-2-git-send-email-byungchul.park@lge.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <3817A0B346BD1B438366B1442EDB7895@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "mingo@kernel.org" <mingo@kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "byungchul.park@lge.com" <byungchul.park@lge.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "amir73il@gmail.com" <amir73il@gmail.com>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "hch@infradead.org" <hch@infradead.org>, "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "oleg@redhat.com" <oleg@redhat.com>, "darrick.wong@oracle.com" <darrick.wong@oracle.com>, "johannes.berg@intel.com" <johannes.berg@intel.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "idryomov@gmail.com" <idryomov@gmail.com>, "tj@kernel.org" <tj@kernel.org>, "kernel-team@lge.com" <kernel-team@lge.com>, "david@fromorbit.com" <david@fromorbit.com>

T24gV2VkLCAyMDE3LTEwLTE4IGF0IDE4OjM4ICswOTAwLCBCeXVuZ2NodWwgUGFyayB3cm90ZToN
Cj4gU29tZXRpbWVzLCB3ZSB3YW50IHRvIGluaXRpYWxpemUgY29tcGxldGlvbnMgd2l0aCBzcGFy
YXRlIGxvY2tkZXAgbWFwcw0KPiB0byBhc3NpZ24gbG9jayBjbGFzc2VzIHVuZGVyIGNvbnRyb2wu
IEZvciBleGFtcGxlLCB0aGUgd29ya3F1ZXVlIGNvZGUNCj4gbWFuYWdlcyBsb2NrZGVwIG1hcHMs
IGFzIGl0IGNhbiBjbGFzc2lmeSBsb2NrZGVwIG1hcHMgcHJvcGVybHkuDQo+IFByb3ZpZGVkIGEg
ZnVuY3Rpb24gZm9yIHRoYXQgcHVycG9zZS4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IEJ5dW5nY2h1
bCBQYXJrIDxieXVuZ2NodWwucGFya0BsZ2UuY29tPg0KPiAtLS0NCj4gIGluY2x1ZGUvbGludXgv
Y29tcGxldGlvbi5oIHwgOCArKysrKysrKw0KPiAgMSBmaWxlIGNoYW5nZWQsIDggaW5zZXJ0aW9u
cygrKQ0KPiANCj4gZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvY29tcGxldGlvbi5oIGIvaW5j
bHVkZS9saW51eC9jb21wbGV0aW9uLmgNCj4gaW5kZXggY2FlNTQwMC4uMTgyZDU2ZSAxMDA2NDQN
Cj4gLS0tIGEvaW5jbHVkZS9saW51eC9jb21wbGV0aW9uLmgNCj4gKysrIGIvaW5jbHVkZS9saW51
eC9jb21wbGV0aW9uLmgNCj4gQEAgLTQ5LDYgKzQ5LDEzIEBAIHN0YXRpYyBpbmxpbmUgdm9pZCBj
b21wbGV0ZV9yZWxlYXNlX2NvbW1pdChzdHJ1Y3QgY29tcGxldGlvbiAqeCkNCj4gIAlsb2NrX2Nv
bW1pdF9jcm9zc2xvY2soKHN0cnVjdCBsb2NrZGVwX21hcCAqKSZ4LT5tYXApOw0KPiAgfQ0KPiAg
DQo+ICsjZGVmaW5lIGluaXRfY29tcGxldGlvbl93aXRoX21hcCh4LCBtKQkJCQkJXA0KPiArZG8g
ewkJCQkJCQkJCVwNCj4gKwlsb2NrZGVwX2luaXRfbWFwX2Nyb3NzbG9jaygoc3RydWN0IGxvY2tk
ZXBfbWFwICopJih4KS0+bWFwLAlcDQo+ICsJCQkobSktPm5hbWUsIChtKS0+a2V5LCAwKTsJCQkJ
XA0KPiArCV9faW5pdF9jb21wbGV0aW9uKHgpOwkJCQkJCVwNCj4gK30gd2hpbGUgKDApDQoNCkFy
ZSB0aGVyZSBhbnkgY29tcGxldGlvbiBvYmplY3RzIGZvciB3aGljaCB0aGUgY3Jvc3MtcmVsZWFz
ZSBjaGVja2luZyBpcw0KdXNlZnVsPyBBcmUgdGhlcmUgYW55IHdhaXRfZm9yX2NvbXBsZXRpb24o
KSBjYWxsZXJzIHRoYXQgaG9sZCBhIG11dGV4IG9yDQpvdGhlciBsb2NraW5nIG9iamVjdD8NCg0K
VGhhbmtzLA0KDQpCYXJ0Lg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
