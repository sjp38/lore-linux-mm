Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E05DAC04AB6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 05:31:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66DA527BA4
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 05:31:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=utc.com header.i=@utc.com header.b="TBf1PlIq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66DA527BA4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=utc.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC4EA6B026A; Mon,  3 Jun 2019 01:31:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D75A06B026B; Mon,  3 Jun 2019 01:31:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3D7B6B026C; Mon,  3 Jun 2019 01:31:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id A19186B026A
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 01:31:03 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id d6so13590022ybj.16
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 22:31:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=ZwIoX4ayl6QqescuSllZYGCuNmxTLiYBgyr8cmCVYFo=;
        b=JhcP+qYu791hAh6apBfGt+Ajy6tKovCCgDXkeTOF1qlcET8L+RTM7m0ADi0RSJyFbd
         24HQmFBiXtcPQJqVX6UGMiG38hePJOSido1rs1vV4GxI0HePaNY3CdlWb9BOFYJ5g2gk
         2M2ejDKBB7J9m7KAKZOGV03+ckJ7cnOEl6ym4g1EElT6z93sng9axOyPU/qPK2ecX0AZ
         oq5ada6jX3C6SFecr0xX2Uh4qrt73uKRwjC6jtrCZRW+IHIjlNSAUWixavcjDqxK9Txc
         Hb4t6Tjb4APIxB/MOfKxVOHvTHeZy94gAwcvd8nfNtW1rfJP51eZAOcEI1Ig8NrNMf+Q
         AuAg==
X-Gm-Message-State: APjAAAXDJa3vsa/t03sxXMpH5JgXqesjS8+PmoYEWBB3CMBAutNF18Md
	Wn6dIfL5dfb9KUr1BYxGaJfVe3D+npnHGP9ayyNTHZnr6pEz6IS6n3ItRqJ3uIq7l5RkjfEVnly
	2fLXrdzsKtioTtAEgIySZnAx4EaqNs++Tx9VzTIhyE9iM7sUJOx05z5mv8hwuUMmOKQ==
X-Received: by 2002:a25:8589:: with SMTP id x9mr650029ybk.354.1559539863161;
        Sun, 02 Jun 2019 22:31:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwda9qfuYtTw0OjSemuSeFwdVyEuqM2QcYqzeDJZ+s8FRIHkmjBlVtm1dyPCj68ezr63aXm
X-Received: by 2002:a25:8589:: with SMTP id x9mr649983ybk.354.1559539861567;
        Sun, 02 Jun 2019 22:31:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559539861; cv=none;
        d=google.com; s=arc-20160816;
        b=b2ix8HdelF+KfzxgRGEHn7O+Z0F4W+68bghKeLAHyZCznGJFuP5Nb44zobT3mSuIjQ
         +hrqRBDQkvi+pM0Gtyb2WGD5CkVrk1Ijk6gauZAtpPy5zCeZsqw4naMHGnLH8WBWi+2Q
         EgelgQKL/2ZfCQvQ3N2185jeZrA9m4zm9dVXnC/z3zOvEWSyVR7LymN+RN1alq8pFpB+
         vU8jT5o4ZmK7PkhkwF+uTwf8ljL3xbJWdSaS2j5/Wmh2NDZhkV+yH03eRCdzpz0i1pIO
         X6+MZfECM/tfOI5a82vi1KWLLmgSCAW+lqhxQW56Yz4QOFwyd/b2ZpekSkUarSp4VNYE
         Jn9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=ZwIoX4ayl6QqescuSllZYGCuNmxTLiYBgyr8cmCVYFo=;
        b=r2KdB5+PHKhBaZWMQQH5mqBYBvfUUwcJQV8vRoyB2Kxk0KxF4zibcYly82S73JZjUB
         fK1OSprqh0tXyx2Kx7Q30VZ9sDvpKA4ID28rmhVuoNvA4glSwgOtmsDVH253/2TRogiF
         SjySumUVSq3yC3ehy2hsOhfOlfyQKDJqJvIP/pyLmTzO53Zi9w8oj95wmjjdR8xowliu
         vaLIZ7X9sMPR8VugSjkUvN2nCeKfNc223iU0YlC/ytbcRoB1tsIliIRj/gtTwOqrko2y
         +BZFVBq3tcuruhaIHWkVhIywAUxH97nZ6DApmBYjtMjkGl4+vLx8Ht9PU7t2WT19pzp1
         rRYg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@utc.com header.s=POD040618 header.b=TBf1PlIq;
       spf=pass (google.com: domain of amit.nagal@utc.com designates 67.231.152.184 as permitted sender) smtp.mailfrom=Amit.Nagal@utc.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=utc.com
