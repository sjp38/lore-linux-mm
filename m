Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5574D6B025F
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 16:09:54 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id b192so4527904pga.14
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 13:09:54 -0700 (PDT)
Received: from esa5.hgst.iphmx.com (esa5.hgst.iphmx.com. [216.71.153.144])
        by mx.google.com with ESMTPS id j13si6758807pgf.700.2017.11.03.13.09.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Nov 2017 13:09:53 -0700 (PDT)
From: Bart Van Assche <Bart.VanAssche@wdc.com>
Subject: Re: [PATCH] mm: use in_atomic() in print_vma_addr()
Date: Fri, 3 Nov 2017 20:09:49 +0000
Message-ID: <1509739786.2473.33.camel@wdc.com>
References: <1509572313-102989-1-git-send-email-yang.s@alibaba-inc.com>
	 <20171102075744.whhxjmqbdkfaxghd@dhcp22.suse.cz>
	 <ace5b078-652b-cbc0-176a-25f69612f7fa@alibaba-inc.com>
	 <20171103110245.7049460a05cc18c7e8a9feb2@linux-foundation.org>
In-Reply-To: <20171103110245.7049460a05cc18c7e8a9feb2@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <705B0B1A9A19B64DB2B2837224F4A43C@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "yang.s@alibaba-inc.com" <yang.s@alibaba-inc.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "joe@perches.com" <joe@perches.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "mingo@redhat.com" <mingo@redhat.com>

T24gRnJpLCAyMDE3LTExLTAzIGF0IDExOjAyIC0wNzAwLCBBbmRyZXcgTW9ydG9uIHdyb3RlOg0K
PiBBbHNvLCBjaGVja3BhdGNoIHNheXMNCj4gDQo+IFdBUk5JTkc6IHVzZSBvZiBpbl9hdG9taWMo
KSBpcyBpbmNvcnJlY3Qgb3V0c2lkZSBjb3JlIGtlcm5lbCBjb2RlDQo+ICM0MzogRklMRTogbW0v
bWVtb3J5LmM6NDQ5MToNCj4gKyAgICAgICBpZiAoaW5fYXRvbWljKCkpDQo+IA0KPiBJIGRvbid0
IHJlY2FsbCB3aHkgd2UgZGlkIHRoYXQsIGJ1dCBwZXJoYXBzIHRoaXMgc2hvdWxkIGJlIHJldmlz
aXRlZD8NCg0KSXMgdGhlIGNvbW1lbnQgYWJvdmUgaW5fYXRvbWljKCkgc3RpbGwgdXAtdG8tZGF0
ZT8gRnJvbSA8bGludXgvcHJlZW1wdC5oPjoNCg0KLyoNCiAqIEFyZSB3ZSBydW5uaW5nIGluIGF0
b21pYyBjb250ZXh0PyAgV0FSTklORzogdGhpcyBtYWNybyBjYW5ub3QNCiAqIGFsd2F5cyBkZXRl
Y3QgYXRvbWljIGNvbnRleHQ7IGluIHBhcnRpY3VsYXIsIGl0IGNhbm5vdCBrbm93IGFib3V0DQog
KiBoZWxkIHNwaW5sb2NrcyBpbiBub24tcHJlZW1wdGlibGUga2VybmVscy4gIFRodXMgaXQgc2hv
dWxkIG5vdCBiZQ0KICogdXNlZCBpbiB0aGUgZ2VuZXJhbCBjYXNlIHRvIGRldGVybWluZSB3aGV0
aGVyIHNsZWVwaW5nIGlzIHBvc3NpYmxlLg0KICogRG8gbm90IHVzZSBpbl9hdG9taWMoKSBpbiBk
cml2ZXIgY29kZS4NCiAqLw0KI2RlZmluZSBpbl9hdG9taWMoKQkocHJlZW1wdF9jb3VudCgpICE9
IDApDQoNCkJhcnQu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
