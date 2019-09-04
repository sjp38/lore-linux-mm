Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 527E8C3A5A9
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 18:25:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E4CE20882
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 18:25:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E4CE20882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CFBE36B0003; Wed,  4 Sep 2019 14:25:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CAC9B6B0006; Wed,  4 Sep 2019 14:25:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B9B1A6B0007; Wed,  4 Sep 2019 14:25:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0008.hostedemail.com [216.40.44.8])
	by kanga.kvack.org (Postfix) with ESMTP id 9911C6B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 14:25:28 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 2F219824CA3F
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 18:25:28 +0000 (UTC)
X-FDA: 75898065936.12.frame53_4c9c2f6536608
X-HE-Tag: frame53_4c9c2f6536608
X-Filterd-Recvd-Size: 4858
Received: from mga06.intel.com (mga06.intel.com [134.134.136.31])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 18:25:26 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Sep 2019 11:25:23 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,467,1559545200"; 
   d="scan'208";a="177033204"
Received: from fmsmsx105.amr.corp.intel.com ([10.18.124.203])
  by orsmga008.jf.intel.com with ESMTP; 04 Sep 2019 11:25:22 -0700
Received: from crsmsx152.amr.corp.intel.com (172.18.7.35) by
 FMSMSX105.amr.corp.intel.com (10.18.124.203) with Microsoft SMTP Server (TLS)
 id 14.3.439.0; Wed, 4 Sep 2019 11:25:22 -0700
Received: from crsmsx101.amr.corp.intel.com ([169.254.1.249]) by
 CRSMSX152.amr.corp.intel.com ([169.254.5.223]) with mapi id 14.03.0439.000;
 Wed, 4 Sep 2019 12:25:20 -0600
From: "Weiny, Ira" <ira.weiny@intel.com>
To: Vlastimil Babka <vbabka@suse.cz>, zhong jiang <zhongjiang@huawei.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@kernel.org"
	<mhocko@kernel.org>
CC: "anshuman.khandual@arm.com" <anshuman.khandual@arm.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, Aneesh Kumar K.V
	<aneesh.kumar@linux.vnet.ibm.com>
Subject: RE: [PATCH] mm: Unsigned 'nr_pages' always larger than zero
Thread-Topic: [PATCH] mm: Unsigned 'nr_pages' always larger than zero
Thread-Index: AQHVYwudPt5si0bTnEuchA1jrW3MqKcbxUIAgAAQYaA=
Date: Wed, 4 Sep 2019 18:25:19 +0000
Message-ID: <2807E5FD2F6FDA4886F6618EAC48510E898E9559@CRSMSX101.amr.corp.intel.com>
References: <1567592763-25282-1-git-send-email-zhongjiang@huawei.com>
 <5505fa16-117e-8890-0f48-38555a61a036@suse.cz>
In-Reply-To: <5505fa16-117e-8890-0f48-38555a61a036@suse.cz>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiODllZjE3YTUtMmZhZS00ODU1LWFkODUtNzhmZTg2Njk3Mjc0IiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoiRWZONTQ1TzdDbWVJS0VybXRybzRSc0tVMjBWandWN1dkbnFKWFk0XC9tZytkTEtsNHdubkFrSHc4RUZWREg3dGcifQ==
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.2.0.6
dlp-reaction: no-action
x-originating-ip: [172.18.205.10]
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

