Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id EDD306B0390
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 19:08:17 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id 19so73716741oti.5
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 16:08:17 -0700 (PDT)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0097.outbound.protection.outlook.com. [104.47.42.97])
        by mx.google.com with ESMTPS id h12si1303896otg.318.2017.03.15.16.08.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 15 Mar 2017 16:08:17 -0700 (PDT)
From: "Kani, Toshimitsu" <toshi.kani@hpe.com>
Subject: Re: [RFC PATCH] rework memory hotplug onlining
Date: Wed, 15 Mar 2017 23:08:14 +0000
Message-ID: <1489622542.9118.8.camel@hpe.com>
References: <20170315091347.GA32626@dhcp22.suse.cz>
In-Reply-To: <20170315091347.GA32626@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <640B4D0A2B34434E81D3A8DA63A97E0E@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org" <mhocko@kernel.org>
Cc: "zhenzhang.zhang@huawei.com" <zhenzhang.zhang@huawei.com>, "tangchen@cn.fujitsu.com" <tangchen@cn.fujitsu.com>, "arbab@linux.vnet.ibm.com" <arbab@linux.vnet.ibm.com>, "vkuznets@redhat.com" <vkuznets@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "daniel.kiper@oracle.com" <daniel.kiper@oracle.com>, "xieyisheng1@huawei.com" <xieyisheng1@huawei.com>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "qiuxishi@huawei.com" <qiuxishi@huawei.com>, "yasu.isimatu@gmail.com" <yasu.isimatu@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "aarcange@redhat.com" <aarcange@redhat.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "imammedo@redhat.com" <imammedo@redhat.com>, "rientjes@google.com" <rientjes@google.com>, "mgorman@suse.de" <mgorman@suse.de>, "ak@linux.intel.com" <ak@linux.intel.com>, "slaoub@gmail.com" <slaoub@gmail.com>

T24gV2VkLCAyMDE3LTAzLTE1IGF0IDEwOjEzICswMTAwLCBNaWNoYWwgSG9ja28gd3JvdGU6DQog
Og0KPiBAQCAtMzg4LDM5ICszODksNDQgQEAgc3RhdGljIHNzaXplX3Qgc2hvd192YWxpZF96b25l
cyhzdHJ1Y3QgZGV2aWNlDQo+ICpkZXYsDQo+IMKgCQkJCXN0cnVjdCBkZXZpY2VfYXR0cmlidXRl
ICphdHRyLCBjaGFyDQo+ICpidWYpDQo+IMKgew0KPiDCoAlzdHJ1Y3QgbWVtb3J5X2Jsb2NrICpt
ZW0gPSB0b19tZW1vcnlfYmxvY2soZGV2KTsNCj4gLQl1bnNpZ25lZCBsb25nIHN0YXJ0X3Bmbiwg
ZW5kX3BmbjsNCj4gLQl1bnNpZ25lZCBsb25nIHZhbGlkX3N0YXJ0LCB2YWxpZF9lbmQsIHZhbGlk
X3BhZ2VzOw0KPiAtCXVuc2lnbmVkIGxvbmcgbnJfcGFnZXMgPSBQQUdFU19QRVJfU0VDVElPTiAq
DQo+IHNlY3Rpb25zX3Blcl9ibG9jazsNCj4gKwl1bnNpZ25lZCBsb25nIHN0YXJ0X3BmbiwgbnJf
cGFnZXM7DQo+ICsJYm9vbCBhcHBlbmQgPSBmYWxzZTsNCj4gwqAJc3RydWN0IHpvbmUgKnpvbmU7
DQo+IC0JaW50IHpvbmVfc2hpZnQgPSAwOw0KPiArCWludCBuaWQ7DQo+IMKgDQo+IMKgCXN0YXJ0
X3BmbiA9IHNlY3Rpb25fbnJfdG9fcGZuKG1lbS0+c3RhcnRfc2VjdGlvbl9ucik7DQo+IC0JZW5k
X3BmbiA9IHN0YXJ0X3BmbiArIG5yX3BhZ2VzOw0KPiArCXpvbmUgPSBwYWdlX3pvbmUocGZuX3Rv
X3BhZ2Uoc3RhcnRfcGZuKSk7DQo+ICsJbnJfcGFnZXMgPSBQQUdFU19QRVJfU0VDVElPTiAqIHNl
Y3Rpb25zX3Blcl9ibG9jazsNCj4gwqANCj4gLQkvKiBUaGUgYmxvY2sgY29udGFpbnMgbW9yZSB0
aGFuIG9uZSB6b25lIGNhbiBub3QgYmUNCj4gb2ZmbGluZWQuICovDQo+IC0JaWYgKCF0ZXN0X3Bh
Z2VzX2luX2Ffem9uZShzdGFydF9wZm4sIGVuZF9wZm4sICZ2YWxpZF9zdGFydCwNCj4gJnZhbGlk
X2VuZCkpDQo+ICsJLyoNCj4gKwnCoCogVGhlIGJsb2NrIGNvbnRhaW5zIG1vcmUgdGhhbiBvbmUg
em9uZSBjYW4gbm90IGJlDQo+IG9mZmxpbmVkLg0KPiArCcKgKiBUaGlzIGNhbiBoYXBwZW4gZS5n
LiBmb3IgWk9ORV9ETUEgYW5kIFpPTkVfRE1BMzINCj4gKwnCoCovDQo+ICsJaWYgKCF0ZXN0X3Bh
Z2VzX2luX2Ffem9uZShzdGFydF9wZm4sIHN0YXJ0X3BmbiArIG5yX3BhZ2VzLA0KPiBOVUxMLCBO
VUxMKSkNCj4gwqAJCXJldHVybiBzcHJpbnRmKGJ1ZiwgIm5vbmVcbiIpOw0KPiDCoA0KPiAtCXpv
bmUgPSBwYWdlX3pvbmUocGZuX3RvX3BhZ2UodmFsaWRfc3RhcnQpKTsNCg0KUGxlYXNlIGRvIG5v
dCByZW1vdmUgdGhlIGZpeCBtYWRlIGluIGE5NmRmZGRiY2MwNDMuIHpvbmUgbmVlZHMgdG8gYmUN
CnNldCBmcm9tIHZhbGlkX3N0YXJ0LCBub3QgZnJvbSBzdGFydF9wZm4uDQoNClRoYW5rcywNCi1U
b3NoaQ==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
