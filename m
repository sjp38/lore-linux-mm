Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 223A5C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 01:25:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1705222C9
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 01:25:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1705222C9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=socionext.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 54F4D8E0002; Wed, 13 Feb 2019 20:25:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4FD7B8E0001; Wed, 13 Feb 2019 20:25:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 39FD08E0002; Wed, 13 Feb 2019 20:25:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id EC7D98E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 20:25:27 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id y1so3073961pgo.0
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 17:25:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language
         :content-transfer-encoding:mime-version;
        bh=XrMWRN4XoG/dBYac1AmLAh9Mf/gLlsguCtWHaN81VqU=;
        b=sjG+HJODNC3NRDMTGEegSR7yKh+HDcgbYBXJPrLepUZdBTH0Lx3CYezEE9WWfbqPQu
         Pm5EfnxGuAH4mhHpjrBk8NZvWToLmHgzikhCft1itM1uVwxof137kRGnkN5//JC7ACAE
         P7fZstUKL3jgSD53xKQ+JiB4gEa+VZKEUykZCT/LJNgBYuo8iTjrfmY9B0vdgLvArexD
         RxJ0VrNfhQ+sevkKM6jG9jS0QtL6c1OOp5qnY84CNUEMlmj3YUEf8W9a4dsqow9TKxAd
         24yrrNVlXuN2LUUoA/Y1oDaNPscEbVCfhVkzcUUtFpX2HrFMas1YrpO5f1Jnk0oyG3/Q
         Adeg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yamada.masahiro@socionext.com designates 202.248.49.38 as permitted sender) smtp.mailfrom=yamada.masahiro@socionext.com
X-Gm-Message-State: AHQUAuY2xubppTmxADRlxP41c7pZrupJpbc2dBGvNFB/YKCXfnEK8Z8v
	kvz+OAH0952t8TM0gPj/iq7yJkeGZAsKOdgbXTWzgNIR4tX7/ayzRqshQkZaOahaPQNpctz9THN
	hR1Vxm/2gIeK5bNyO7JtjGOp4irrCor44oNyMRmbkQyFhNRoc8RNcBuavxoZOlc9zyw==
X-Received: by 2002:a63:dc58:: with SMTP id f24mr1199625pgj.248.1550107525227;
        Wed, 13 Feb 2019 17:25:25 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbLRTxLRP2opxazys5QiqzoizoNZh5gKi2RMbvcl7VjeU4ZEDMyhz/jcL57MWQEszcRZNfH
X-Received: by 2002:a63:dc58:: with SMTP id f24mr1199543pgj.248.1550107524061;
        Wed, 13 Feb 2019 17:25:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550107524; cv=none;
        d=google.com; s=arc-20160816;
        b=QJNe7dd363GauNwZ2T8CRC5MSMMvpPyuk2JT/vYZJ/PixAgCkfhm53QbBPibyyWNby
         DmltxLQ/VZltNJGeGRTMU44hBU456L1eZqbvFY0CpMBHy+ias1R+SsTHp6XAfek5FfzW
         eVrIrbtk+nQYHrW5pRhyk9nJ/85+PqnnS9LvygjzPK25mQksLU6IUC5t+1RaYmCXDgkr
         CJp5bbRgS4NJmGaRfUrNd1n3xKZZtcntM6atFT/4KD/MdY+FZ/b0AAs7BKhTXaoGlL07
         2PLSG70G4157WT8fP/VztSQYPy9pLatia8Fhkt8Vj+ve9ikiejhuF1ZIkuC1HNsMNi9E
         U0cg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=XrMWRN4XoG/dBYac1AmLAh9Mf/gLlsguCtWHaN81VqU=;
        b=j3VLXJQVJZdexe+TbNVAOT4JoxHOKn6W6QB6kS4MoZqV1XxUwNwVrMyqoCwwYtEdS/
         EC/qobqrQzOJ3CmMiEtRqvFheMMoNNYgVQRUi5KdrSpukKUkztCTvqk4x0ODuPgeGJ5P
         GTTbCeX2tycVksTyPoiqKXrvL5f1klfhRYh+EdMRQzMDCyx+aiXQydpvVe423ITt01z5
         FNDyJ/c3cHhxuxuZ1Y3RVj0aDhboMKB8R/TeHbqKLf27TwjM9NJLsfwtCHbpqhxAgzsF
         rPGbwFrK33qOXMadIEyn8x4hh4Y7dGxqFcLBGdeJEFvU2jtWKFnjo1y4mAonlFRWwGkY
         5b5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yamada.masahiro@socionext.com designates 202.248.49.38 as permitted sender) smtp.mailfrom=yamada.masahiro@socionext.com