Received: from mx0a-00105401.pphosted.com (mx0b-00105401.pphosted.com. [67.231.152.184])
        by mx.google.com with ESMTPS id n8si683957ywi.152.2019.06.02.22.31.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Jun 2019 22:31:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of amit.nagal@utc.com designates 67.231.152.184 as permitted sender) client-ip=67.231.152.184;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@utc.com header.s=POD040618 header.b=TBf1PlIq;
       spf=pass (google.com: domain of amit.nagal@utc.com designates 67.231.152.184 as permitted sender) smtp.mailfrom=Amit.Nagal@utc.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=utc.com
Received: from pps.filterd (m0081755.ppops.net [127.0.0.1])
	by mx0b-00105401.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x535QPX0006065;
	Mon, 3 Jun 2019 01:31:01 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=utc.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type :
 content-transfer-encoding : mime-version; s=POD040618;
 bh=ZwIoX4ayl6QqescuSllZYGCuNmxTLiYBgyr8cmCVYFo=;
 b=TBf1PlIqgMrFV6OWwzQ2GIXPgZzmxd7gkaMWH7kgFYG8ClI/ItHKTBMOHzFY9V2DYBE4
 Cn42TxxN/OicqCs0lgQl14tTiSObVxJOLf8aXRD77Oh2uhOWsWswBEEQOe1YNIrabD2J
 BceTZa3Bz7xIS+85+aqbf4bXV3wq00EBgu+pFgGAcvdNvupAYuWq6fJBxls1MHQ/7Qtb
 t1o529JPq8AGOgDAc22gJwS5fxHaeA9B8amFS/yxrvVhnlZlpj6AXPevx/UeL02OW1pk
 A43b4KgzXJoGnxA0ITlg9Ox+uYPaSk6sX8r+LNE8Q545O6FeI+7ANmtuhHPBV0+oNcyT fA== 
Received: from xnwpv38.utc.com ([167.17.239.18])
	by mx0b-00105401.pphosted.com with ESMTP id 2sukvk1g7n-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 03 Jun 2019 01:31:00 -0400
Received: from uusmna1r.utc.com (uusmna1r.utc.com [159.82.219.64])
	by xnwpv38.utc.com (8.16.0.27/8.16.0.27) with ESMTPS id x535Ux9M155466
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 3 Jun 2019 01:30:59 -0400
Received: from UUSALE0W.utcmail.com (UUSALE0W.utcmail.com [10.220.3.13])
	by uusmna1r.utc.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id x535UwT3025877
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=OK);
	Mon, 3 Jun 2019 01:30:58 -0400
