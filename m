Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F497C43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 02:40:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F0B9206BA
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 02:40:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F0B9206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D9C126B0007; Thu, 25 Apr 2019 22:40:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D4B156B0008; Thu, 25 Apr 2019 22:40:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BEBF16B000C; Thu, 25 Apr 2019 22:40:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7E0216B0007
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 22:40:30 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id z7so1068094pgc.1
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 19:40:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=ZBFOlGBbaWXnbJMkXRfC/fyunU8yiXzqLYTvJHh/tPw=;
        b=KwhFFJy6Ld9fQejKhY27SL2/CVeBG0Mman+LYhDnFZ3PfSfIhcAAsXg5kWcd3exGF9
         /iSWHdRyF/lFo7mMKJOrSqJ5Fcl2il847VQ7Uxlx5ZaXs95gIC19W92+iw45LHHBvdMc
         hfoHyHM2njH1kL/xxIapS1ZygLjLw38KzhlfvA5EPQ8Q2RxsAPSTEzg1EuPZJ8J9TAiY
         2L46LmCjpY48gdDX5RIT5n5Y4OcZ2LmRUM70tqG1Ign8F7Adb5VH44JKHfCKnqnovbfd
         jGP5NpnVr5rlVhdEXumhLF0BIl3UwVxneSuS/dfwh80FF8tDPQWCRR+eDAyPhQ13HBBS
         9LxA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fan.du@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=fan.du@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU1CSWBxHKfrZpyqS4FGuWoj5Mv2/wEm6K+HIIaJyzztDOfbIOz
	vX/xeMl+RORqKy4HRWrE8s6TH9KtkqVu3V1rDGSs8x0cYrVE6n47VqGB7INnx5zSVeXExey57Bm
	wTzgYbVf3SYEWfSK8W0p9E7pP3rqu7HqdtuNc3sKvWXOUPo5Pe3aoBkfP/xOyHd+45A==
X-Received: by 2002:a63:5b4b:: with SMTP id l11mr39387752pgm.95.1556246430150;
        Thu, 25 Apr 2019 19:40:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxA8SolgHwCtmU7pwgsUkywA5GJk5Xuk3ZTMthEXieTqOX7YNc9ZPz2x1q+l7dOg8qCEKuw
X-Received: by 2002:a63:5b4b:: with SMTP id l11mr39387694pgm.95.1556246429201;
        Thu, 25 Apr 2019 19:40:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556246429; cv=none;
        d=google.com; s=arc-20160816;
        b=N0LdXdcN9juYw283QhEtXl2F1O0oKep0C5Eql5/Lh7NNyxu60RI5CtPvdM1GNiofmM
         o2ts62cI6Zp66PQX8+xUaw/LhLMIifnzHbNH3r3zBVE9opBs7ExhFWKdMMXrSVZuLC3q
         ntcChC0obpE8Ap38X+Ke5kah2ih2BXAUcwuhHAl0krYsysHZ8LjK2DDEN2p8yKY+fdDM
         Y/HMDMe582HfMJbCDV3cQNNYX8yyTnBYo15vrBwfxk94tVrPDIVdC4UVLX9Yfxgck3gw
         UphXBlweBHtnPe5fxhbzPFOGlEJcnO4/Rn6rYIVEktC9npTaTjMOlFkCmFh20++MqR8S
         nJTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=ZBFOlGBbaWXnbJMkXRfC/fyunU8yiXzqLYTvJHh/tPw=;
        b=Iyv7NIcoPR/2HWONPrlzVZ9tCN4BkLzt0eCGsS9A+gQVGXe4We3mEfA0hygyL/oN+m
         BrDhMvlsoCZwA2hfuE71ONknPnVB0wRy2TD1yYn7b3fg79jGQ9fjhRcQowxxAspjuGUN
         GrYY2yH9Fth8BPDt14naJ9P/AYkjQyMoBROTQrnJhvI2T50ZGB+HIKJGqA51cEX/fyfQ
         2Jcdjq0B5m5JpJijUUPqMltKefDMXwC56zhPOhAdHC5Lv5QufncxU4EdcIYkcXbjQbTK
         +M57rV+stxBn4hPNF8c+XmudY7d6T//jCrEtTOcQVs/t67bs6rCKkUOtnBL2hCnwUDBi
         bUUA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fan.du@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=fan.du@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 192si11591075pgc.200.2019.04.25.19.40.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 19:40:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of fan.du@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fan.du@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=fan.du@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Apr 2019 19:40:28 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,395,1549958400"; 
   d="scan'208";a="164977643"