PiBPbiA5LzQvMTkgMTI6MjYgUE0sIHpob25nIGppYW5nIHdyb3RlOg0KPiA+IFdpdGggdGhlIGhl
bHAgb2YgdW5zaWduZWRfbGVzc2VyX3RoYW5femVyby5jb2NjaS4gVW5zaWduZWQgJ25yX3BhZ2Vz
IicNCj4gPiBjb21wYXJlIHdpdGggemVyby4gQW5kIF9fZ2V0X3VzZXJfcGFnZXNfbG9ja2VkIHdp
bGwgcmV0dXJuIGFuIGxvbmcNCj4gdmFsdWUuDQo+ID4gSGVuY2UsIENvbnZlcnQgdGhlIGxvbmcg
dG8gY29tcGFyZSB3aXRoIHplcm8gaXMgZmVhc2libGUuDQo+IA0KPiBJdCB3b3VsZCBiZSBuaWNl
ciBpZiB0aGUgcGFyYW1ldGVyIG5yX3BhZ2VzIHdhcyBsb25nIGFnYWluIGluc3RlYWQgb2YNCj4g
dW5zaWduZWQgbG9uZyAobm90ZSB0aGVyZSBhcmUgdHdvIHZhcmlhbnRzIG9mIHRoZSBmdW5jdGlv
biwgc28gYm90aCBzaG91bGQgYmUNCj4gY2hhbmdlZCkuDQoNCldoeT8gIFdoYXQgZG9lcyBpdCBt
ZWFuIGZvciBucl9wYWdlcyB0byBiZSBuZWdhdGl2ZT8gIFRoZSBjaGVjayBiZWxvdyBzZWVtcyB2
YWxpZC4gIFVuc2lnbmVkIGNhbiBiZSAwIHNvIHRoZSBjaGVjayBjYW4gZmFpbC4gIElPVyBDaGVj
a2luZyB1bnNpZ25lZCA+IDAgc2VlbXMgb2suDQoNCldoYXQgYW0gSSBtaXNzaW5nPw0KDQpJcmEN
Cg0KPiANCj4gPiBTaWduZWQtb2ZmLWJ5OiB6aG9uZyBqaWFuZyA8emhvbmdqaWFuZ0BodWF3ZWku
Y29tPg0KPiANCj4gRml4ZXM6IDkzMmY0YTYzMGE2OSAoIm1tL2d1cDogcmVwbGFjZSBnZXRfdXNl
cl9wYWdlc19sb25ndGVybSgpIHdpdGgNCj4gRk9MTF9MT05HVEVSTSIpDQo+IA0KPiAod2hpY2gg
Y2hhbmdlZCBsb25nIHRvIHVuc2lnbmVkIGxvbmcpDQo+IA0KPiBBRkFJQ1MuLi4gc3RhYmxlIHNo
b3VsZG4ndCBiZSBuZWVkZWQgYXMgdGhlIG9ubHkgInJpc2siIGlzIHRoYXQgd2UgZ290bw0KPiBj
aGVja19hZ2FpbiBldmVuIHdoZW4gd2UgZmFpbCwgd2hpY2ggc2hvdWxkIGJlIGhhcm1sZXNzLg0K
PiANCj4gVmxhc3RpbWlsDQo+IA0KPiA+IC0tLQ0KPiA+ICBtbS9ndXAuYyB8IDIgKy0NCj4gPiAg
MSBmaWxlIGNoYW5nZWQsIDEgaW5zZXJ0aW9uKCspLCAxIGRlbGV0aW9uKC0pDQo+ID4NCj4gPiBk
aWZmIC0tZ2l0IGEvbW0vZ3VwLmMgYi9tbS9ndXAuYw0KPiA+IGluZGV4IDIzYTlmOWMuLjk1NmQ1
YTEgMTAwNjQ0DQo+ID4gLS0tIGEvbW0vZ3VwLmMNCj4gPiArKysgYi9tbS9ndXAuYw0KPiA+IEBA
IC0xNTA4LDcgKzE1MDgsNyBAQCBzdGF0aWMgbG9uZyBjaGVja19hbmRfbWlncmF0ZV9jbWFfcGFn
ZXMoc3RydWN0DQo+IHRhc2tfc3RydWN0ICp0c2ssDQo+ID4gIAkJCQkJCSAgIHBhZ2VzLCB2bWFz
LCBOVUxMLA0KPiA+ICAJCQkJCQkgICBndXBfZmxhZ3MpOw0KPiA+DQo+ID4gLQkJaWYgKChucl9w
YWdlcyA+IDApICYmIG1pZ3JhdGVfYWxsb3cpIHsNCj4gPiArCQlpZiAoKChsb25nKW5yX3BhZ2Vz
ID4gMCkgJiYgbWlncmF0ZV9hbGxvdykgew0KPiA+ICAJCQlkcmFpbl9hbGxvdyA9IHRydWU7DQo+
ID4gIAkJCWdvdG8gY2hlY2tfYWdhaW47DQo+ID4gIAkJfQ0KPiA+DQoNCg==