Received: from UUSALE1A.utcmail.com (10.220.3.27) by UUSALE0W.utcmail.com
 (10.220.3.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 3 Jun
 2019 01:30:57 -0400
Received: from UUSALE1A.utcmail.com ([10.220.5.27]) by UUSALE1A.utcmail.com
 ([10.220.5.27]) with mapi id 15.00.1473.003; Mon, 3 Jun 2019 01:30:57 -0400
From: "Nagal, Amit               UTC CCS" <Amit.Nagal@utc.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "CHAWLA, RITU              UTC
 CCS" <RITU.CHAWLA@utc.com>,
        "Netter, Christian M       UTC CCS"
	<christian.Netter@fs.UTC.COM>
Subject: RE: [External] Re: linux kernel page allocation failure and tuning of
 page cache
Thread-Topic: [External] Re: linux kernel page allocation failure and tuning
 of page cache
Thread-Index: AdUXwJaEVv2cRvqaQPqGQFhwqLYB3QAWIwGAAGydulA=
Date: Mon, 3 Jun 2019 05:30:57 +0000
Message-ID: <6ec47a90f5b047dabe4028ca90bb74ab@UUSALE1A.utcmail.com>
References: <09c5d10e9d6b4c258b22db23e7a17513@UUSALE1A.utcmail.com>
 <CAKgT0UfoLDxL_8QkF_fuUK-2-6KGFr5y=2_nRZCNc_u+d+LCrg@mail.gmail.com>
In-Reply-To: <CAKgT0UfoLDxL_8QkF_fuUK-2-6KGFr5y=2_nRZCNc_u+d+LCrg@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-ms-exchange-transport-fromentityheader: Hosted
x-originating-ip: [10.220.3.243]
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Proofpoint-Spam-Details: rule=outbound_default_notspam policy=outbound_default score=0
 priorityscore=1501 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0
 spamscore=0 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906030038
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

LS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCkZyb206IEFsZXhhbmRlciBEdXljayBbbWFpbHRv
OmFsZXhhbmRlci5kdXlja0BnbWFpbC5jb21dIA0KU2VudDogU2F0dXJkYXksIEp1bmUgMSwgMjAx
OSAyOjU3IEFNDQpUbzogTmFnYWwsIEFtaXQgVVRDIENDUyA8QW1pdC5OYWdhbEB1dGMuY29tPg0K
Q2M6IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmc7IGxpbnV4LW1tQGt2YWNrLm9yZzsgQ0hB
V0xBLCBSSVRVIFVUQyBDQ1MgPFJJVFUuQ0hBV0xBQHV0Yy5jb20+DQpTdWJqZWN0OiBbRXh0ZXJu
YWxdIFJlOiBsaW51eCBrZXJuZWwgcGFnZSBhbGxvY2F0aW9uIGZhaWx1cmUgYW5kIHR1bmluZyBv
ZiBwYWdlIGNhY2hlDQoNCk9uIEZyaSwgTWF5IDMxLCAyMDE5IGF0IDg6MDcgQU0gTmFnYWwsIEFt
aXQgVVRDIENDUyA8QW1pdC5OYWdhbEB1dGMuY29tPiB3cm90ZToNCj4NCj4gSGkNCj4NCj4gV2Ug
YXJlIHVzaW5nIFJlbmVzYXMgUlovQTEgcHJvY2Vzc29yIGJhc2VkIGN1c3RvbSB0YXJnZXQgYm9h
cmQgLiBsaW51eCBrZXJuZWwgdmVyc2lvbiBpcyA0LjkuMTIzLg0KPg0KPiAxKSB0aGUgcGxhdGZv
cm0gaXMgbG93IG1lbW9yeSBwbGF0Zm9ybSBoYXZpbmcgbWVtb3J5IDY0TUIuDQo+DQo+IDIpICB3
ZSBhcmUgZG9pbmcgYXJvdW5kIDQ1TUIgVENQIGRhdGEgdHJhbnNmZXIgZnJvbSBQQyB0byB0YXJn
ZXQgdXNpbmcgbmV0Y2F0IHV0aWxpdHkgLk9uIFRhcmdldCAsIGEgcHJvY2VzcyByZWNlaXZlcyBk
YXRhIG92ZXIgc29ja2V0IGFuZCB3cml0ZXMgdGhlIGRhdGEgdG8gZmxhc2ggZGlzayAuDQo+DQo+
IDMpIEF0IHRoZSBzdGFydCBvZiBkYXRhIHRyYW5zZmVyICwgd2UgZXhwbGljaXRseSBjbGVhciBs
aW51eCBrZXJuZWwgY2FjaGVkIG1lbW9yeSBieSAgY2FsbGluZyBlY2hvIDMgPiAvcHJvYy9zeXMv
dm0vZHJvcF9jYWNoZXMgLg0KPg0KPiA0KSBkdXJpbmcgVENQIGRhdGEgdHJhbnNmZXIgLCB3ZSBj
b3VsZCBzZWUgZnJlZSAtbSBzaG93aW5nICJmcmVlIiBnZXR0aW5nIGRyb3BwZWQgdG8gYWxtb3N0
IDFNQiBhbmQgbW9zdCBvZiB0aGUgbWVtb3J5IGFwcGVhcmluZyBhcyAiY2FjaGVkIg0KPg0KPiAj
IGZyZWUgLW0NCj4gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB0
b3RhbCAgICAgICAgIHVzZWQgICBmcmVlICAgICBzaGFyZWQgICBidWZmZXJzICAgY2FjaGVkDQo+
IE1lbTogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgNTcgICAgICAgICAgICA1NiAg
ICAgICAgIDEgICAgICAgICAgICAgICAgIDAgICAgICAgICAgICAyICAgICAgICAgICA0Mg0KPiAt
LysgYnVmZmVycy9jYWNoZTogICAgICAgICAgICAgICAgICAgICAgICAgIDEyICAgICAgICA0NQ0K
PiBTd2FwOiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgMCAgICAgICAgICAgICAg
MCAgICAgICAgICAgMA0KPg0KPiA1KSBzb21ldGltZXMgLCB3ZSBvYnNlcnZlZCBrZXJuZWwgbWVt
b3J5IGdldHRpbmcgZXhoYXVzdGVkIGFzIHBhZ2UgYWxsb2NhdGlvbiBmYWlsdXJlIGhhcHBlbnMg
aW4ga2VybmVsICB3aXRoIHRoZSBiYWNrdHJhY2UgaXMgcHJpbnRlZCBiZWxvdyA6DQo+ICMgWyAg
Nzc1Ljk0Nzk0OV0gbmMudHJhZGl0aW9uYWw6IHBhZ2UgYWxsb2NhdGlvbiBmYWlsdXJlOiBvcmRl
cjowLCBtb2RlOjB4MjA4MDAyMChHRlBfQVRPTUlDKQ0KPiBbICA3NzUuOTU2MzYyXSBDUFU6IDAg
UElEOiAxMjg4IENvbW06IG5jLnRyYWRpdGlvbmFsIFRhaW50ZWQ6IEcgICAgICAgICAgIE8gICAg
NC45LjEyMy1waWM2LWczMWExM2RlLWRpcnR5ICMxOQ0KPiBbICA3NzUuOTY2MDg1XSBIYXJkd2Fy
ZSBuYW1lOiBHZW5lcmljIFI3UzcyMTAwIChGbGF0dGVuZWQgRGV2aWNlIFRyZWUpIA0KPiBbICA3
NzUuOTcyNTAxXSBbPGMwMTA5ODI5Pl0gKHVud2luZF9iYWNrdHJhY2UpIGZyb20gWzxjMDEwNzk2
Zj5dIA0KPiAoc2hvd19zdGFjaysweGIvMHhjKSBbICA3NzUuOTgwMTE4XSBbPGMwMTA3OTZmPl0g
KHNob3dfc3RhY2spIGZyb20gDQo+IFs8YzAxNTFkZTM+XSAod2Fybl9hbGxvYysweDg5LzB4YmEp
IFsgIDc3NS45ODczNjFdIFs8YzAxNTFkZTM+XSANCj4gKHdhcm5fYWxsb2MpIGZyb20gWzxjMDE1
MjA0Mz5dIChfX2FsbG9jX3BhZ2VzX25vZGVtYXNrKzB4MWViLzB4NjM0KQ0KPiBbICA3NzUuOTk1
NzkwXSBbPGMwMTUyMDQzPl0gKF9fYWxsb2NfcGFnZXNfbm9kZW1hc2spIGZyb20gWzxjMDE1MjUy
Mz5dIA0KPiAoX19hbGxvY19wYWdlX2ZyYWcrMHgzOS8weGRlKSBbICA3NzYuMDA0Njg1XSBbPGMw
MTUyNTIzPl0gDQo+IChfX2FsbG9jX3BhZ2VfZnJhZykgZnJvbSBbPGMwMzE5MGYxPl0gKF9fbmV0
ZGV2X2FsbG9jX3NrYisweDUxLzB4YjApIFsgIA0KPiA3NzYuMDEzMjE3XSBbPGMwMzE5MGYxPl0g
KF9fbmV0ZGV2X2FsbG9jX3NrYikgZnJvbSBbPGMwMmMxYjZmPl0gDQo+IChzaF9ldGhfcG9sbCsw
eGJmLzB4M2MwKSBbICA3NzYuMDIxMzQyXSBbPGMwMmMxYjZmPl0gKHNoX2V0aF9wb2xsKSANCj4g
ZnJvbSBbPGMwMzFmZDhmPl0gKG5ldF9yeF9hY3Rpb24rMHg3Ny8weDE3MCkgWyAgNzc2LjAyOTA1
MV0gDQo+IFs8YzAzMWZkOGY+XSAobmV0X3J4X2FjdGlvbikgZnJvbSBbPGMwMTEyMzhmPl0gDQo+
IChfX2RvX3NvZnRpcnErMHgxMDcvMHgxNjApIFsgIDc3Ni4wMzY4OTZdIFs8YzAxMTIzOGY+XSAo
X19kb19zb2Z0aXJxKSANCj4gZnJvbSBbPGMwMTEyNTg5Pl0gKGlycV9leGl0KzB4NWQvMHg4MCkg
WyAgNzc2LjA0NDE2NV0gWzxjMDExMjU4OT5dIA0KPiAoaXJxX2V4aXQpIGZyb20gWzxjMDEyZjRk
Yj5dIChfX2hhbmRsZV9kb21haW5faXJxKzB4NTcvMHg4YykgWyAgNzc2LjA1MjAwN10gWzxjMDEy
ZjRkYj5dIChfX2hhbmRsZV9kb21haW5faXJxKSBmcm9tIFs8YzAxMDEyZTE+XSAoZ2ljX2hhbmRs
ZV9pcnErMHgzMS8weDQ4KSBbICA3NzYuMDYwMzYyXSBbPGMwMTAxMmUxPl0gKGdpY19oYW5kbGVf
aXJxKSBmcm9tIFs8YzAxMDgwMjU+XSAoX19pcnFfc3ZjKzB4NjUvMHhhYykgWyAgNzc2LjA2Nzgz
NV0gRXhjZXB0aW9uIHN0YWNrKDB4YzFjYWZkNzAgdG8gMHhjMWNhZmRiOCkNCj4gWyAgNzc2LjA3
Mjg3Nl0gZmQ2MDogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgMDAwMjc1MWMg
YzFkZWM2YTAgMDAwMDAwMGMgNTIxYzNiZTUNCj4gWyAgNzc2LjA4MTA0Ml0gZmQ4MDogNTZmZWIw
OGUgZjY0ODIzYTYgZmZiMzVmN2IgZmVhYjUxM2QgZjljYjA2NDMgDQo+IDAwMDAwNTZjIGMxY2Fm
ZjEwIGZmZmZlMDAwIFsgIDc3Ni4wODkyMDRdIGZkYTA6IGIxZjQ5MTYwIGMxY2FmZGM0IA0KPiBj
MTgwYzY3NyBjMDIzNGFjZSAyMDBlMDAzMyBmZmZmZmZmZiBbICA3NzYuMDk1ODE2XSBbPGMwMTA4
MDI1Pl0gDQo+IChfX2lycV9zdmMpIGZyb20gWzxjMDIzNGFjZT5dIChfX2NvcHlfdG9fdXNlcl9z
dGQrMHg3ZS8weDQzMCkgWyAgDQo+IDc3Ni4xMDM3OTZdIFs8YzAyMzRhY2U+XSAoX19jb3B5X3Rv
X3VzZXJfc3RkKSBmcm9tIFs8YzAyNDE3MTU+XSANCj4gKGNvcHlfcGFnZV90b19pdGVyKzB4MTA1
LzB4MjUwKSBbICA3NzYuMTEyNTAzXSBbPGMwMjQxNzE1Pl0gDQo+IChjb3B5X3BhZ2VfdG9faXRl
cikgZnJvbSBbPGMwMzE5YWViPl0gDQo+IChza2JfY29weV9kYXRhZ3JhbV9pdGVyKzB4YTMvMHgx
MDgpDQo+IFsgIDc3Ni4xMjE0NjldIFs8YzAzMTlhZWI+XSAoc2tiX2NvcHlfZGF0YWdyYW1faXRl
cikgZnJvbSBbPGMwMzQ0M2E3Pl0gDQo+ICh0Y3BfcmVjdm1zZysweDNhYi8weDVmNCkgWyAgNzc2
LjEzMDA0NV0gWzxjMDM0NDNhNz5dICh0Y3BfcmVjdm1zZykgDQo+IGZyb20gWzxjMDM1ZTI0OT5d
IChpbmV0X3JlY3Ztc2crMHgyMS8weDJjKSBbICA3NzYuMTM3NTc2XSBbPGMwMzVlMjQ5Pl0gDQo+
IChpbmV0X3JlY3Ztc2cpIGZyb20gWzxjMDMxMDA5Zj5dIChzb2NrX3JlYWRfaXRlcisweDUxLzB4
NmUpIFsgIA0KPiA3NzYuMTQ1Mzg0XSBbPGMwMzEwMDlmPl0gKHNvY2tfcmVhZF9pdGVyKSBmcm9t
IFs8YzAxNzc5NWQ+XSANCj4gKF9fdmZzX3JlYWQrMHg5Ny8weGIwKSBbICA3NzYuMTUyOTY3XSBb
PGMwMTc3OTVkPl0gKF9fdmZzX3JlYWQpIGZyb20gDQo+IFs8YzAxNzgxZDk+XSAodmZzX3JlYWQr
MHg1MS8weGIwKSBbICA3NzYuMTU5OTgzXSBbPGMwMTc4MWQ5Pl0gDQo+ICh2ZnNfcmVhZCkgZnJv
bSBbPGMwMTc4YWFiPl0gKFN5U19yZWFkKzB4MjcvMHg1MikgWyAgNzc2LjE2NjgzN10gDQo+IFs8
YzAxNzhhYWI+XSAoU3lTX3JlYWQpIGZyb20gWzxjMDEwNTI2MT5dIChyZXRfZmFzdF9zeXNjYWxs
KzB4MS8weDU0KQ0KDQo+U28gaXQgbG9va3MgbGlrZSB5b3UgYXJlIGludGVycnVwdGluZyB0aGUg
cHJvY2VzcyB0aGF0IGlzIGRyYWluaW5nIHRoZSBzb2NrZXQgdG8gc2VydmljZSB0aGUgaW50ZXJy
dXB0IHRoYXQgaXMgZmlsbGluZyBpdC4gSSBhbSBjdXJpb3VzIHdoYXQgeW91ciB0Y3Bfcm1lbSB2
YWx1ZSBpcy4gSWYgdGhpcyBpcyBvY2N1cnJpbmcgb2Z0ZW4gdGhlbiB5b3Ugd2lsbCBsaWtlbHkg
YnVpbGQgdXAgYSA+YmFja2xvZyBvZiBwYWNrZXRzIGluIHRoZSByZWNlaXZlIGJ1ZmZlciBmb3Ig
dGhlIHNvY2tldCBhbmQgdGhhdCBtYXkgYmUgd2hlcmUgYWxsIHlvdXIgbWVtb3J5IGlzIGdvaW5n
Lg0KDQpUaGFua3MgZm9yIHRoZSByZXBseSAuDQojIGNhdCAvcHJvYy9zeXMvbmV0L2lwdjQvdGNw
X3JtZW0NCjQwOTYgICAgODczODAgICA0NTQ2ODgNCg0KdGhlIG1heGltdW0gdmFsdWUgaXMgbGVz
cyB0aGFuIDFNQiBoZXJlIC4gIHdoaWNoIG1lYW5zIHRoYXQgc29ja2V0IGJ1ZmZlciBpcyBub3Qg
Y29uc3VtaW5nIGFsbCB0aGUgbWVtb3J5IGhlcmUgcmlnaHQgPw0KIA0KPiBbICA3NzYuMTc0MzA4
XSBNZW0tSW5mbzoNCj4gWyAgNzc2LjE3NjY1MF0gYWN0aXZlX2Fub246MjAzNyBpbmFjdGl2ZV9h
bm9uOjIzIGlzb2xhdGVkX2Fub246MCBbICANCj4gNzc2LjE3NjY1MF0gIGFjdGl2ZV9maWxlOjI2
MzYgaW5hY3RpdmVfZmlsZTo3MzkxIGlzb2xhdGVkX2ZpbGU6MzIgWyAgDQo+IDc3Ni4xNzY2NTBd
ICB1bmV2aWN0YWJsZTowIGRpcnR5OjEzNjYgd3JpdGViYWNrOjEyODEgdW5zdGFibGU6MCBbICAN
Cj4gNzc2LjE3NjY1MF0gIHNsYWJfcmVjbGFpbWFibGU6NzE5IHNsYWJfdW5yZWNsYWltYWJsZTo3
MjQgWyAgDQo+IDc3Ni4xNzY2NTBdICBtYXBwZWQ6MTk5MCBzaG1lbToyNiBwYWdldGFibGVzOjE1
OSBib3VuY2U6MCBbICANCj4gNzc2LjE3NjY1MF0gIGZyZWU6MzczIGZyZWVfcGNwOjYgZnJlZV9j
bWE6MCBbICA3NzYuMjA5MDYyXSBOb2RlIDAgDQo+IGFjdGl2ZV9hbm9uOjgxNDhrQiBpbmFjdGl2
ZV9hbm9uOjkya0IgYWN0aXZlX2ZpbGU6MTA1NDRrQiANCj4gaW5hY3RpdmVfZmlsZToyOTU2NGtC
IHVuZXZpY3RhYmxlOjBrQiBpc29sYXRlZChhbm9uKTowa0IgDQo+IGlzb2xhdGVkKGZpbGUpOjEy
OGtCIG1hcHBlZDo3OTYwa0IgZGlydHk6NTQ2NGtCIHdyaXRlYmFjazo1MTI0a0IgDQo+IHNobWVt
OjEwNGtCIHdyaXRlYmFja190bXA6MGtCIHVuc3RhYmxlOjBrQiBwYWdlc19zY2FubmVkOjAgDQo+
IGFsbF91bnJlY2xhaW1hYmxlPyBubyBbICA3NzYuMjMzNjAyXSBOb3JtYWwgZnJlZToxNDkya0Ig
bWluOjk2NGtCIA0KPiBsb3c6MTIwNGtCIGhpZ2g6MTQ0NGtCIGFjdGl2ZV9hbm9uOjgxNDhrQiBp
bmFjdGl2ZV9hbm9uOjkya0IgDQo+IGFjdGl2ZV9maWxlOjEwNTQ0a0IgaW5hY3RpdmVfZmlsZToy
OTU2NGtCIHVuZXZpY3RhYmxlOjBrQiANCj4gd3JpdGVwZW5kaW5nOjEwNTg4a0IgcHJlc2VudDo2
NTUzNmtCIG1hbmFnZWQ6NTkzMDRrQiBtbG9ja2VkOjBrQiANCj4gc2xhYl9yZWNsYWltYWJsZToy
ODc2a0Igc2xhYl91bnJlY2xhaW1hYmxlOjI4OTZrQiBrZXJuZWxfc3RhY2s6MTE1MmtCIA0KPiBw
YWdldGFibGVzOjYzNmtCIGJvdW5jZTowa0IgZnJlZV9wY3A6MjRrQiBsb2NhbF9wY3A6MjRrQiBm
cmVlX2NtYTowa0IgDQo+IFsgIDc3Ni4yNjU0MDZdIGxvd21lbV9yZXNlcnZlW106IDAgMCBbICA3
NzYuMjY4NzYxXSBOb3JtYWw6IDcqNGtCIChIKSANCj4gNSo4a0IgKEgpIDcqMTZrQiAoSCkgNSoz
MmtCIChIKSA2KjY0a0IgKEgpIDIqMTI4a0IgKEgpIDIqMjU2a0IgKEgpIA0KPiAwKjUxMmtCIDAq
MTAyNGtCIDAqMjA0OGtCIDAqNDA5NmtCID0gMTQ5MmtCDQo+IDEwMDcxIHRvdGFsIHBhZ2VjYWNo
ZSBwYWdlcw0KPiBbICA3NzYuMjg0MTI0XSAwIHBhZ2VzIGluIHN3YXAgY2FjaGUNCj4gWyAgNzc2
LjI4NzQ0Nl0gU3dhcCBjYWNoZSBzdGF0czogYWRkIDAsIGRlbGV0ZSAwLCBmaW5kIDAvMCBbICAN
Cj4gNzc2LjI5MjY0NV0gRnJlZSBzd2FwICA9IDBrQiBbICA3NzYuMjk1NTMyXSBUb3RhbCBzd2Fw
ID0gMGtCIFsgIA0KPiA3NzYuMjk4NDIxXSAxNjM4NCBwYWdlcyBSQU0gWyAgNzc2LjMwMTIyNF0g
MCBwYWdlcyBIaWdoTWVtL01vdmFibGVPbmx5IA0KPiBbICA3NzYuMzA1MDUyXSAxNTU4IHBhZ2Vz
IHJlc2VydmVkDQo+DQo+IDYpIHdlIGhhdmUgY2VydGFpbiBxdWVzdGlvbnMgYXMgYmVsb3cgOg0K
PiBhKSBob3cgdGhlIGtlcm5lbCBtZW1vcnkgZ290IGV4aGF1c3RlZCA/IGF0IHRoZSB0aW1lIG9m
IGxvdyBtZW1vcnkgY29uZGl0aW9ucyBpbiBrZXJuZWwgLCBhcmUgdGhlIGtlcm5lbCBwYWdlIGZs
dXNoZXIgdGhyZWFkcyAsIHdoaWNoIHNob3VsZCBoYXZlIHdyaXR0ZW4gZGlydHkgcGFnZXMgZnJv
bSBwYWdlIGNhY2hlIHRvIGZsYXNoIGRpc2sgLCBub3QgPiA+ZXhlY3V0aW5nIGF0IHJpZ2h0IHRp
bWUgPyBpcyB0aGUga2VybmVsIHBhZ2UgcmVjbGFpbSBtZWNoYW5pc20gbm90IGV4ZWN1dGluZyBh
dCByaWdodCB0aW1lID8NCg0KPkkgc3VzcGVjdCB0aGUgcGFnZXMgYXJlIGxpa2VseSBzdHVjayBp
biBhIHN0YXRlIG9mIGJ1ZmZlcmluZy4gSW4gdGhlIGNhc2Ugb2Ygc29ja2V0cyB0aGUgcGFja2V0
cyB3aWxsIGdldCBxdWV1ZWQgdXAgdW50aWwgZWl0aGVyIHRoZXkgY2FuIGJlIHNlcnZpY2VkIG9y
IHRoZSBtYXhpbXVtIHNpemUgb2YgdGhlIHJlY2VpdmUgYnVmZmVyIGFzIGJlZW4gZXhjZWVkZWQg
PmFuZCB0aGV5IGFyZSBkcm9wcGVkLg0KDQpNeSBjb25jZXJuIGhlcmUgaXMgdGhhdCB3aHkgdGhl
IHJlY2xhaW0gcHJvY2VkdXJlIGhhcyBub3QgdHJpZ2dlcmVkID8NCg0KPiBiKSBhcmUgdGhlcmUg
YW55IHBhcmFtZXRlcnMgYXZhaWxhYmxlIHdpdGhpbiB0aGUgbGludXggbWVtb3J5IHN1YnN5c3Rl
bSB3aXRoIHdoaWNoIHRoZSByZWNsYWltIHByb2NlZHVyZSBjYW4gYmUgbW9uaXRvcmVkIGFuZCAg
ZmluZSB0dW5lZCA/DQoNCj5JIGRvbid0IHRoaW5rIGZyZWVpbmcgdXAgbW9yZSBtZW1vcnkgd2ls
bCBzb2x2ZSB0aGUgaXNzdWUuIEkgcmVhbGx5IHRoaW5rIHlvdSBwcm9iYWJseSBzaG91bGQgbG9v
ayBhdCB0dW5pbmcgdGhlIG5ldHdvcmsgc2V0dGluZ3MuIEkgc3VzcGVjdCB0aGUgc29ja2V0IGl0
c2VsZiBpcyBsaWtlbHkgdGhlIHRoaW5nIGhvbGRpbmcgYWxsIG9mIHRoZSBtZW1vcnkuDQoNCj4g
YykgY2FuICBzb21lIGFtb3VudCBvZiBmcmVlIG1lbW9yeSBiZSByZXNlcnZlZCBzbyB0aGF0IGxp
bnV4IGtlcm5lbCBkb2VzIG5vdCBjYWNoZXMgaXQgYW5kIGtlcm5lbCBjYW4gdXNlIGl0IGZvciBp
dHMgb3RoZXIgcmVxdWlyZWQgcGFnZSBhbGxvY2F0aW9uICggcGFydGljdWxhcmx5IGdmcF9hdG9t
aWMgKSBhcyBuZWVkZWQgYWJvdmUgb24gYmVoYWxmIG9mIG5ldGNhdCBuYyBwcm9jZXNzID8gY2Fu
IHNvbWUgdHVuaW5nIGJlIGRvbmUgaW4gbGludXggbWVtb3J5IHN1YnN5c3RlbSBlZyBieSB1c2lu
ZyAvcHJvYy9zeXMvdm0vbWluX2ZyZWVfa2J5dGVzICB0byBhY2hpZXZlIHRoaXMgb2JqZWN0aXZl
IC4NCg0KPldpdGhpbiB0aGUga2VybmVsIHdlIGFscmVhZHkgaGF2ZSBzb21lIGVtZXJnZW5jeSBy
ZXNlcnZlZCB0aGF0IGdldCBkaXBwZWQgaW50byBpZiB0aGUgUEZfTUVNQUxMT0MgZmxhZyBpcyBz
ZXQuIEhvd2V2ZXIgdGhhdCBpcyB1c3VhbGx5IHJlc2VydmVkIGZvciB0aGUgY2FzZXMgd2hlcmUg
eW91IGFyZSBib290aW5nIG9mZiBvZiBzb21ldGhpbmcgbGlrZSA+aXNjc2kgb3IgTlZNZSBvdmVy
IFRDUC4NCg0KPiBkKSBjYW4gd2UgYmUgcHJvdmlkZWQgd2l0aCBmdXJ0aGVyIGNsdWVzIG9uIGhv
dyB0byBkZWJ1ZyB0aGlzIGlzc3VlIGZ1cnRoZXIgZm9yIG91dCBvZiBtZW1vcnkgY29uZGl0aW9u
IGluIGtlcm5lbCAgPw0KDQo+TXkgYWR2aWNlIHdvdWxkIGJlIGxvb2sgYXQgdHVuaW5nIHlvdXIg
VENQIHNvY2tldCB2YWx1ZXMgaW4gc3lzY3RsLiBJIHN1c3BlY3QgeW91IGFyZSBsaWtlbHkgdXNp
bmcgYSBsYXJnZXIgd2luZG93IHRoZW4geW91ciBzeXN0ZW0gY2FuIGN1cnJlbnRseSBoYW5kbGUg
Z2l2ZW4gdGhlIG1lbW9yeSBjb25zdHJhaW50cyBhbmQgdGhhdCB3aGF0IHlvdSBhcmUgPnNlZWlu
ZyBpcyB0aGF0IGFsbCB0aGUgbWVtb3J5IGlzIGJlaW5nIGNvbnN1bWVkIGJ5IGJ1ZmZlcmluZyBm
b3IgdGhlIFRDUCBzb2NrZXQuDQoNCkFueSBzdWdnZXN0aW9ucyBoZXJlIHdoYXQgYWxsIFRDUCBz
b2NrZXQgdmFsdWVzIEkgc2hvdWxkIGxvb2sgaW50byBhbmQgd2hhdCB2YWx1ZXMgdG8gdHVuZSB0
byAuICANCg0KDQoNCg==