Received: from fmsmsx105.amr.corp.intel.com ([10.18.124.203])
  by fmsmga002.fm.intel.com with ESMTP; 25 Apr 2019 19:40:28 -0700
Received: from fmsmsx125.amr.corp.intel.com (10.18.125.40) by
 FMSMSX105.amr.corp.intel.com (10.18.124.203) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Thu, 25 Apr 2019 19:40:28 -0700
Received: from shsmsx108.ccr.corp.intel.com (10.239.4.97) by
 FMSMSX125.amr.corp.intel.com (10.18.125.40) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Thu, 25 Apr 2019 19:40:12 -0700
Received: from shsmsx104.ccr.corp.intel.com ([169.254.5.92]) by
 SHSMSX108.ccr.corp.intel.com ([169.254.8.147]) with mapi id 14.03.0415.000;
 Fri, 26 Apr 2019 10:40:05 +0800
From: "Du, Fan" <fan.du@intel.com>
To: "Williams, Dan J" <dan.j.williams@intel.com>
CC: Michal Hocko <mhocko@kernel.org>, "akpm@linux-foundation.org"
	<akpm@linux-foundation.org>, "Wu, Fengguang" <fengguang.wu@intel.com>,
	"Hansen, Dave" <dave.hansen@intel.com>, "xishi.qiuxishi@alibaba-inc.com"
	<xishi.qiuxishi@alibaba-inc.com>, "Huang, Ying" <ying.huang@intel.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "Du, Fan" <fan.du@intel.com>
Subject: RE: [RFC PATCH 0/5] New fallback workflow for heterogeneous memory
 system
Thread-Topic: [RFC PATCH 0/5] New fallback workflow for heterogeneous memory
 system
Thread-Index: AQHU+wguqC0/BskpLkaHU1TotE//DKZL5oWAgACMEvD//4lJgIAAhy/Q///77QCAATS/QA==
Date: Fri, 26 Apr 2019 02:40:05 +0000
Message-ID: <5A90DA2E42F8AE43BC4A093BF067884825786402@SHSMSX104.ccr.corp.intel.com>
References: <1556155295-77723-1-git-send-email-fan.du@intel.com>
 <20190425063727.GJ12751@dhcp22.suse.cz>
 <5A90DA2E42F8AE43BC4A093BF067884825785EE8@SHSMSX104.ccr.corp.intel.com>
 <20190425075353.GO12751@dhcp22.suse.cz>
 <5A90DA2E42F8AE43BC4A093BF067884825785F6E@SHSMSX104.ccr.corp.intel.com>
 <CAPcyv4jpiPg+dbFg0BrNSqGjxKA6CQdBiLp5L=nrLWzN7mD8Kw@mail.gmail.com>
In-Reply-To: <CAPcyv4jpiPg+dbFg0BrNSqGjxKA6CQdBiLp5L=nrLWzN7mD8Kw@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiNjMxN2FhNjUtOTYzZS00NDQ3LThlMTAtZmEzMTM2MGE3Mzg0IiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoicHBmT3ZYRnQrcXBndmdqMTN3ME5yc3dONzJyUE9SMzdBaGhxN1wveGQwajU0TjVnaU9JYVJYNUh4MVBrUERtd3kifQ==
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.0.600.7
dlp-reaction: no-action
x-originating-ip: [10.239.127.40]
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

