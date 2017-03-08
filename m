Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5D46E83200
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 13:02:13 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id v125so89307161qkh.5
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 10:02:13 -0800 (PST)
Received: from us-smtp-delivery-194.mimecast.com (us-smtp-delivery-194.mimecast.com. [63.128.21.194])
        by mx.google.com with ESMTPS id b202si3541334qka.36.2017.03.08.10.01.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 08 Mar 2017 10:01:55 -0800 (PST)
From: Trond Myklebust <trondmy@primarydata.com>
Subject: Re: [PATCH v2 6/9] mm: set mapping error when launder_pages fails
Date: Wed, 8 Mar 2017 18:01:47 +0000
Message-ID: <1488996103.3098.4.camel@primarydata.com>
References: <20170308162934.21989-1-jlayton@redhat.com>
	 <20170308162934.21989-7-jlayton@redhat.com>
In-Reply-To: <20170308162934.21989-7-jlayton@redhat.com>
Content-Language: en-US
Content-ID: <21F7418F71E31848A4493C2E2A5DBE3B@namprd11.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "jlayton@redhat.com" <jlayton@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-nilfs@vger.kernel.org" <linux-nilfs@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "konishi.ryusuke@lab.ntt.co.jp" <konishi.ryusuke@lab.ntt.co.jp>, "neilb@suse.com" <neilb@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "adilger@dilger.ca" <adilger@dilger.ca>, "James.Bottomley@HansenPartnership.com" <James.Bottomley@HansenPartnership.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "openosd@gmail.com" <openosd@gmail.com>, "jack@suse.cz" <jack@suse.cz>

T24gV2VkLCAyMDE3LTAzLTA4IGF0IDExOjI5IC0wNTAwLCBKZWZmIExheXRvbiB3cm90ZToNCj4g
SWYgbGF1bmRlcl9wYWdlIGZhaWxzLCB0aGVuIHdlIGhpdCBhIHByb2JsZW0gd3JpdGluZyBiYWNr
IHNvbWUgaW5vZGUNCj4gZGF0YS4gRW5zdXJlIHRoYXQgd2UgY29tbXVuaWNhdGUgdGhhdCBmYWN0
IGluIGEgc3Vic2VxdWVudCBmc3luYw0KPiBzaW5jZQ0KPiBhbm90aGVyIHRhc2sgY291bGQgc3Rp
bGwgaGF2ZSBpdCBvcGVuIGZvciB3cml0ZS4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IEplZmYgTGF5
dG9uIDxqbGF5dG9uQHJlZGhhdC5jb20+DQo+IC0tLQ0KPiDCoG1tL3RydW5jYXRlLmMgfCA2ICsr
KysrLQ0KPiDCoDEgZmlsZSBjaGFuZ2VkLCA1IGluc2VydGlvbnMoKyksIDEgZGVsZXRpb24oLSkN
Cj4gDQo+IGRpZmYgLS1naXQgYS9tbS90cnVuY2F0ZS5jIGIvbW0vdHJ1bmNhdGUuYw0KPiBpbmRl
eCA2MjYzYWZmZGVmODguLjI5YWU0MjBhNWJmOSAxMDA2NDQNCj4gLS0tIGEvbW0vdHJ1bmNhdGUu
Yw0KPiArKysgYi9tbS90cnVuY2F0ZS5jDQo+IEBAIC01OTQsMTEgKzU5NCwxNSBAQCBpbnZhbGlk
YXRlX2NvbXBsZXRlX3BhZ2UyKHN0cnVjdCBhZGRyZXNzX3NwYWNlDQo+ICptYXBwaW5nLCBzdHJ1
Y3QgcGFnZSAqcGFnZSkNCj4gwqANCj4gwqBzdGF0aWMgaW50IGRvX2xhdW5kZXJfcGFnZShzdHJ1
Y3QgYWRkcmVzc19zcGFjZSAqbWFwcGluZywgc3RydWN0DQo+IHBhZ2UgKnBhZ2UpDQo+IMKgew0K
PiArCWludCByZXQ7DQo+ICsNCj4gwqAJaWYgKCFQYWdlRGlydHkocGFnZSkpDQo+IMKgCQlyZXR1
cm4gMDsNCj4gwqAJaWYgKHBhZ2UtPm1hcHBpbmcgIT0gbWFwcGluZyB8fCBtYXBwaW5nLT5hX29w
cy0+bGF1bmRlcl9wYWdlIA0KPiA9PSBOVUxMKQ0KPiDCoAkJcmV0dXJuIDA7DQo+IC0JcmV0dXJu
IG1hcHBpbmctPmFfb3BzLT5sYXVuZGVyX3BhZ2UocGFnZSk7DQo+ICsJcmV0ID0gbWFwcGluZy0+
YV9vcHMtPmxhdW5kZXJfcGFnZShwYWdlKTsNCj4gKwltYXBwaW5nX3NldF9lcnJvcihtYXBwaW5n
LCByZXQpOw0KPiArCXJldHVybiByZXQ7DQo+IMKgfQ0KPiDCoA0KPiDCoC8qKg0KDQpOby4gQXQg
dGhhdCBsYXllciwgeW91IGRvbid0IGtub3cgdGhhdCB0aGlzIGlzIGEgcGFnZSBlcnJvci4gSW4g
dGhlIE5GUw0KY2FzZSwgaXQgY291bGQsIGZvciBpbnN0YW5jZSwganVzdCBhcyB3ZWxsIGJlIGEg
ZmF0YWwgc2lnbmFsLg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBt
YWludGFpbmVyLCBQcmltYXJ5RGF0YQ0KdHJvbmQubXlrbGVidXN0QHByaW1hcnlkYXRhLmNvbQ0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
