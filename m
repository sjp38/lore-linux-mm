Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39FC4C4360D
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 00:48:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8136020863
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 00:48:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8136020863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=zte.com.cn
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D4D476B0005; Sun,  8 Sep 2019 20:48:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CFE056B0006; Sun,  8 Sep 2019 20:48:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BEBF26B0007; Sun,  8 Sep 2019 20:48:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0244.hostedemail.com [216.40.44.244])
	by kanga.kvack.org (Postfix) with ESMTP id 9C9A46B0005
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 20:48:06 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 48C7A6D73
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 00:48:06 +0000 (UTC)
X-FDA: 75913545372.21.park05_c76090e3f117
X-HE-Tag: park05_c76090e3f117
X-Filterd-Recvd-Size: 3865
Received: from mxhk.zte.com.cn (mxhk.zte.com.cn [63.217.80.70])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 00:48:05 +0000 (UTC)
Received: from mse-fl2.zte.com.cn (unknown [10.30.14.239])
	by Forcepoint Email with ESMTPS id 7C091B6EFF73FAFBD049;
	Mon,  9 Sep 2019 08:48:02 +0800 (CST)
Received: from kjyxapp02.zte.com.cn ([10.30.12.201])
	by mse-fl2.zte.com.cn with SMTP id x890loCS077836;
	Mon, 9 Sep 2019 08:47:50 +0800 (GMT-8)
	(envelope-from wang.yi59@zte.com.cn)
Received: from mapi (kjyxapp01[null])
	by mapi (Zmail) with MAPI id mid14;
	Mon, 9 Sep 2019 08:47:56 +0800 (CST)
Date: Mon, 9 Sep 2019 08:47:56 +0800 (CST)
X-Zmail-TransId: 2b035d75a13c241f1ebb
X-Mailer: Zmail v1.0
Message-ID: <201909090847560209680@zte.com.cn>
In-Reply-To: <1566978161-7293-1-git-send-email-wang.yi59@zte.com.cn>
References: 1566978161-7293-1-git-send-email-wang.yi59@zte.com.cn
Mime-Version: 1.0
From: <wang.yi59@zte.com.cn>
To: <akpm@linux-foundation.org>
Cc: <keescook@chromium.org>, <dan.j.williams@intel.com>, <cai@lca.pw>,
        <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
        <osalvador@suse.de>, <mhocko@suse.com>, <rppt@linux.ibm.com>,
        <david@redhat.com>, <richardw.yang@linux.intel.com>,
        <xue.zhihong@zte.com.cn>, <up2wing@gmail.com>,
        <wang.liang82@zte.com.cn>, <wang.yi59@zte.com.cn>
Subject: =?UTF-8?B?UmU6W1BBVENIXSBtbTogZml4IC1XbWlzc2luZy1wcm90b3R5cGVzIHdhcm5pbmdz?=
Content-Type: multipart/mixed;
	boundary="=====_001_next====="
X-MAIL:mse-fl2.zte.com.cn x890loCS077836
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



--=====_001_next=====
Content-Type: multipart/alternative;
	boundary="=====_003_next====="


--=====_003_next=====
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: base64

