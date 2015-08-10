Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 948386B0258
	for <linux-mm@kvack.org>; Sun,  9 Aug 2015 20:53:05 -0400 (EDT)
Received: by pawu10 with SMTP id u10so127557194paw.1
        for <linux-mm@kvack.org>; Sun, 09 Aug 2015 17:53:05 -0700 (PDT)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id bt2si30502616pdb.15.2015.08.09.17.53.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 09 Aug 2015 17:53:04 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp ([10.7.69.201])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id t7A0r0T5020273
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 09:53:01 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v3 3/3] Documentation/filesystems/proc.txt: document hugetlb
 RSS
Date: Mon, 10 Aug 2015 00:47:09 +0000
Message-ID: <1439167624-17772-4-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <20150807155537.d483456f753355059f9ce10a@linux-foundation.org>
 <1439167624-17772-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1439167624-17772-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, =?utf-8?B?SsO2cm4gRW5nZWw=?= <joern@purestorage.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

L3Byb2MvUElEL3tzdGF0dXMsc21hcHN9IGlzIGF3YXJlIG9mIGh1Z2V0bGIgUlNTIG5vdywgc28g
bGV0J3MgZG9jdW1lbnQgaXQuDQoNClNpZ25lZC1vZmYtYnk6IE5hb3lhIEhvcmlndWNoaSA8bi1o
b3JpZ3VjaGlAYWguanAubmVjLmNvbT4NCi0tLQ0KIERvY3VtZW50YXRpb24vZmlsZXN5c3RlbXMv
cHJvYy50eHQgfCAxMCArKysrKysrKy0tDQogMSBmaWxlIGNoYW5nZWQsIDggaW5zZXJ0aW9ucygr
KSwgMiBkZWxldGlvbnMoLSkNCg0KZGlmZiAtLWdpdCB2NC4yLXJjNC5vcmlnL0RvY3VtZW50YXRp
b24vZmlsZXN5c3RlbXMvcHJvYy50eHQgdjQuMi1yYzQvRG9jdW1lbnRhdGlvbi9maWxlc3lzdGVt
cy9wcm9jLnR4dA0KaW5kZXggNmY3ZmFmZGUwODg0Li5jYjg1NjVlMTUwZWQgMTAwNjQ0DQotLS0g
djQuMi1yYzQub3JpZy9Eb2N1bWVudGF0aW9uL2ZpbGVzeXN0ZW1zL3Byb2MudHh0DQorKysgdjQu
Mi1yYzQvRG9jdW1lbnRhdGlvbi9maWxlc3lzdGVtcy9wcm9jLnR4dA0KQEAgLTE2OCw2ICsxNjgs
NyBAQCBGb3IgZXhhbXBsZSwgdG8gZ2V0IHRoZSBzdGF0dXMgaW5mb3JtYXRpb24gb2YgYSBwcm9j
ZXNzLCBhbGwgeW91IGhhdmUgdG8gZG8gaXMNCiAgIFZtTGNrOiAgICAgICAgIDAga0INCiAgIFZt
SFdNOiAgICAgICA0NzYga0INCiAgIFZtUlNTOiAgICAgICA0NzYga0INCisgIFZtSHVnZXRsYlJT
UzogIDAga0INCiAgIFZtRGF0YTogICAgICAxNTYga0INCiAgIFZtU3RrOiAgICAgICAgODgga0IN
CiAgIFZtRXhlOiAgICAgICAgNjgga0INCkBAIC0yMzAsNiArMjMxLDcgQEAgVGFibGUgMS0yOiBD
b250ZW50cyBvZiB0aGUgc3RhdHVzIGZpbGVzIChhcyBvZiA0LjEpDQogIFZtTGNrICAgICAgICAg
ICAgICAgICAgICAgICBsb2NrZWQgbWVtb3J5IHNpemUNCiAgVm1IV00gICAgICAgICAgICAgICAg
ICAgICAgIHBlYWsgcmVzaWRlbnQgc2V0IHNpemUgKCJoaWdoIHdhdGVyIG1hcmsiKQ0KICBWbVJT
UyAgICAgICAgICAgICAgICAgICAgICAgc2l6ZSBvZiBtZW1vcnkgcG9ydGlvbnMNCisgVm1IdWdl
dGxiUlNTICAgICAgICAgICAgICAgIHNpemUgb2YgaHVnZXRsYiBtZW1vcnkgcG9ydGlvbnMNCiAg
Vm1EYXRhICAgICAgICAgICAgICAgICAgICAgIHNpemUgb2YgZGF0YSwgc3RhY2ssIGFuZCB0ZXh0
IHNlZ21lbnRzDQogIFZtU3RrICAgICAgICAgICAgICAgICAgICAgICBzaXplIG9mIGRhdGEsIHN0
YWNrLCBhbmQgdGV4dCBzZWdtZW50cw0KICBWbUV4ZSAgICAgICAgICAgICAgICAgICAgICAgc2l6
ZSBvZiB0ZXh0IHNlZ21lbnQNCkBAIC00NDAsOCArNDQyLDEyIEBAIGluZGljYXRlcyB0aGUgYW1v
dW50IG9mIG1lbW9yeSBjdXJyZW50bHkgbWFya2VkIGFzIHJlZmVyZW5jZWQgb3IgYWNjZXNzZWQu
DQogIkFub255bW91cyIgc2hvd3MgdGhlIGFtb3VudCBvZiBtZW1vcnkgdGhhdCBkb2VzIG5vdCBi
ZWxvbmcgdG8gYW55IGZpbGUuICBFdmVuDQogYSBtYXBwaW5nIGFzc29jaWF0ZWQgd2l0aCBhIGZp
bGUgbWF5IGNvbnRhaW4gYW5vbnltb3VzIHBhZ2VzOiB3aGVuIE1BUF9QUklWQVRFDQogYW5kIGEg
cGFnZSBpcyBtb2RpZmllZCwgdGhlIGZpbGUgcGFnZSBpcyByZXBsYWNlZCBieSBhIHByaXZhdGUg
YW5vbnltb3VzIGNvcHkuDQotIlN3YXAiIHNob3dzIGhvdyBtdWNoIHdvdWxkLWJlLWFub255bW91
cyBtZW1vcnkgaXMgYWxzbyB1c2VkLCBidXQgb3V0IG9uDQotc3dhcC4NCisiU3dhcCIgc2hvd3Mg
aG93IG11Y2ggd291bGQtYmUtYW5vbnltb3VzIG1lbW9yeSBpcyBhbHNvIHVzZWQsIGJ1dCBvdXQg
b24gc3dhcC4NCitTaW5jZSA0LjMsICJSU1MiIGNvbnRhaW5zIHRoZSBhbW91bnQgb2YgbWFwcGlu
Z3MgZm9yIGh1Z2V0bGIgcGFnZXMuIEFsdGhvdWdoDQorUlNTIG9mIGh1Z2V0bGIgbWFwcGluZ3Mg
aXMgbWFpbnRhaW5lZCBzZXBhcmF0ZWx5IGZyb20gbm9ybWFsIG1hcHBpbmdzDQorKGRpc3BsYXll
ZCBpbiAiVm1IdWdldGxiUlNTIiBmaWVsZCBvZiAvcHJvYy9QSUQvc3RhdHVzLCkgL3Byb2MvUElE
L3NtYXBzIHNob3dzDQorYm90aCBtYXBwaW5ncyBpbiAiUlNTIiBmaWVsZC4gVXNlcnNwYWNlIGFw
cGxpY2F0aW9ucyBjbGVhcmx5IGRpc3Rpbmd1aXNoIHRoZQ0KK3R5cGUgb2YgbWFwcGluZyB3aXRo
ICdodCcgZmxhZyBpbiAiVm1GbGFncyIgZmllbGQuDQogDQogIlZtRmxhZ3MiIGZpZWxkIGRlc2Vy
dmVzIGEgc2VwYXJhdGUgZGVzY3JpcHRpb24uIFRoaXMgbWVtYmVyIHJlcHJlc2VudHMgdGhlIGtl
cm5lbA0KIGZsYWdzIGFzc29jaWF0ZWQgd2l0aCB0aGUgcGFydGljdWxhciB2aXJ0dWFsIG1lbW9y
eSBhcmVhIGluIHR3byBsZXR0ZXIgZW5jb2RlZA0KLS0gDQoyLjQuMw0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
