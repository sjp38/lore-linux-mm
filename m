Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F61AC41514
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 07:42:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1531720679
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 07:42:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1531720679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=zte.com.cn
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 928576B000D; Wed, 28 Aug 2019 03:42:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9076E6B000E; Wed, 28 Aug 2019 03:42:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 83BE06B0010; Wed, 28 Aug 2019 03:42:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0081.hostedemail.com [216.40.44.81])
	by kanga.kvack.org (Postfix) with ESMTP id 621C26B000D
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 03:42:32 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 0BCA3181AC9B4
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 07:42:32 +0000 (UTC)
X-FDA: 75871044144.22.vein37_160e72a53b65b
X-HE-Tag: vein37_160e72a53b65b
X-Filterd-Recvd-Size: 3566
Received: from mxct.zte.com.cn (out1.zte.com.cn [202.103.147.172])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 07:42:31 +0000 (UTC)
Received: from mse-fl1.zte.com.cn (unknown [10.30.14.238])
	by Forcepoint Email with ESMTPS id 6D5987D499892B6419E9;
	Wed, 28 Aug 2019 15:42:26 +0800 (CST)
Received: from kjyxapp02.zte.com.cn ([10.30.12.201])
	by mse-fl1.zte.com.cn with SMTP id x7S7epOK046962;
	Wed, 28 Aug 2019 15:40:51 +0800 (GMT-8)
	(envelope-from wang.yi59@zte.com.cn)
Received: from mapi (kjyxapp01[null])
	by mapi (Zmail) with MAPI id mid14;
	Wed, 28 Aug 2019 15:40:54 +0800 (CST)
Date: Wed, 28 Aug 2019 15:40:54 +0800 (CST)
X-Zmail-TransId: 2b035d66300624e50c30
X-Mailer: Zmail v1.0
Message-ID: <201908281540545970180@zte.com.cn>
In-Reply-To: <20190828071021.GD7386@dhcp22.suse.cz>
References: 1566959929-10638-1-git-send-email-wang.yi59@zte.com.cn,20190828071021.GD7386@dhcp22.suse.cz
Mime-Version: 1.0
From: <wang.yi59@zte.com.cn>
To: <mhocko@kernel.org>
Cc: <akpm@linux-foundation.org>, <penguin-kernel@I-love.SAKURA.ne.jp>,
        <guro@fb.com>, <shakeelb@google.com>, <yuzhoujian@didichuxing.com>,
        <jglisse@redhat.com>, <ebiederm@xmission.com>, <hannes@cmpxchg.org>,
        <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
        <xue.zhihong@zte.com.cn>, <up2wing@gmail.com>,
        <wang.liang82@zte.com.cn>
Subject: =?UTF-8?B?UmU6W1BBVENIXSBtbS9vb21fa2lsbC5jOiBmb3ggb29tX2NwdXNldF9lbGlnaWJsZSgpIGNvbW1lbnQ=?=
Content-Type: multipart/mixed;
	boundary="=====_001_next====="
X-MAIL:mse-fl1.zte.com.cn x7S7epOK046962
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

SGkgTWljaGFsLAoKVGhhbmtzIGZvciB5b3VyIGFjayBhbmQgc29ycnkgZm9yIG15IHNwZWxsaW5n
IG1pc3Rha2UgOigKCj4gc0Bmb3hAZml4QAo+Cj4gT24gV2VkIDI4LTA4LTE5IDEwOjM4OjQ5LCBZ
aSBXYW5nIHdyb3RlOgo+ID4gQ29tbWl0IGFjMzExYTE0YzY4MiAoIm9vbTogZGVjb3VwbGUgbWVt
c19hbGxvd2VkIGZyb20gb29tX3Vua2lsbGFibGVfdGFzayIpCj4gPiBjaGFuZ2VkIHRoZSBmdW5j
dGlvbiBoYXNfaW50ZXJzZWN0c19tZW1zX2FsbG93ZWQoKSB0bwo+ID4gb29tX2NwdXNldF9lbGln
aWJsZSgpLCBidXQgZGlkbid0IGNoYW5nZSB0aGUgY29tbWVudCBtZWFud2hpbGUuCj4gPgo+ID4g
TGV0J3MgZml4IHRoaXMuCj4gPgo+ID4gU2lnbmVkLW9mZi1ieTogWWkgV2FuZyA8d2FuZy55aTU5
QHp0ZS5jb20uY24+Cj4KPiBBY2tlZC1ieTogTWljaGFsIEhvY2tvIDxtaG9ja29Ac3VzZS5jb20+
Cj4KPiBUaGFua3MhCj4KPiA+IC0tLQo+ID4gIG1tL29vbV9raWxsLmMgfCAyICstCj4gPiAgMSBm
aWxlIGNoYW5nZWQsIDEgaW5zZXJ0aW9uKCspLCAxIGRlbGV0aW9uKC0pCj4gPgo+ID4gZGlmZiAt
LWdpdCBhL21tL29vbV9raWxsLmMgYi9tbS9vb21fa2lsbC5jCj4gPiBpbmRleCBlZGEyZTJhLi42
NWMwOTJlIDEwMDY0NAo+ID4gLS0tIGEvbW0vb29tX2tpbGwuYwo+ID4gKysrIGIvbW0vb29tX2tp
bGwuYwo+ID4gQEAgLTczLDcgKzczLDcgQEAgc3RhdGljIGlubGluZSBib29sIGlzX21lbWNnX29v
bShzdHJ1Y3Qgb29tX2NvbnRyb2wgKm9jKQo+ID4gIC8qKgo+ID4gICAqIG9vbV9jcHVzZXRfZWxp
Z2libGUoKSAtIGNoZWNrIHRhc2sgZWxpZ2libGl0eSBmb3Iga2lsbAo+ID4gICAqIEBzdGFydDog
dGFzayBzdHJ1Y3Qgb2Ygd2hpY2ggdGFzayB0byBjb25zaWRlcgo+ID4gLSAqIEBtYXNrOiBub2Rl
bWFzayBwYXNzZWQgdG8gcGFnZSBhbGxvY2F0b3IgZm9yIG1lbXBvbGljeSBvb21zCj4gPiArICog
QG9jOiBwb2ludGVyIHRvIHN0cnVjdCBvb21fY29udHJvbAo+ID4gICAqCj4gPiAgICogVGFzayBl
bGlnaWJpbGl0eSBpcyBkZXRlcm1pbmVkIGJ5IHdoZXRoZXIgb3Igbm90IGEgY2FuZGlkYXRlIHRh
c2ssIEB0c2ssCj4gPiAgICogc2hhcmVzIHRoZSBzYW1lIG1lbXBvbGljeSBub2RlcyBhcyBjdXJy
ZW50IGlmIGl0IGlzIGJvdW5kIGJ5IHN1Y2ggYSBwb2xpY3kKPiA+IC0tCj4gPiAxLjguMy4xCj4g
PgoKCi0tLQpCZXN0IHdpc2hlcwpZaSBXYW5n


--=====_003_next=====--

--=====_001_next=====--