R2VudGxlIHBpbmcgOikKCj4gV2UgZ2V0IHR3byB3YXJuaW5ncyB3aGVuIGJ1aWxkIGtlcm5lbCBX
PTE6Cj4gbW0vc2h1ZmZsZS5jOjM2OjEyOiB3YXJuaW5nOiBubyBwcmV2aW91cyBwcm90b3R5cGUg
Zm9yIOKAmHNodWZmbGVfc2hvd+KAmQo+IFstV21pc3NpbmctcHJvdG90eXBlc10KPiBtbS9zcGFy
c2UuYzoyMjA6Njogd2FybmluZzogbm8gcHJldmlvdXMgcHJvdG90eXBlIGZvcgo+IOKAmHN1YnNl
Y3Rpb25fbWFza19zZXTigJkgWy1XbWlzc2luZy1wcm90b3R5cGVzXQo+Cj4gTWFrZSB0aGUgZnVu
Y3Rpb24gc3RhdGljIHRvIGZpeCB0aGlzLgo+Cj4gU2lnbmVkLW9mZi1ieTogWWkgV2FuZyA8d2Fu
Zy55aTU5QHp0ZS5jb20uY24+Cj4gLS0tCj4gIG1tL3NodWZmbGUuYyB8IDIgKy0KPiAgbW0vc3Bh
cnNlLmMgIHwgMiArLQo+ICAyIGZpbGVzIGNoYW5nZWQsIDIgaW5zZXJ0aW9ucygrKSwgMiBkZWxl
dGlvbnMoLSkKPgo+IGRpZmYgLS1naXQgYS9tbS9zaHVmZmxlLmMgYi9tbS9zaHVmZmxlLmMKPiBp
bmRleCAzY2UxMjQ4Li5iM2ZlOTdmIDEwMDY0NAo+IC0tLSBhL21tL3NodWZmbGUuYwo+ICsrKyBi
L21tL3NodWZmbGUuYwo+IEBAIC0zMyw3ICszMyw3IEBAIF9fbWVtaW5pdCB2b2lkIHBhZ2VfYWxs
b2Nfc2h1ZmZsZShlbnVtIG1tX3NodWZmbGVfY3RsIGN0bCkKPiAgfQo+Cj4gIHN0YXRpYyBib29s
IHNodWZmbGVfcGFyYW07Cj4gLWV4dGVybiBpbnQgc2h1ZmZsZV9zaG93KGNoYXIgKmJ1ZmZlciwg
Y29uc3Qgc3RydWN0IGtlcm5lbF9wYXJhbSAqa3ApCj4gK3N0YXRpYyBpbnQgc2h1ZmZsZV9zaG93
KGNoYXIgKmJ1ZmZlciwgY29uc3Qgc3RydWN0IGtlcm5lbF9wYXJhbSAqa3ApCj4gIHsKPiAgICAg
IHJldHVybiBzcHJpbnRmKGJ1ZmZlciwgIiVjXG4iLCB0ZXN0X2JpdChTSFVGRkxFX0VOQUJMRSwg
JnNodWZmbGVfc3RhdGUpCj4gICAgICAgICAgICAgID8gJ1knIDogJ04nKTsKPiBkaWZmIC0tZ2l0
IGEvbW0vc3BhcnNlLmMgYi9tbS9zcGFyc2UuYwo+IGluZGV4IDcyZjAxMGQuLjQ5MDA2ZGQgMTAw
NjQ0Cj4gLS0tIGEvbW0vc3BhcnNlLmMKPiArKysgYi9tbS9zcGFyc2UuYwo+IEBAIC0yMTcsNyAr
MjE3LDcgQEAgc3RhdGljIGlubGluZSB1bnNpZ25lZCBsb25nIGZpcnN0X3ByZXNlbnRfc2VjdGlv
bl9ucih2b2lkKQo+ICAgICAgcmV0dXJuIG5leHRfcHJlc2VudF9zZWN0aW9uX25yKC0xKTsKPiAg
fQo+Cj4gLXZvaWQgc3Vic2VjdGlvbl9tYXNrX3NldCh1bnNpZ25lZCBsb25nICptYXAsIHVuc2ln
bmVkIGxvbmcgcGZuLAo+ICtzdGF0aWMgdm9pZCBzdWJzZWN0aW9uX21hc2tfc2V0KHVuc2lnbmVk
IGxvbmcgKm1hcCwgdW5zaWduZWQgbG9uZyBwZm4sCj4gICAgICAgICAgdW5zaWduZWQgbG9uZyBu
cl9wYWdlcykKPiAgewo+ICAgICAgaW50IGlkeCA9IHN1YnNlY3Rpb25fbWFwX2luZGV4KHBmbik7
Cj4gLS0KPiAxLjguMy4xCgoKLS0tCkJlc3Qgd2lzaGVzCllpIFdhbmc=


--=====_003_next=====--

--=====_001_next=====--