Received: from mx.socionext.com (mx.socionext.com. [202.248.49.38])
        by mx.google.com with ESMTP id a2si890281pgw.264.2019.02.13.17.25.23
        for <linux-mm@kvack.org>;
        Wed, 13 Feb 2019 17:25:24 -0800 (PST)
Received-SPF: pass (google.com: domain of yamada.masahiro@socionext.com designates 202.248.49.38 as permitted sender) client-ip=202.248.49.38;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yamada.masahiro@socionext.com designates 202.248.49.38 as permitted sender) smtp.mailfrom=yamada.masahiro@socionext.com
Received: from unknown (HELO kinkan-ex.css.socionext.com) ([172.31.9.52])
  by mx.socionext.com with ESMTP; 14 Feb 2019 10:25:22 +0900
Received: from mail.mfilter.local (m-filter-1 [10.213.24.61])
	by kinkan-ex.css.socionext.com (Postfix) with ESMTP id 97ADF180101;
	Thu, 14 Feb 2019 10:25:22 +0900 (JST)
Received: from 10.213.24.1 (10.213.24.1) by m-FILTER with ESMTP; Thu, 14 Feb 2019 10:25:22 +0900
Received: from SOC-EX01V.e01.socionext.com (10.213.24.21) by
 SOC-EX03V.e01.socionext.com (10.213.24.23) with Microsoft SMTP Server (TLS)
 id 15.0.995.29; Thu, 14 Feb 2019 10:25:21 +0900
Received: from SOC-EX01V.e01.socionext.com ([10.213.24.21]) by
 SOC-EX01V.e01.socionext.com ([10.213.24.21]) with mapi id 15.00.0995.028;
 Thu, 14 Feb 2019 10:25:21 +0900
From: <yamada.masahiro@socionext.com>
To: <lkp@intel.com>
CC: <kbuild-all@01.org>, <hannes@cmpxchg.org>, <akpm@linux-foundation.org>,
	<linux-mm@kvack.org>
Subject: RE: [mmotm:master 298/371] {standard input}:124: Warning: .ent or
 .aent not in text section
Thread-Topic: [mmotm:master 298/371] {standard input}:124: Warning: .ent or
 .aent not in text section
