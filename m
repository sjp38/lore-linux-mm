Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5CDC26B0389
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 13:19:38 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id x37so124025676ota.6
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 10:19:38 -0700 (PDT)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0103.outbound.protection.outlook.com. [104.47.42.103])
        by mx.google.com with ESMTPS id q15si2027979oic.106.2017.03.16.10.19.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Mar 2017 10:19:36 -0700 (PDT)
From: "Kani, Toshimitsu" <toshi.kani@hpe.com>
Subject: Re: [RFC PATCH] rework memory hotplug onlining
Date: Thu, 16 Mar 2017 17:19:34 +0000
Message-ID: <1489688018.9118.14.camel@hpe.com>
References: <20170315091347.GA32626@dhcp22.suse.cz>
	 <1489622542.9118.8.camel@hpe.com> <20170316085404.GE30501@dhcp22.suse.cz>
In-Reply-To: <20170316085404.GE30501@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <3676DD6D62852844A835C5F735DFC027@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "mhocko@kernel.org" <mhocko@kernel.org>
Cc: "zhenzhang.zhang@huawei.com" <zhenzhang.zhang@huawei.com>, "tangchen@cn.fujitsu.com" <tangchen@cn.fujitsu.com>, "arbab@linux.vnet.ibm.com" <arbab@linux.vnet.ibm.com>, "vkuznets@redhat.com" <vkuznets@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "daniel.kiper@oracle.com" <daniel.kiper@oracle.com>, "xieyisheng1@huawei.com" <xieyisheng1@huawei.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "qiuxishi@huawei.com" <qiuxishi@huawei.com>, "yasu.isimatu@gmail.com" <yasu.isimatu@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "aarcange@redhat.com" <aarcange@redhat.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "imammedo@redhat.com" <imammedo@redhat.com>, "rientjes@google.com" <rientjes@google.com>, "mgorman@suse.de" <mgorman@suse.de>, "ak@linux.intel.com" <ak@linux.intel.com>, "slaoub@gmail.com" <slaoub@gmail.com>

T24gVGh1LCAyMDE3LTAzLTE2IGF0IDA5OjU0ICswMTAwLCBNaWNoYWwgSG9ja28gd3JvdGU6DQo+
IE9uIFdlZCAxNS0wMy0xNyAyMzowODoxNCwgS2FuaSwgVG9zaGltaXRzdSB3cm90ZToNCj4gPiBP
biBXZWQsIDIwMTctMDMtMTUgYXQgMTA6MTMgKzAxMDAsIE1pY2hhbCBIb2NrbyB3cm90ZToNCiA6
DQo+ID4gPiAtCXpvbmUgPSBwYWdlX3pvbmUocGZuX3RvX3BhZ2UodmFsaWRfc3RhcnQpKTsNCj4g
PiANCj4gPiBQbGVhc2UgZG8gbm90IHJlbW92ZSB0aGUgZml4IG1hZGUgaW4gYTk2ZGZkZGJjYzA0
My4gem9uZSBuZWVkcyB0bw0KPiA+IGJlIHNldCBmcm9tIHZhbGlkX3N0YXJ0LCBub3QgZnJvbSBz
dGFydF9wZm4uDQo+IA0KPiBUaGFua3MgZm9yIHBvaW50aW5nIHRoaXMgb3V0LiBJIHdhcyBzY3Jh
dGNoaW5nIG15IGhlYWQgYWJvdXQgdGhpcw0KPiBwYXJ0IGJ1dCB3YXMgdG9vIHRpcmVkIGZyb20g
cHJldmlvdXMgZ2l0IGFyY2hlb2xvZ3kgc28gSSBkaWRuJ3QgY2hlY2sNCj4gdGhlIGhpc3Rvcnkg
b2YgdGhpcyBwYXJ0aWN1bGFyIHBhcnQuDQo+DQo+IEkgd2lsbCByZXN0b3JlIHRoZSBvcmlnaW5h
bCBiZWhhdmlvciBidXQgYmVmb3JlIEkgZG8gdGhhdCBJIGFtIHJlYWxseQ0KPiBjdXJpb3VzIHdo
ZXRoZXIgcGFydGlhbCBtZW1ibG9ja3MgYXJlIGV2ZW4gc3VwcG9ydGVkIGZvciBvbmxpbmluZy4N
Cj4gTWF5YmUgSSBhbSBtaXNzaW5nIHNvbWV0aGluZyBidXQgSSBkbyBub3Qgc2VlIGFueSBleHBs
aWNpdCBjaGVja3MgZm9yDQo+IE5VTEwgc3RydWN0IHBhZ2Ugd2hlbiB3ZSBzZXQgem9uZSBib3Vu
ZGFyaWVzIG9yIG9ubGluZSBhIG1lbWJsb2NrLiBJcw0KPiBpdCBwb3NzaWJsZSB0aG9zZSBtZW1i
bG9ja3MgYXJlIGp1c3QgbmV2ZXIgaG90cGx1Z2FibGU/DQoNCmNoZWNrX2hvdHBsdWdfbWVtb3J5
X3JhbmdlKCkgY2hlY2tzIGlmIGEgZ2l2ZW4gcmFuZ2UgaXMgYWxpZ25lZCBieSB0aGUNCnNlY3Rp
b24gc2l6ZS4NCg0KVGhpcyBtZW1vcnkgZGV2aWNlIHJlcHJlc2VudHMgYSBtZW1vcnlfYmxvY2ss
IHdoaWNoIG1heSBoYXZlIG11bHRpcGxlDQpzZWN0aW9ucyBwZXIgJ3NlY3Rpb25zX3Blcl9ibG9j
aycuICBUaGlzIHZhbHVlIGlzIHNldCB0byAyR0IvMTI4TUIgZm9yDQoyR0IgbWVtb3J5X2Jsb2Nr
LiAgU28sIEknZCBleHBlY3QgdGhhdCBob3QtYWRkIHdvcmtzIGFzIGxvbmcgYXMgdGhlDQphZGRy
ZXNzIGlzIGFsaWduZWQgYnkgMTI4TUIsIGJ1dCBJIGhhdmUgbm90IHRlc3RlZCBpdCBteXNlbGYu
DQoNClRoYW5rcywNCi1Ub3NoaQ==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
