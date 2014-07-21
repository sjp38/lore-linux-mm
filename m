Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 61A066B0036
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 01:36:01 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id q58so7004427wes.7
        for <linux-mm@kvack.org>; Sun, 20 Jul 2014 22:36:00 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id s1si18259466wif.8.2014.07.20.22.35.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 20 Jul 2014 22:35:59 -0700 (PDT)
From: "Huangpeng (Peter)" <peter.huangpeng@huawei.com>
Subject: =?utf-8?B?W1BBVENIXSBtbe+8mmJ1Z2ZpeCwgcGZuX3ZhbGlkIHNvbWV0aW1lcyByZXR1?=
 =?utf-8?Q?rn_incorrect_when_memmap_parameter_specified?=
Date: Mon, 21 Jul 2014 05:35:31 +0000
Message-ID: <615092B2FD0E7648B6E4B43E029BCFB852D66798@SZXEMA503-MBS.china.huawei.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.cz" <mhocko@suse.cz>, "liwanp@linux.vnet.ibm.com" <liwanp@linux.vnet.ibm.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "Wulizhen (Pss)" <pss.wulizhen@huawei.com>

SW4gc3BhcnNlIG1lbW9yeSBtb2RlLCBJIGFkZCAibWVtbWFwID0gMjAwTSQweDEwMzM4MDAwMDAi
IGludG8gbWVudS5sc3QsDQp0aGVuIEkgZm91bmQgdGhlIGluZm9ybWF0aW9uIGluIC9wcm9jL2lv
bWVtIGlzIHNob3duIGFzOg0KLi4uLi4uLi4uLi4uLi4uLi4NCmZlZTAwMDAwLWZlZTAwZmZmIDog
TG9jYWwgQVBJQw0KICBmZWUwMDAwMC1mZWUwMGZmZiA6IHJlc2VydmVkDQogICAgZmVlMDAwMDAt
ZmVlMDBmZmYgOiBwbnAgMDA6MDgNCmZmZjAwMDAwLWZmZmZmZmZmIDogcmVzZXJ2ZWQNCjEwMDAw
MDAwMC0xMDMzN2ZmZmZmIDogU3lzdGVtIFJBTQ0KMTAzMzgwMDAwMC0xMDNmZmZmZmZmIDogcmVz
ZXJ2ZWQNCnRoZSByZXR1cm4gdmFsdWUgb2YgZnVuY3Rpb24gcGZuX3ZhbGlkLCB3aGljaCBjaGVj
a3Mgd2hldGhlciBwZm4gMHgxMDMzODAwIGlzIHZhbGlkLA0KaXMgbm9uLXplcm8uVGh1cywgaXQg
d2lsbCB0aGVyZWFmdGVyIHJ1biB0aGUgZnVuY3Rpb24gUGFnZVJlc2VydmVkKCksIHdoaWNoIHJl
dHVybnMgMCwNCkkgdGhpbmsgdGhlIHJldHVybiB2YWx1ZSBvZiAwIGlzIHdyb25nLCBhcyB0aGF0
IHBmbiAweDEwMzM4MDAgaXMgYWN0dWFsbHkgcmVzZXJ2ZWQuDQpJIHByb2JlZCBmdXJ0aGVyLCBh
bmQgZm91bmQgdGhhdDogdGhlIHNlY3Rpb24gWzB4MTAzMzAwMDAwMH4weDEwMzNBRkZGRkZGXSwg
aW5jbHVkaW5nDQpwZm4gMHgxMDMzODAwLCBpcyBpbml0aWFsaXplZCBkdXJpbmcga2VybmVsIHN0
YXJ0aW5nIHVwLiBIb3dldmVyLCB0aGUgcGFnZSBzdHVyY3R1cmVzDQpjb3JyZXNwb25kaW5nIHRv
IHRoYXQgc2VjdGlvbiBhcmUganVzdCBwYXJ0aWFsbHkgaW5pdGlhbHplZCwNCmtub3duIGFzIFsw
eDEwMzMwMDAwMDB+KG1heF9wZm4gLTEpXShtYXhfcGZuID0gMHgxMDMzODAwKS4gV2hpY2ggbWVh
bnMgdGhhdCwgcGZuIDB4MTAzMzgwMA0KaXMgdmFsaWQoYXMgZnVuY3Rpb24gcGZuX3ZhbGlkIHRl
bGxzKSwgYnV0IGl0cyByZWxhdGVkIHBhZ2Ugc3RydWN0dXJlcyBhcmUgbm90IGluaXRpYWxpemVk
LA0Kd2hpY2ggcmVzdWx0cyBpbiB0aGUgcHJvYmxlbSBzaG93biBhYm92ZTogcGZuIDB4MTAzMzgw
MCBpcyBvZiB0eXBlIHJlc2VydmVkLCBidXQgdGhlIGZ1bmN0aW9uDQpQYWdlUmVzZXJ2ZWQgc2hv
d3MgdGhhdCBpdCdzIG5vdC4NCg0KaSB0aGluayBpbiB0aGUgZnVudGlvbiBvZiBwZm5fdmFsaWQg
c2hvdWxkIGJlIGFkZCBhIGNvbmRpdGlvbjogcGZuID49IG1heF9wZm4uDQoNClNpZ25lZC1vZmYt
Ynk6IFd1bGl6aGVuIDxwc3Mud3VsaXpoZW5AaHVhd2VpLmNvbT4NCi0tLQ0KIGluY2x1ZGUvbGlu
dXgvbW16b25lLmggfCAyICstDQogbW0vbm9ib290bWVtLmMgICAgICAgICB8IDIgKy0NCiAyIGZp
bGVzIGNoYW5nZWQsIDIgaW5zZXJ0aW9ucygrKSwgMiBkZWxldGlvbnMoLSkNCg0KZGlmZiAtLWdp
dCBhL2luY2x1ZGUvbGludXgvbW16b25lLmggYi9pbmNsdWRlL2xpbnV4L21tem9uZS5oDQppbmRl
eCA4MzVhYTNkLi5jNTQyODRiIDEwMDY0NA0KLS0tIGEvaW5jbHVkZS9saW51eC9tbXpvbmUuaA0K
KysrIGIvaW5jbHVkZS9saW51eC9tbXpvbmUuaA0KQEAgLTExOTksNyArMTE5OSw3IEBAIHN0YXRp
YyBpbmxpbmUgc3RydWN0IG1lbV9zZWN0aW9uICpfX3Bmbl90b19zZWN0aW9uKHVuc2lnbmVkIGxv
bmcgcGZuKQ0KICNpZm5kZWYgQ09ORklHX0hBVkVfQVJDSF9QRk5fVkFMSUQNCiBzdGF0aWMgaW5s
aW5lIGludCBwZm5fdmFsaWQodW5zaWduZWQgbG9uZyBwZm4pDQogew0KLSBpZiAocGZuX3RvX3Nl
Y3Rpb25fbnIocGZuKSA+PSBOUl9NRU1fU0VDVElPTlMpDQorIGlmIChwZm4gPj0gbWF4X3BmbiB8
fCBwZm5fdG9fc2VjdGlvbl9ucihwZm4pID49IE5SX01FTV9TRUNUSU9OUykNCiAgcmV0dXJuIDA7
DQogIHJldHVybiB2YWxpZF9zZWN0aW9uKF9fbnJfdG9fc2VjdGlvbihwZm5fdG9fc2VjdGlvbl9u
cihwZm4pKSk7DQogfQ0KZGlmZiAtLWdpdCBhL21tL25vYm9vdG1lbS5jIGIvbW0vbm9ib290bWVt
LmMNCmluZGV4IDA0YTlkOTQuLjdlYjI3M2UgMTAwNjQ0DQotLS0gYS9tbS9ub2Jvb3RtZW0uYw0K
KysrIGIvbW0vbm9ib290bWVtLmMNCkBAIC0zMSw3ICszMSw3IEBAIEVYUE9SVF9TWU1CT0woY29u
dGlnX3BhZ2VfZGF0YSk7DQogdW5zaWduZWQgbG9uZyBtYXhfbG93X3BmbjsNCiB1bnNpZ25lZCBs
b25nIG1pbl9sb3dfcGZuOw0KIHVuc2lnbmVkIGxvbmcgbWF4X3BmbjsNCi0NCitFWFBPUlRfU1lN
Qk9MKG1heF9wZm4pOw0KIHN0YXRpYyB2b2lkICogX19pbml0IF9fYWxsb2NfbWVtb3J5X2NvcmVf
ZWFybHkoaW50IG5pZCwgdTY0IHNpemUsIHU2NCBhbGlnbiwNCiAgdTY0IGdvYWwsIHU2NCBsaW1p
dCkNCiB7DQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
