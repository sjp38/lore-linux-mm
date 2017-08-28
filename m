Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id A74436B02B4
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 17:42:36 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id w42so4976910qtg.2
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:42:36 -0700 (PDT)
Received: from esa5.hgst.iphmx.com (esa5.hgst.iphmx.com. [216.71.153.144])
        by mx.google.com with ESMTPS id u5si1235513qkc.355.2017.08.28.14.42.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 14:42:35 -0700 (PDT)
From: Bart Van Assche <Bart.VanAssche@wdc.com>
Subject: Re: [PATCH v2 17/30] scsi: Define usercopy region in scsi_sense_cache
 slab cache
Date: Mon, 28 Aug 2017 21:42:32 +0000
Message-ID: <1503956551.2841.70.camel@wdc.com>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
	 <1503956111-36652-18-git-send-email-keescook@chromium.org>
In-Reply-To: <1503956111-36652-18-git-send-email-keescook@chromium.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <99A2AF1448B43B4DAD1BCE1FA28710ED@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "keescook@chromium.org" <keescook@chromium.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "jejb@linux.vnet.ibm.com" <jejb@linux.vnet.ibm.com>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "martin.petersen@oracle.com" <martin.petersen@oracle.com>, "dave@nullcore.net" <dave@nullcore.net>

T24gTW9uLCAyMDE3LTA4LTI4IGF0IDE0OjM0IC0wNzAwLCBLZWVzIENvb2sgd3JvdGU6DQo+IGRp
ZmYgLS1naXQgYS9kcml2ZXJzL3Njc2kvc2NzaV9saWIuYyBiL2RyaXZlcnMvc2NzaS9zY3NpX2xp
Yi5jDQo+IGluZGV4IGY2MDk3Yjg5ZDVkMy4uZjFjNmJkNTZkZDViIDEwMDY0NA0KPiAtLS0gYS9k
cml2ZXJzL3Njc2kvc2NzaV9saWIuYw0KPiArKysgYi9kcml2ZXJzL3Njc2kvc2NzaV9saWIuYw0K
PiBAQCAtNzcsMTQgKzc3LDE1IEBAIGludCBzY3NpX2luaXRfc2Vuc2VfY2FjaGUoc3RydWN0IFNj
c2lfSG9zdCAqc2hvc3QpDQo+ICAJaWYgKHNob3N0LT51bmNoZWNrZWRfaXNhX2RtYSkgew0KPiAg
CQlzY3NpX3NlbnNlX2lzYWRtYV9jYWNoZSA9DQo+ICAJCQlrbWVtX2NhY2hlX2NyZWF0ZSgic2Nz
aV9zZW5zZV9jYWNoZShETUEpIiwNCj4gLQkJCVNDU0lfU0VOU0VfQlVGRkVSU0laRSwgMCwNCj4g
LQkJCVNMQUJfSFdDQUNIRV9BTElHTiB8IFNMQUJfQ0FDSEVfRE1BLCBOVUxMKTsNCj4gKwkJCQlT
Q1NJX1NFTlNFX0JVRkZFUlNJWkUsIDAsDQo+ICsJCQkJU0xBQl9IV0NBQ0hFX0FMSUdOIHwgU0xB
Ql9DQUNIRV9ETUEsIE5VTEwpOw0KPiAgCQlpZiAoIXNjc2lfc2Vuc2VfaXNhZG1hX2NhY2hlKQ0K
PiAgCQkJcmV0ID0gLUVOT01FTTsNCg0KQWxsIHRoaXMgcGFydCBvZiB0aGlzIHBhdGNoIGRvZXMg
aXMgdG8gY2hhbmdlIHNvdXJjZSBjb2RlIGluZGVudGF0aW9uLiBTaG91bGQNCnRoZXNlIGNoYW5n
ZXMgcmVhbGx5IGJlIGluY2x1ZGVkIGluIHRoaXMgcGF0Y2g/DQoNClRoYW5rcywNCg0KQmFydC4=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