DQoNCj4tLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPkZyb206IERhbiBXaWxsaWFtcyBbbWFp
bHRvOmRhbi5qLndpbGxpYW1zQGludGVsLmNvbV0NCj5TZW50OiBUaHVyc2RheSwgQXByaWwgMjUs
IDIwMTkgMTE6NDMgUE0NCj5UbzogRHUsIEZhbiA8ZmFuLmR1QGludGVsLmNvbT4NCj5DYzogTWlj
aGFsIEhvY2tvIDxtaG9ja29Aa2VybmVsLm9yZz47IGFrcG1AbGludXgtZm91bmRhdGlvbi5vcmc7
IFd1LA0KPkZlbmdndWFuZyA8ZmVuZ2d1YW5nLnd1QGludGVsLmNvbT47IEhhbnNlbiwgRGF2ZQ0K
PjxkYXZlLmhhbnNlbkBpbnRlbC5jb20+OyB4aXNoaS5xaXV4aXNoaUBhbGliYWJhLWluYy5jb207
IEh1YW5nLCBZaW5nDQo+PHlpbmcuaHVhbmdAaW50ZWwuY29tPjsgbGludXgtbW1Aa3ZhY2sub3Jn
OyBsaW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3JnDQo+U3ViamVjdDogUmU6IFtSRkMgUEFUQ0gg
MC81XSBOZXcgZmFsbGJhY2sgd29ya2Zsb3cgZm9yIGhldGVyb2dlbmVvdXMNCj5tZW1vcnkgc3lz
dGVtDQo+DQo+T24gVGh1LCBBcHIgMjUsIDIwMTkgYXQgMTowNSBBTSBEdSwgRmFuIDxmYW4uZHVA
aW50ZWwuY29tPiB3cm90ZToNCj4+DQo+Pg0KPj4NCj4+ID4tLS0tLU9yaWdpbmFsIE1lc3NhZ2Ut
LS0tLQ0KPj4gPkZyb206IG93bmVyLWxpbnV4LW1tQGt2YWNrLm9yZyBbbWFpbHRvOm93bmVyLWxp
bnV4LW1tQGt2YWNrLm9yZ10gT24NCj4+ID5CZWhhbGYgT2YgTWljaGFsIEhvY2tvDQo+PiA+U2Vu
dDogVGh1cnNkYXksIEFwcmlsIDI1LCAyMDE5IDM6NTQgUE0NCj4+ID5UbzogRHUsIEZhbiA8ZmFu
LmR1QGludGVsLmNvbT4NCj4+ID5DYzogYWtwbUBsaW51eC1mb3VuZGF0aW9uLm9yZzsgV3UsIEZl
bmdndWFuZw0KPjxmZW5nZ3Vhbmcud3VAaW50ZWwuY29tPjsNCj4+ID5XaWxsaWFtcywgRGFuIEog
PGRhbi5qLndpbGxpYW1zQGludGVsLmNvbT47IEhhbnNlbiwgRGF2ZQ0KPj4gPjxkYXZlLmhhbnNl
bkBpbnRlbC5jb20+OyB4aXNoaS5xaXV4aXNoaUBhbGliYWJhLWluYy5jb207IEh1YW5nLCBZaW5n
DQo+PiA+PHlpbmcuaHVhbmdAaW50ZWwuY29tPjsgbGludXgtbW1Aa3ZhY2sub3JnOw0KPmxpbnV4
LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmcNCj4+ID5TdWJqZWN0OiBSZTogW1JGQyBQQVRDSCAwLzVd
IE5ldyBmYWxsYmFjayB3b3JrZmxvdyBmb3IgaGV0ZXJvZ2VuZW91cw0KPj4gPm1lbW9yeSBzeXN0
ZW0NCj4+ID4NCj4+ID5PbiBUaHUgMjUtMDQtMTkgMDc6NDE6NDAsIER1LCBGYW4gd3JvdGU6DQo+
PiA+Pg0KPj4gPj4NCj4+ID4+ID4tLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPj4gPj4gPkZy
b206IE1pY2hhbCBIb2NrbyBbbWFpbHRvOm1ob2Nrb0BrZXJuZWwub3JnXQ0KPj4gPj4gPlNlbnQ6
IFRodXJzZGF5LCBBcHJpbCAyNSwgMjAxOSAyOjM3IFBNDQo+PiA+PiA+VG86IER1LCBGYW4gPGZh
bi5kdUBpbnRlbC5jb20+DQo+PiA+PiA+Q2M6IGFrcG1AbGludXgtZm91bmRhdGlvbi5vcmc7IFd1
LCBGZW5nZ3VhbmcNCj4+ID48ZmVuZ2d1YW5nLnd1QGludGVsLmNvbT47DQo+PiA+PiA+V2lsbGlh
bXMsIERhbiBKIDxkYW4uai53aWxsaWFtc0BpbnRlbC5jb20+OyBIYW5zZW4sIERhdmUNCj4+ID4+
ID48ZGF2ZS5oYW5zZW5AaW50ZWwuY29tPjsgeGlzaGkucWl1eGlzaGlAYWxpYmFiYS1pbmMuY29t
OyBIdWFuZywgWWluZw0KPj4gPj4gPjx5aW5nLmh1YW5nQGludGVsLmNvbT47IGxpbnV4LW1tQGt2
YWNrLm9yZzsNCj4+ID5saW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3JnDQo+PiA+PiA+U3ViamVj
dDogUmU6IFtSRkMgUEFUQ0ggMC81XSBOZXcgZmFsbGJhY2sgd29ya2Zsb3cgZm9yIGhldGVyb2dl
bmVvdXMNCj4+ID4+ID5tZW1vcnkgc3lzdGVtDQo+PiA+PiA+DQo+PiA+PiA+T24gVGh1IDI1LTA0
LTE5IDA5OjIxOjMwLCBGYW4gRHUgd3JvdGU6DQo+PiA+PiA+Wy4uLl0NCj4+ID4+ID4+IEhvd2V2
ZXIgUE1FTSBoYXMgZGlmZmVyZW50IGNoYXJhY3RlcmlzdGljcyBmcm9tIERSQU0sDQo+PiA+PiA+
PiB0aGUgbW9yZSByZWFzb25hYmxlIG9yIGRlc2lyYWJsZSBmYWxsYmFjayBzdHlsZSB3b3VsZCBi
ZToNCj4+ID4+ID4+IERSQU0gbm9kZSAwIC0+IERSQU0gbm9kZSAxIC0+IFBNRU0gbm9kZSAyIC0+
IFBNRU0gbm9kZSAzLg0KPj4gPj4gPj4gV2hlbiBEUkFNIGlzIGV4aGF1c3RlZCwgdHJ5IFBNRU0g
dGhlbi4NCj4+ID4+ID4NCj4+ID4+ID5XaHkgYW5kIHdobyBkb2VzIGNhcmU/IE5VTUEgaXMgZnVu
ZGFtZW50YWxseSBhYm91dCBtZW1vcnkgbm9kZXMNCj4+ID53aXRoDQo+PiA+PiA+ZGlmZmVyZW50
IGFjY2VzcyBjaGFyYWN0ZXJpc3RpY3Mgc28gd2h5IGlzIFBNRU0gYW55IHNwZWNpYWw/DQo+PiA+
Pg0KPj4gPj4gTWljaGFsLCB0aGFua3MgZm9yIHlvdXIgY29tbWVudHMhDQo+PiA+Pg0KPj4gPj4g
VGhlICJkaWZmZXJlbnQiIGxpZXMgaW4gdGhlIGxvY2FsIG9yIHJlbW90ZSBhY2Nlc3MsIHVzdWFs
bHkgdGhlIHVuZGVybHlpbmcNCj4+ID4+IG1lbW9yeSBpcyB0aGUgc2FtZSB0eXBlLCBpLmUuIERS
QU0uDQo+PiA+Pg0KPj4gPj4gQnkgInNwZWNpYWwiLCBQTUVNIGlzIHVzdWFsbHkgaW4gZ2lnYW50
aWMgY2FwYWNpdHkgdGhhbiBEUkFNIHBlciBkaW1tLA0KPj4gPj4gd2hpbGUgd2l0aCBkaWZmZXJl
bnQgcmVhZC93cml0ZSBhY2Nlc3MgbGF0ZW5jeSB0aGFuIERSQU0uDQo+PiA+DQo+PiA+WW91IGFy
ZSBkZXNjcmliaW5nIGEgTlVNQSBpbiBnZW5lcmFsIGhlcmUuIFllcyBhY2Nlc3MgdG8gZGlmZmVy
ZW50IE5VTUENCj4+ID5ub2RlcyBoYXMgYSBkaWZmZXJlbnQgcmVhZC93cml0ZSBsYXRlbmN5LiBC
dXQgdGhhdCBkb2Vzbid0IG1ha2UgUE1FTQ0KPj4gPnJlYWxseSBzcGVjaWFsIGZyb20gYSByZWd1
bGFyIERSQU0uDQo+Pg0KPj4gTm90IHRoZSBudW1hIGRpc3RhbmNlIGIvdyBjcHUgYW5kIFBNRU0g
bm9kZSBtYWtlIFBNRU0gZGlmZmVyZW50DQo+dGhhbg0KPj4gRFJBTS4gVGhlIGRpZmZlcmVuY2Ug
bGllcyBpbiB0aGUgcGh5c2ljYWwgbGF5ZXIuIFRoZSBhY2Nlc3MgbGF0ZW5jeQ0KPmNoYXJhY3Rl
cmlzdGljcw0KPj4gY29tZXMgZnJvbSBtZWRpYSBsZXZlbC4NCj4NCj5ObywgdGhlcmUgaXMgbm8g
c3VjaCB0aGluZyBhcyBhICJQTUVNIG5vZGUiLiBJJ3ZlIHB1c2hlZCBiYWNrIG9uIHRoaXMNCj5i
cm9rZW4gY29uY2VwdCBpbiB0aGUgcGFzdCBbMV0gWzJdLiBDb25zaWRlciB0aGF0IFBNRU0gY291
bGQgYmUgYXMNCj5mYXN0IGFzIERSQU0gZm9yIHRlY2hub2xvZ2llcyBsaWtlIE5WRElNTS1OIG9y
IGluIGVtdWxhdGlvbg0KPmVudmlyb25tZW50cy4gVGhlc2UgYXR0ZW1wdHMgdG8gbG9vayBhdCBw
ZXJzaXN0ZW5jZSBhcyBhbiBhdHRyaWJ1dGUgb2YNCj5wZXJmb3JtYW5jZSBhcmUgZW50aXJlbHkg
bWlzc2luZyB0aGUgcG9pbnQgdGhhdCB0aGUgc3lzdGVtIGNhbiBoYXZlDQo+bXVsdGlwbGUgdmFy
aWVkIG1lbW9yeSB0eXBlcyBhbmQgdGhlIHBsYXRmb3JtIGZpcm13YXJlIG5lZWRzIHRvDQo+ZW51
bWVyYXRlIHRoZXNlIHBlcmZvcm1hbmNlIHByb3BlcnRpZXMgaW4gdGhlIEhNQVQgb24gQUNQSSBw
bGF0Zm9ybXMuDQo+QW55IHNjaGVtZSB0aGF0IG9ubHkgY29uc2lkZXJzIGEgYmluYXJ5IERSQU0g
YW5kIG5vdC1EUkFNIHByb3BlcnR5IGlzDQo+aW1tZWRpYXRlbHkgaW52YWxpZGF0ZWQgdGhlIG1v
bWVudCB0aGUgT1MgbmVlZHMgdG8gY29uc2lkZXIgYSAzcmQgb3INCj40dGggbWVtb3J5IHR5cGUs
IG9yIGEgbW9yZSB2YXJpZWQgY29ubmVjdGlvbiB0b3BvbG9neS4NCg0KRGFuLCBUaGFua3MgZm9y
IHlvdXIgY29tbWVudHMhDQoNCkkndmUgdW5kZXJzdG9vZCB5b3VyIHBvaW50IGZyb20gdGhlIHZl
cnkgYmVnaW5uaW5nIHRpbWUgb2YgeW91ciBwb3N0IGJlZm9yZS4NCkJlbG93IGlzIG15IHNvbWV0
aGluZyBpbiBteSBtaW5kIGFzIGEgW3N0YW5kYWxvbmUgcGVyc29uYWwgY29udHJpYnV0b3JdIG9u
bHk6DQphLiBJIGZ1bGx5IHJlY29nbml6ZWQgd2hhdCBITUFUIGlzIGRlc2lnbmVkIGZvci4NCmIu
IEkgdW5kZXJzdG9vZCB5b3VyIHBvaW50IGZvciB0aGUgInR5cGUiIHRoaW5nIGlzIHRlbXBvcmFs
LCBhbmQgdGhpbmsgeW91IGFyZSByaWdodCBhYm91dCB5b3VyDQogIHBvaW50Lg0KDQpBIGdlbmVy
aWMgYXBwcm9hY2ggaXMgaW5kZWVkIHJlcXVpcmVkLCBob3dldmVyIEkgd2hhdCB0byBlbGFib3Jh
dGUgdGhlIHBvaW50IG9mIHRoZSBwcm9ibGVtDQpJJ20gdHJ5aW5nIHRvIHNvbHZlIGZvciBjdXN0
b21lciwgbm90IGhvdyB3ZSBhbmQgb3RoZXIgcGVvcGxlIHNvbHZlIGl0IG9uZSB3YXkgb3IgYW5v
dGhlci4uDQoNCkN1c3RvbWVyIHJlcXVpcmUgdG8gZnVsbHkgdXRpbGl6ZWQgc3lzdGVtIG1lbW9y
eSwgbm8gbWF0dGVyIERSQU0sIDFzdCBnZW5lcmF0aW9uIFBNRU0sDQpmdXR1cmUgeHRoIGdlbmVy
YXRpb24gUE1FTSB3aGljaCBiZWF0cyBEUkFNLg0KQ3VzdG9tZXIgcmVxdWlyZSB0byBleHBsaWNp
dGx5IFtjb2Fyc2UgZ3JhaW5lZF0gY29udHJvbCB0aGUgbWVtb3J5IGFsbG9jYXRpb24gZm9yIGRp
ZmZlcmVudA0KbGF0ZW5jeS9iYW5kd2lkdGguDQoNCk1heWJlIGl0J3MgbW9yZSB3b3J0aHdoaWxl
IHRvIHRoaW5rIHdoYXQgaXMgbmVlZGVkIGVzc2VudGlhbGx5IHRvIHNvbHZlIHRoZSBwcm9ibGVt
LA0KQW5kIG1ha2Ugc3VyZSBpdCBzY2FsZSB3ZWxsIGVub3VnaCBmb3Igc29tZSBwZXJpb2QuDQoN
CmEuIEJ1aWxkIGZhbGxiYWNrIGxpc3QgZm9yIGhldGVyb2dlbmVvdXMgc3lzdGVtLg0KICBJIHBy
ZWZlciB0byBidWlsZCBpdCBwZXIgSE1BVCwgYmVjYXVzZSBITUFUIGV4cG9zZSB0aGUgbGF0ZW5j
eS9iYW5kd2lkdGggZnJvbSBsb2NhbCBub2RlDQogIFBlcnNwZWN0aXZlLCBpdCdzIGFscmVhZHkg
c3RhbmRhcmRpemVkIGluIEFDUEkgU3BlYy4gTlVNQSBub2RlIGRpc3RhbmNlIGZyb20gU0xJVCB3
b3VsZG4ndCBiZQ0KICBtb3JlIGFjY3VyYXRlbHkgaGVscGZ1bCBmb3IgaGV0ZXJvZ2VuZW91cyBt
ZW1vcnkgc3lzdGVtIGFueW1vcmUuDQoNCmIuIFByb3ZpZGUgZXhwbGljaXQgcGFnZSBhbGxvY2F0
aW9uIG9wdGlvbiBmb3IgZnJlcXVlbnRseSByZWFkIGFjY2Vzc2VkIHBhZ2VzIHJlcXVlc3QuDQog
IFRoaXMgcmVxdWlyZW1lbnQgaXMgd2VsbCBqdXN0aWZpZWQgYXMgd2VsbC4gQWxsIHNjZW5hcmlv
IGJvdGggaW4ga2VybmVsIG9yIHVzZXIgbGV2ZWwsIGRvbid0IGNhcmUgYWJvdXQNCiAgd3JpdGUg
bGF0ZW5jeSBzaG91bGQgbGV2ZXJhZ2UgdGhpcyBvcHRpb24gdG8gYXJjaGl2ZSBvdmVyYWxsIG9w
dGltYWwgcGVyZm9ybWFuY2UuDQoNCmMuIE5VTUEgYmFsYW5jaW5nIGZvciBoZXRlcm9nZW5lb3Vz
IHN5c3RlbS4NCiAgSSdtIGF3YXJlIG9mIHRoaXMgdG9waWMsIGJ1dCBpdCdzIG5vdCB3aGF0IEkg
aW4gbWluZChhLiBiLikgcmlnaHQgbm93Lg0KDQoNCj5bMV06DQo+aHR0cHM6Ly9sb3JlLmtlcm5l
bC5vcmcvbGttbC9DQVBjeXY0aGVpVWJadlA3RXdveS1IeT0tbVByZGpDakV1U3crMHJ3ZA0KPk9V
SGRqd2V0eGdAbWFpbC5nbWFpbC5jb20vDQo+DQo+WzJdOg0KPmh0dHBzOi8vbG9yZS5rZXJuZWwu
b3JnL2xrbWwvQ0FQY3l2NGl0MXc3U2REVkJWMjRjUkNWSHRMYjNzMXBWQjUrU0RNMA0KPjJVdzRS
YmFoS2lBQG1haWwuZ21haWwuY29tLw0K