Thread-Index: AQHUw7F5eyCHaLMtSUSjahPBvpu+1aXegD9g
Date: Thu, 14 Feb 2019 01:25:21 +0000
Message-ID: <60d9adb75b604b78b977e78cb2825bf3@SOC-EX01V.e01.socionext.com>
References: <201902132350.SmzoeQC1%fengguang.wu@intel.com>
In-Reply-To: <201902132350.SmzoeQC1%fengguang.wu@intel.com>
Accept-Language: ja-JP, en-US
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-securitypolicycheck: OK by SHieldMailChecker v2.5.2
x-shieldmailcheckerpolicyversion: POLICY190117
x-originating-ip: [10.213.24.1]
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGkga2J1aWxkIHRlc3Qgcm9ib3QsDQoNCg0KPiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0K
PiBGcm9tOiBrYnVpbGQgdGVzdCByb2JvdCBbbWFpbHRvOmxrcEBpbnRlbC5jb21dDQo+IFNlbnQ6
IFRodXJzZGF5LCBGZWJydWFyeSAxNCwgMjAxOSAxMjozMyBBTQ0KPiBUbzogWWFtYWRhLCBNYXNh
aGlyby8bJEI7M0VEGyhCIBskQj8/OTAbKEIgPHlhbWFkYS5tYXNhaGlyb0Bzb2Npb25leHQuY29t
Pg0KPiBDYzoga2J1aWxkLWFsbEAwMS5vcmc7IEpvaGFubmVzIFdlaW5lciA8aGFubmVzQGNtcHhj
aGcub3JnPjsgQW5kcmV3DQo+IE1vcnRvbiA8YWtwbUBsaW51eC1mb3VuZGF0aW9uLm9yZz47IExp
bnV4IE1lbW9yeSBNYW5hZ2VtZW50IExpc3QNCj4gPGxpbnV4LW1tQGt2YWNrLm9yZz4NCj4gU3Vi
amVjdDogW21tb3RtOm1hc3RlciAyOTgvMzcxXSB7c3RhbmRhcmQgaW5wdXR9OjEyNDogV2Fybmlu
ZzogLmVudA0KPiBvciAuYWVudCBub3QgaW4gdGV4dCBzZWN0aW9uDQo+IA0KPiB0cmVlOiAgIGdp
dDovL2dpdC5jbXB4Y2hnLm9yZy9saW51eC1tbW90bS5naXQgbWFzdGVyDQo+IGhlYWQ6ICAgOWVl
NmE4YzE1OTkwMzdmZWUxM2FiOGExNzgwMDkyYjk2ZGI0NDZkZg0KPiBjb21taXQ6IDI5MDNiNDE4
YWVmNWJhNjgwNjhkM2E5YTZmOGM4ZTZmZjI4ZjY0ODUgWzI5OC8zNzFdDQo+IGtlcm5lbC9jb25m
aWdzOiB1c2UgLmluY2JpbiBkaXJlY3RpdmUgdG8gZW1iZWQgY29uZmlnX2RhdGEuZ3oNCj4gY29u
ZmlnOiBtaXBzLWFsbG1vZGNvbmZpZyAoYXR0YWNoZWQgYXMgLmNvbmZpZykNCj4gY29tcGlsZXI6
IG1pcHMtbGludXgtZ251LWdjYyAoRGViaWFuIDguMi4wLTExKSA4LjIuMA0KPiByZXByb2R1Y2U6
DQo+ICAgICAgICAgd2dldA0KPiBodHRwczovL3Jhdy5naXRodWJ1c2VyY29udGVudC5jb20vaW50
ZWwvbGtwLXRlc3RzL21hc3Rlci9zYmluL21ha2UuY3JvDQo+IHNzIC1PIH4vYmluL21ha2UuY3Jv
c3MNCj4gICAgICAgICBjaG1vZCAreCB+L2Jpbi9tYWtlLmNyb3NzDQo+ICAgICAgICAgZ2l0IGNo
ZWNrb3V0IDI5MDNiNDE4YWVmNWJhNjgwNjhkM2E5YTZmOGM4ZTZmZjI4ZjY0ODUNCj4gICAgICAg
ICAjIHNhdmUgdGhlIGF0dGFjaGVkIC5jb25maWcgdG8gbGludXggYnVpbGQgdHJlZQ0KPiAgICAg
ICAgIEdDQ19WRVJTSU9OPTguMi4wIG1ha2UuY3Jvc3MgQVJDSD1taXBzDQo+IA0KPiBBbGwgd2Fy
bmluZ3MgKG5ldyBvbmVzIHByZWZpeGVkIGJ5ID4+KToNCj4gDQo+ICAgIHtzdGFuZGFyZCBpbnB1
dH06IEFzc2VtYmxlciBtZXNzYWdlczoNCj4gPj4ge3N0YW5kYXJkIGlucHV0fToxMjQ6IFdhcm5p
bmc6IC5lbnQgb3IgLmFlbnQgbm90IGluIHRleHQgc2VjdGlvbg0KPiA+PiB7c3RhbmRhcmQgaW5w
dXR9OjE2NTogV2FybmluZzogLmVuZCBub3QgaW4gdGV4dCBzZWN0aW9uDQoNCg0KVGhhbmtzIGZv
ciBjYXRjaGluZyB0aGlzIQ0KDQoucHVzaHNlY3Rpb24gIGFuZCAucG9wc2VjdGlvbiBzaG91bGQg
YmUgdXNlZCBoZXJlLg0KDQoNCg0KQW5kcmV3LA0KSSB3aWxsIHNlbmQgdjIgc29vbi4NCg0KDQpU
aGFua3MuDQoNCk1hc2FoaXJvIFlhbWFkYQ0KDQo=

