Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1D6866B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 09:40:42 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id p194so71857158iod.2
        for <linux-mm@kvack.org>; Tue, 31 May 2016 06:40:42 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id u28si17439184otu.215.2016.05.31.06.40.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 May 2016 06:40:41 -0700 (PDT)
From: zhouxianrong <zhouxianrong@huawei.com>
Subject: =?gb2312?B?tPC4tDogW1BBVENIXSByZXVzaW5nIG9mIG1hcHBpbmcgcGFnZSBzdXBwbGll?=
 =?gb2312?B?cyBhIHdheSBmb3IgZmlsZSBwYWdlIGFsbG9jYXRpb24gdW5kZXIgbG93IG1l?=
 =?gb2312?B?bW9yeSBkdWUgdG8gcGFnZWNhY2hlIG92ZXIgc2l6ZSBhbmQgaXMgY29udHJv?=
 =?gb2312?B?bGxlZCBieSBzeXNjdGwgcGFyYW1ldGVycy4gaXQgaXMgdXNlZCBvbmx5IGZv?=
 =?gb2312?B?ciBydyBwYWdlIGFsbG9jYXRpb24gcmF0aGVyIHRoYW4gZmF1bHQgb3IgcmVh?=
 =?gb2312?Q?dahead_allocation._it_is_like...?=
Date: Tue, 31 May 2016 13:35:37 +0000
Message-ID: <AE94847B1D9E864B8593BD8051012AF36D70EA02@SZXEML505-MBS.china.huawei.com>
References: <1464685702-100211-1-git-send-email-zhouxianrong@huawei.com>
 <20160531093631.GH26128@dhcp22.suse.cz>
In-Reply-To: <20160531093631.GH26128@dhcp22.suse.cz>
Content-Language: zh-CN
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Zhouxiyu <zhouxiyu@huawei.com>, "wanghaijun (E)" <wanghaijun5@huawei.com>, "Yuchao (T)" <yuchao0@huawei.com>

