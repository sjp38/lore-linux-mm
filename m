Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A356B6B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 19:03:11 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f5so111122777pgi.1
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 16:03:11 -0800 (PST)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0130.outbound.protection.outlook.com. [104.47.32.130])
        by mx.google.com with ESMTPS id j62si7141822pfg.51.2017.01.17.16.03.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 17 Jan 2017 16:03:10 -0800 (PST)
From: "Kani, Toshimitsu" <toshi.kani@hpe.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Future direction of DAX
Date: Wed, 18 Jan 2017 00:03:08 +0000
Message-ID: <1484701124.2029.9.camel@hpe.com>
References: <20170114002008.GA25379@linux.intel.com>
	 <20170117155910.GU2517@quack2.suse.cz>
In-Reply-To: <20170117155910.GU2517@quack2.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <75D4FFDF1F75974CBD1510C98C246452@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "jack@suse.cz" <jack@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

T24gVHVlLCAyMDE3LTAxLTE3IGF0IDE2OjU5ICswMTAwLCBKYW4gS2FyYSB3cm90ZToNCj4gT24g
RnJpIDEzLTAxLTE3IDE3OjIwOjA4LCBSb3NzIFp3aXNsZXIgd3JvdGU6DQogOg0KPiA+IC0gSWYg
SSByZWNhbGwgY29ycmVjdGx5LCBhdCBvbmUgcG9pbnQgRGF2ZSBDaGlubmVyIHN1Z2dlc3RlZCB0
aGF0DQo+ID4gd2UgY2hhbmdlIC0gSWYgSSByZWNhbGwgY29ycmVjdGx5LCBhdCBvbmUgcG9pbnQg
RGF2ZSBDaGlubmVyDQo+ID4gc3VnZ2VzdGVkIHRoYXQgd2UgY2hhbmdlIMKgIERBWCBzbyB0aGF0
IEkvTyB3b3VsZCB1c2UgY2FjaGVkIHN0b3Jlcw0KPiA+IGluc3RlYWQgb2YgdGhlIG5vbi10ZW1w
b3JhbCBzdG9yZXMgwqAgdGhhdCBpdCBjdXJyZW50bHkgdXNlcy7CoMKgV2UNCj4gPiB3b3VsZCB0
aGVuIHRyYWNrIHBhZ2VzIHRoYXQgd2VyZSB3cml0dGVuIHRvIGJ5IERBWCBpbiB0aGUgcmFkaXgN
Cj4gPiB0cmVlIHNvIHRoYXQgdGhleSB3b3VsZCBiZSBmbHVzaGVkIGxhdGVyIGR1cmluZyDCoA0K
PiA+IGZzeW5jL21zeW5jLsKgwqBEb2VzIHRoaXMgc291bmQgbGlrZSBhIHdpbj/CoMKgQWxzbywg
YXNzdW1pbmcgdGhhdCB3ZQ0KPiA+IGNhbiBmaW5kIGEgc29sdXRpb24gZm9yIHBsYXRmb3JtcyB3
aGVyZSB0aGUgcHJvY2Vzc29yIGNhY2hlIGlzIHBhcnQNCj4gPiBvZiB0aGUgQURSIHNhZmUgem9u
ZSAoYWJvdmUgdG9waWMpIHRoaXMgd291bGQgYmUgYSBjbGVhcg0KPiA+IGltcHJvdmVtZW50LCBt
b3ZpbmcgdXMgZnJvbSB1c2luZyBub24tdGVtcG9yYWwgc3RvcmVzIHRvIGZhc3Rlcg0KPiA+IGNh
Y2hlZCBzdG9yZXMgd2l0aCBubyBkb3duc2lkZS4NCj4gDQo+IEkgZ3Vlc3MgdGhpcyBuZWVkcyBt
ZWFzdXJlbWVudHMuIEJ1dCBpdCBpcyB3b3J0aCBhIHRyeS4NCg0KQnJhaW4gQm95bHN0b24gZGlk
IHNvbWUgbWVhc3VyZW1lbnQgYmVmb3JlLg0KaHR0cDovL29zcy5zZ2kuY29tL2FyY2hpdmVzL3hm
cy8yMDE2LTA4L21zZzAwMjM5Lmh0bWwNCg0KSSB1cGRhdGVkIGhpcyB0ZXN0IHByb2dyYW0gdG8g
c2tpcCBwbWVtX3BlcnNpc3QoKSBmb3IgdGhlIGNhY2hlZCBjb3B5DQpjYXNlLg0KDQrCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqBkc3QgPSBkc3RiYXNlOw0K
KyAjaWYgMA0KwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
Lyogc2VlIG5vdGUgYWJvdmUgKi8NCsKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoGlmIChtb2RlID09ICdjJykNCsKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqBwbWVtX3BlcnNpc3QoZHN0LCBk
c3Rzeik7DQorICNlbmRpZg0KwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqB9DQoNCkhl
cmUgYXJlIHNhbXBsZSBydW5zOg0KDQokIG51bWFjdGwgLU4wIHRpbWUgLXAgLi9tZW1jcHlwZXJm
IGMgL21udC9wbWVtMC9maWxlIDEwMDAwMDANCklORk86IGRzdCAweDdmMWQwMDAwMDAwMCBzcmMg
MHg2MDEyMDAgZHN0c3ogMjc1NjUwOTY5NiBjcHlzeiAxNjM4NA0KcmVhbCAzLjI4DQp1c2VyIDMu
MjcNCnN5cyAwLjAwDQoNCiQgbnVtYWN0bCAtTjAgdGltZSAtcCAuL21lbWNweXBlcmYgbiAvbW50
L3BtZW0wL2ZpbGUgMTAwMDAwMA0KSU5GTzogZHN0IDB4N2Y2MDgwMDAwMDAwIHNyYyAweDYwMTIw
MCBkc3RzeiAyNzU2NTA5Njk2IGNweXN6IDE2Mzg0DQpyZWFsIDEuMDENCnVzZXIgMS4wMQ0Kc3lz
IDAuMDANCg0KJCBudW1hY3RsIC1OMSB0aW1lIC1wIC4vbWVtY3B5cGVyZiBjIC9tbnQvcG1lbTAv
ZmlsZSAxMDAwMDAwDQpJTkZPOiBkc3QgMHg3ZmU5MDAwMDAwMDAgc3JjIDB4NjAxMjAwIGRzdHN6
IDI3NTY1MDk2OTYgY3B5c3ogMTYzODQNCnJlYWwgNC4wNg0KdXNlciA0LjA2DQpzeXMgMC4wMA0K
DQokIG51bWFjdGwgLU4xIHRpbWUgLXAgLi9tZW1jcHlwZXJmIG4gL21udC9wbWVtMC9maWxlIDEw
MDAwMDANCklORk86IGRzdCAweDdmNzY0MDAwMDAwMCBzcmMgMHg2MDEyMDAgZHN0c3ogMjc1NjUw
OTY5NiBjcHlzeiAxNjM4NA0KcmVhbCAxLjI3DQp1c2VyIDEuMjcNCnN5cyAwLjAwDQoNCkluIHRo
aXMgc2ltcGxlIHRlc3QsIHVzaW5nIG5vbi10ZW1wb3JhbCBjb3B5IGlzIHN0aWxsIGZhc3RlciB0
aGFuIHVzaW5nDQpjYWNoZWQgY29weS4NCg0KVGhhbmtzLA0KLVRvc2hpDQoNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
