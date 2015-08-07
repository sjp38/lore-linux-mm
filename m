Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 48DE66B0253
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 03:33:05 -0400 (EDT)
Received: by pabxd6 with SMTP id xd6so63985451pab.2
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 00:33:05 -0700 (PDT)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id mc9si11041734pdb.199.2015.08.07.00.33.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Aug 2015 00:33:04 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp ([10.7.69.201])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id t777X0KZ009744
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Fri, 7 Aug 2015 16:33:01 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2 1/2] smaps: fill missing fields for vma(VM_HUGETLB)
Date: Fri, 7 Aug 2015 07:24:50 +0000
Message-ID: <1438932278-7973-2-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <20150806074443.GA7870@hori1.linux.bs1.fc.nec.co.jp>
 <1438932278-7973-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1438932278-7973-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="utf-8"
Content-ID: <019B25B7041C0D43A202E166A1F4B9FD@gisp.nec.co.jp>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, =?utf-8?B?SsO2cm4gRW5nZWw=?= <joern@purestorage.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Q3VycmVudGx5IHNtYXBzIHJlcG9ydHMgbWFueSB6ZXJvIGZpZWxkcyBmb3Igdm1hKFZNX0hVR0VU
TEIpLCB3aGljaCBpcw0KaW5jb252ZW5pZW50IHdoZW4gd2Ugd2FudCB0byBrbm93IHBlci10YXNr
IG9yIHBlci12bWEgYmFzZSBodWdldGxiIHVzYWdlLg0KVGhpcyBwYXRjaCBlbmFibGVzIHRoZXNl
IGZpZWxkcyBieSBpbnRyb2R1Y2luZyBzbWFwc19odWdldGxiX3JhbmdlKCkuDQoNCmJlZm9yZSBw
YXRjaDoNCg0KICBTaXplOiAgICAgICAgICAgICAgMjA0ODAga0INCiAgUnNzOiAgICAgICAgICAg
ICAgICAgICAwIGtCDQogIFBzczogICAgICAgICAgICAgICAgICAgMCBrQg0KICBTaGFyZWRfQ2xl
YW46ICAgICAgICAgIDAga0INCiAgU2hhcmVkX0RpcnR5OiAgICAgICAgICAwIGtCDQogIFByaXZh
dGVfQ2xlYW46ICAgICAgICAgMCBrQg0KICBQcml2YXRlX0RpcnR5OiAgICAgICAgIDAga0INCiAg
UmVmZXJlbmNlZDogICAgICAgICAgICAwIGtCDQogIEFub255bW91czogICAgICAgICAgICAgMCBr
Qg0KICBBbm9uSHVnZVBhZ2VzOiAgICAgICAgIDAga0INCiAgU3dhcDogICAgICAgICAgICAgICAg
ICAwIGtCDQogIEtlcm5lbFBhZ2VTaXplOiAgICAgMjA0OCBrQg0KICBNTVVQYWdlU2l6ZTogICAg
ICAgIDIwNDgga0INCiAgTG9ja2VkOiAgICAgICAgICAgICAgICAwIGtCDQogIFZtRmxhZ3M6IHJk
IHdyIG1yIG13IG1lIGRlIGh0DQoNCmFmdGVyIHBhdGNoOg0KDQogIFNpemU6ICAgICAgICAgICAg
ICAyMDQ4MCBrQg0KICBSc3M6ICAgICAgICAgICAgICAgMTg0MzIga0INCiAgUHNzOiAgICAgICAg
ICAgICAgIDE4NDMyIGtCDQogIFNoYXJlZF9DbGVhbjogICAgICAgICAgMCBrQg0KICBTaGFyZWRf
RGlydHk6ICAgICAgICAgIDAga0INCiAgUHJpdmF0ZV9DbGVhbjogICAgICAgICAwIGtCDQogIFBy
aXZhdGVfRGlydHk6ICAgICAxODQzMiBrQg0KICBSZWZlcmVuY2VkOiAgICAgICAgMTg0MzIga0IN
CiAgQW5vbnltb3VzOiAgICAgICAgIDE4NDMyIGtCDQogIEFub25IdWdlUGFnZXM6ICAgICAgICAg
MCBrQg0KICBTd2FwOiAgICAgICAgICAgICAgICAgIDAga0INCiAgS2VybmVsUGFnZVNpemU6ICAg
ICAyMDQ4IGtCDQogIE1NVVBhZ2VTaXplOiAgICAgICAgMjA0OCBrQg0KICBMb2NrZWQ6ICAgICAg
ICAgICAgICAgIDAga0INCiAgVm1GbGFnczogcmQgd3IgbXIgbXcgbWUgZGUgaHQNCg0KU2lnbmVk
LW9mZi1ieTogTmFveWEgSG9yaWd1Y2hpIDxuLWhvcmlndWNoaUBhaC5qcC5uZWMuY29tPg0KQWNr
ZWQtYnk6IErDtnJuIEVuZ2VsIDxqb2VybkBsb2dmcy5vcmc+DQotLS0NCiBmcy9wcm9jL3Rhc2tf
bW11LmMgfCAyNyArKysrKysrKysrKysrKysrKysrKysrKysrKysNCiAxIGZpbGUgY2hhbmdlZCwg
MjcgaW5zZXJ0aW9ucygrKQ0KDQpkaWZmIC0tZ2l0IHY0LjItcmM0Lm9yaWcvZnMvcHJvYy90YXNr
X21tdS5jIHY0LjItcmM0L2ZzL3Byb2MvdGFza19tbXUuYw0KaW5kZXggY2ExZTA5MTg4MWQ0Li5j
NzIxODYwMzMwNmQgMTAwNjQ0DQotLS0gdjQuMi1yYzQub3JpZy9mcy9wcm9jL3Rhc2tfbW11LmMN
CisrKyB2NC4yLXJjNC9mcy9wcm9jL3Rhc2tfbW11LmMNCkBAIC02MTAsMTIgKzYxMCwzOSBAQCBz
dGF0aWMgdm9pZCBzaG93X3NtYXBfdm1hX2ZsYWdzKHN0cnVjdCBzZXFfZmlsZSAqbSwgc3RydWN0
IHZtX2FyZWFfc3RydWN0ICp2bWEpDQogCXNlcV9wdXRjKG0sICdcbicpOw0KIH0NCiANCisjaWZk
ZWYgQ09ORklHX0hVR0VUTEJfUEFHRQ0KK3N0YXRpYyBpbnQgc21hcHNfaHVnZXRsYl9yYW5nZShw
dGVfdCAqcHRlLCB1bnNpZ25lZCBsb25nIGhtYXNrLA0KKwkJCQkgdW5zaWduZWQgbG9uZyBhZGRy
LCB1bnNpZ25lZCBsb25nIGVuZCwNCisJCQkJIHN0cnVjdCBtbV93YWxrICp3YWxrKQ0KK3sNCisJ
c3RydWN0IG1lbV9zaXplX3N0YXRzICptc3MgPSB3YWxrLT5wcml2YXRlOw0KKwlzdHJ1Y3Qgdm1f
YXJlYV9zdHJ1Y3QgKnZtYSA9IHdhbGstPnZtYTsNCisJc3RydWN0IHBhZ2UgKnBhZ2UgPSBOVUxM
Ow0KKw0KKwlpZiAocHRlX3ByZXNlbnQoKnB0ZSkpIHsNCisJCXBhZ2UgPSB2bV9ub3JtYWxfcGFn
ZSh2bWEsIGFkZHIsICpwdGUpOw0KKwl9IGVsc2UgaWYgKGlzX3N3YXBfcHRlKCpwdGUpKSB7DQor
CQlzd3BfZW50cnlfdCBzd3BlbnQgPSBwdGVfdG9fc3dwX2VudHJ5KCpwdGUpOw0KKw0KKwkJaWYg
KGlzX21pZ3JhdGlvbl9lbnRyeShzd3BlbnQpKQ0KKwkJCXBhZ2UgPSBtaWdyYXRpb25fZW50cnlf
dG9fcGFnZShzd3BlbnQpOw0KKwl9DQorCWlmIChwYWdlKQ0KKwkJc21hcHNfYWNjb3VudChtc3Ms
IHBhZ2UsIGh1Z2VfcGFnZV9zaXplKGhzdGF0ZV92bWEodm1hKSksDQorCQkJICAgICAgcHRlX3lv
dW5nKCpwdGUpLCBwdGVfZGlydHkoKnB0ZSkpOw0KKwlyZXR1cm4gMDsNCit9DQorI2VuZGlmIC8q
IEhVR0VUTEJfUEFHRSAqLw0KKw0KIHN0YXRpYyBpbnQgc2hvd19zbWFwKHN0cnVjdCBzZXFfZmls
ZSAqbSwgdm9pZCAqdiwgaW50IGlzX3BpZCkNCiB7DQogCXN0cnVjdCB2bV9hcmVhX3N0cnVjdCAq
dm1hID0gdjsNCiAJc3RydWN0IG1lbV9zaXplX3N0YXRzIG1zczsNCiAJc3RydWN0IG1tX3dhbGsg
c21hcHNfd2FsayA9IHsNCiAJCS5wbWRfZW50cnkgPSBzbWFwc19wdGVfcmFuZ2UsDQorI2lmZGVm
IENPTkZJR19IVUdFVExCX1BBR0UNCisJCS5odWdldGxiX2VudHJ5ID0gc21hcHNfaHVnZXRsYl9y
YW5nZSwNCisjZW5kaWYNCiAJCS5tbSA9IHZtYS0+dm1fbW0sDQogCQkucHJpdmF0ZSA9ICZtc3Ms
DQogCX07DQotLSANCjIuNC4zDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