SGV5IDoNCgl0aGUgY29uc2lkZXJhdGlvbiBvZiB0aGlzIHBhdGNoIGlzIHRoYXQgcmV1c2luZyBt
YXBwaW5nIHBhZ2UgcmF0aGVyIHRoYW4gYWxsb2NhdGluZyBhIG5ldyBwYWdlIGZvciBwYWdlIGNh
Y2hlIHdoZW4gc3lzdGVtIGJlIHBsYWNlZCBpbiBzb21lIHN0YXRlcy4NCkZvciBsb29rdXAgcGFn
ZXMgcXVpY2tseSBhZGQgYSBuZXcgdGFnIFBBR0VDQUNIRV9UQUdfUkVVU0UgZm9yIHJhZGl4IHRy
ZWUgd2hpY2ggdGFnIHRoZSBwYWdlcyB0aGF0IGlzIHN1aXRhYmxlIGZvciByZXVzaW5nLg0KDQpB
IHBhZ2Ugc3VpdGFibGUgZm9yIHJldXNpbmcgd2l0aGluIG1hcHBpbmcgaXMNCjEuIGNsZWFuDQoy
LiBtYXAgY291bnQgaXMgemVybw0KMy4gd2hvc2UgbWFwcGluZyBpcyBldmljdGFibGUNCg0KQSBw
YWdlIHRhZ2dlZCBhcyBQQUdFQ0FDSEVfVEFHX1JFVVNFIHdoZW4NCjEuIGFmdGVyIHdyaXRlYmFj
ayBhIHBhZ2Ugd2l0aGluIGVuZF9wYWdlX3dyaXRlYmFjayBzZXR0aW5nIHRoZSBwYWdlIGFzIFBB
R0VDQUNIRV9UQUdfUkVVU0UNCjIuIGluIGdlbmVyaWMgdmZzIHJlYWQgcGF0aCBkZWZhdWx0IHRv
IHNldHRpbmcgcGFnZSBhcyBQQUdFQ0FDSEVfVEFHX1JFVVNFDQoNCkEgcGFnZSBjbGVhcmVkIFBB
R0VDQUNIRV9UQUdfUkVVU0Ugd2hlbg0KMS4gcGFnZSBiZWNvbWUgZGlyeSB3aXRoaW4gX19zZXRf
cGFnZV9kaXJ0eSBhbmQgX19zZXRfcGFnZV9kaXJ0eV9ub2J1ZmZlcnMgKGRpcnR5IHBhZ2UgaXMg
bm90IHN1aXRhYmxlIGZvciByZXVzaW5nKQ0KDQpUaGUgc3RlcHMgb2YgcmVzdWluZyBhIHBhZ2Ug
aXMNCjEuIGludmFsaWQgYSBwYWdlIGJ5IGludmFsaWRhdGVfaW5vZGVfcGFnZSAocmVtb3ZlIGZv
cm0gbWFwcGluZykNCjIuIGlzb2xhdGUgZnJvbSBscnUgbGlzdCBieSBpc29sYXRlX2xydV9wYWdl
DQozLiBjbGVhciBwYWdlIHVwdG9kYXRlIGFuZCBvdGhlciBwYWdlIGZsYWdzDQoNCkhvdyB0byBz
dGFydHVwIHRoZSBmdW5jdGlvbmFsDQoxLiB0aGUgc3lzdGVtIGlzIHVuZGVyIGxvdyBtZW1vcnkg
c3RhdGUgYW5kIHRoZXJlIGFyZSBmcyBydyBvcGVyYXRpb25zDQoyLiBwYWdlIGNhY2hlIHNpemUg
aXMgZ2V0IGJpZ2dlciBvdmVyIHN5c2N0bCBsaW1pdA0KDQpJZiBhIGZpbGVzeXN0ZW0gd2FudGVk
IHRvIGludHJvZHVjZSB0aGlzIGZ1bmN0aW9uYWwsIGZvciBleGFtcGxlIGV4dDQsIGRvIGxpa2Ug
YmVsb3c6DQoNCnN0YXRpYyBjb25zdCBzdHJ1Y3QgYWRkcmVzc19zcGFjZV9vcGVyYXRpb25zIGV4
dDRfYW9wcyA9IHsNCgkuLi4NCgkucmVhZHBhZ2UJCT0gZXh0NF9yZWFkcGFnZSwNCgkucmVhZHBh
Z2VzCQk9IGV4dDRfcmVhZHBhZ2VzLA0KCS53cml0ZXBhZ2UJCT0gZXh0NF93cml0ZXBhZ2UsDQoJ
LndyaXRlX2JlZ2luCQk9IGV4dDRfd3JpdGVfYmVnaW4sDQoJLndyaXRlX2VuZAkJPSBleHQ0X3dy
aXRlX2VuZCwNCgkuLi4NCgkucmV1c2VfbWFwcGluZ19wYWdlID0gZ2VuZXJpY19yZXVzZV9tYXBw
aW5nX3BhZ2UsDQp9Ow0KDQotLS0tLdPKvP7Urbz+LS0tLS0NCreivP7IyzogTWljaGFsIEhvY2tv
IFttYWlsdG86bWhvY2tvQGtlcm5lbC5vcmddIA0Kt6LLzcqxvOQ6IDIwMTbE6jXUwjMxyNUgMTc6
MzcNCsrVvP7IyzogemhvdXhpYW5yb25nDQqzrcvNOiB2aXJvQHplbml2LmxpbnV4Lm9yZy51azsg
bGludXgtZnNkZXZlbEB2Z2VyLmtlcm5lbC5vcmc7IGxpbnV4LW1tQGt2YWNrLm9yZzsgWmhvdXhp
eXU7IHdhbmdoYWlqdW4gKEUpOyBZdWNoYW8gKFQpDQrW98ziOiBSZTogW1BBVENIXSByZXVzaW5n
IG9mIG1hcHBpbmcgcGFnZSBzdXBwbGllcyBhIHdheSBmb3IgZmlsZSBwYWdlIGFsbG9jYXRpb24g
dW5kZXIgbG93IG1lbW9yeSBkdWUgdG8gcGFnZWNhY2hlIG92ZXIgc2l6ZSBhbmQgaXMgY29udHJv
bGxlZCBieSBzeXNjdGwgcGFyYW1ldGVycy4gaXQgaXMgdXNlZCBvbmx5IGZvciBydyBwYWdlIGFs
bG9jYXRpb24gcmF0aGVyIHRoYW4gZmF1bHQgb3IgcmVhZGFoZWFkIGFsbG9jYXRpb24uIGl0IGlz
IGxpa2UuLi4NCg0KT24gVHVlIDMxLTA1LTE2IDE3OjA4OjIyLCB6aG91eGlhbnJvbmdAaHVhd2Vp
LmNvbSB3cm90ZToNCj4gRnJvbTogejAwMjgxNDIxIDx6MDAyODE0MjFAbm90ZXNtYWlsLmh1YXdl
aS5jb20+DQo+IA0KPiBjb25zdCBzdHJ1Y3QgYWRkcmVzc19zcGFjZV9vcGVyYXRpb25zIHNwZWNp
YWxfYW9wcyA9IHsNCj4gICAgIC4uLg0KPiAJLnJldXNlX21hcHBpbmdfcGFnZSA9IGdlbmVyaWNf
cmV1c2VfbWFwcGluZ19wYWdlLCB9DQoNClBsZWFzZSB0cnkgdG8gd3JpdGUgYSBwcm9wZXIgY2hh
bmdlbG9nIHdoaWNoIGV4cGxhaW5zIHdoYXQgaXMgdGhlIGNoYW5nZSwgd2h5IGRvIHdlIG5lZWQg
aXQgYW5kIHdobyBpcyBpdCBnb2luZyB0byB1c2UuDQotLQ0KTWljaGFsIEhvY2tvDQpTVVNFIExh
YnMNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
