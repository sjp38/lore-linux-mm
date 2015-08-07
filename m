Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8DE0E6B0253
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 03:33:04 -0400 (EDT)
Received: by pdrh1 with SMTP id h1so24259579pdr.0
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 00:33:04 -0700 (PDT)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id pu4si16103793pbb.18.2015.08.07.00.33.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Aug 2015 00:33:03 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp ([10.7.69.201])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id t777X0KX009744
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Fri, 7 Aug 2015 16:33:01 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2 0/2] hugetlb: display per-process/per-vma usage
Date: Fri, 7 Aug 2015 07:24:49 +0000
Message-ID: <1438932278-7973-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <20150806074443.GA7870@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20150806074443.GA7870@hori1.linux.bs1.fc.nec.co.jp>
Content-Language: ja-JP
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, =?utf-8?B?SsO2cm4gRW5nZWw=?= <joern@purestorage.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

SSB3cm90ZSBwYXRjaGVzIHRvIGV4cG9ydCBodWdldGxiIHVzYWdlIGluZm8gdmlhIC9wcm9jL3Bp
ZC97c21hcHMsc3RhdHVzfS4NCkluIHRoaXMgdmVyc2lvbiwgSSBhZGRlZCBwYXRjaCAyIGZvciAv
cHJvYy9waWQvc3RhdHVzIHRvIGRlYWwgd2l0aCB0aGUNCmluY29uc2lzdGVuY3kgY29uY2VybiBm
cm9tIERhdmlkICh0aGFua3MgZm9yIHRoZSBjb21tZW50KS4NCg0KVGhhbmtzLA0KTmFveWEgSG9y
aWd1Y2hpDQotLS0NClN1bW1hcnk6DQoNCk5hb3lhIEhvcmlndWNoaSAoMik6DQogICAgICBzbWFw
czogZmlsbCBtaXNzaW5nIGZpZWxkcyBmb3Igdm1hKFZNX0hVR0VUTEIpDQogICAgICBtbTogaHVn
ZXRsYjogYWRkIFZtSHVnZXRsYlJTUzogZmllbGQgaW4gL3Byb2MvcGlkL3N0YXR1cw0KDQogZnMv
cHJvYy90YXNrX21tdS5jICAgICAgIHwgMzIgKysrKysrKysrKysrKysrKysrKysrKysrKysrKysr
Ky0NCiBpbmNsdWRlL2xpbnV4L2h1Z2V0bGIuaCAgfCAxOCArKysrKysrKysrKysrKysrKysNCiBp
bmNsdWRlL2xpbnV4L21tLmggICAgICAgfCAgMyArKysNCiBpbmNsdWRlL2xpbnV4L21tX3R5cGVz
LmggfCAgMyArKysNCiBtbS9odWdldGxiLmMgICAgICAgICAgICAgfCAgOSArKysrKysrKysNCiBt
bS9tZW1vcnkuYyAgICAgICAgICAgICAgfCAgNCArKy0tDQogbW0vcm1hcC5jICAgICAgICAgICAg
ICAgIHwgIDQgKysrLQ0KIDcgZmlsZXMgY2hhbmdlZCwgNjkgaW5zZXJ0aW9ucygrKSwgNCBkZWxl
dGlvbnMoLSk=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
