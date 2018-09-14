Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E19718E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 16:37:54 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d22-v6so5183140pfn.3
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 13:37:54 -0700 (PDT)
Received: from g2t2352.austin.hpe.com (g2t2352.austin.hpe.com. [15.233.44.25])
        by mx.google.com with ESMTPS id w5-v6si7732180plz.175.2018.09.14.13.37.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 13:37:53 -0700 (PDT)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: [PATCH 3/5] x86: pgtable: Drop pXd_none() checks from
 pXd_free_pYd_table()
Date: Fri, 14 Sep 2018 20:37:48 +0000
Message-ID: <dc8b03de1e3318e3dd577d80482260f99ab4e9a5.camel@hpe.com>
References: <1536747974-25875-1-git-send-email-will.deacon@arm.com>
	 <1536747974-25875-4-git-send-email-will.deacon@arm.com>
In-Reply-To: <1536747974-25875-4-git-send-email-will.deacon@arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <E1FA3F5CC3F7D74FA70DC541EA54D9DA@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "will.deacon@arm.com" <will.deacon@arm.com>
Cc: "tglx@linutronix.de" <tglx@linutronix.de>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "Hocko, Michal" <MHocko@suse.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

T24gV2VkLCAyMDE4LTA5LTEyIGF0IDExOjI2ICswMTAwLCBXaWxsIERlYWNvbiB3cm90ZToNCj4g
Tm93IHRoYXQgdGhlIGNvcmUgY29kZSBjaGVja3MgdGhpcyBmb3IgdXMsIHdlIGRvbid0IG5lZWQg
dG8gZG8gaXQgaW4gdGhlDQo+IGJhY2tlbmQuDQo+IA0KPiBDYzogQ2hpbnRhbiBQYW5keWEgPGNw
YW5keWFAY29kZWF1cm9yYS5vcmc+DQo+IENjOiBUb3NoaSBLYW5pIDx0b3NoaS5rYW5pQGhwZS5j
b20+DQo+IENjOiBUaG9tYXMgR2xlaXhuZXIgPHRnbHhAbGludXRyb25peC5kZT4NCj4gQ2M6IE1p
Y2hhbCBIb2NrbyA8bWhvY2tvQHN1c2UuY29tPg0KPiBDYzogQW5kcmV3IE1vcnRvbiA8YWtwbUBs
aW51eC1mb3VuZGF0aW9uLm9yZz4NCj4gU2lnbmVkLW9mZi1ieTogV2lsbCBEZWFjb24gPHdpbGwu
ZGVhY29uQGFybS5jb20+DQo+IC0tLQ0KPiAgYXJjaC94ODYvbW0vcGd0YWJsZS5jIHwgNiAtLS0t
LS0NCj4gIDEgZmlsZSBjaGFuZ2VkLCA2IGRlbGV0aW9ucygtKQ0KPiANCj4gZGlmZiAtLWdpdCBh
L2FyY2gveDg2L21tL3BndGFibGUuYyBiL2FyY2gveDg2L21tL3BndGFibGUuYw0KPiBpbmRleCBh
ZTM5NDU1MmZiOTQuLmI0OTE5YzQ0YTE5NCAxMDA2NDQNCj4gLS0tIGEvYXJjaC94ODYvbW0vcGd0
YWJsZS5jDQo+ICsrKyBiL2FyY2gveDg2L21tL3BndGFibGUuYw0KPiBAQCAtNzk2LDkgKzc5Niw2
IEBAIGludCBwdWRfZnJlZV9wbWRfcGFnZShwdWRfdCAqcHVkLCB1bnNpZ25lZCBsb25nIGFkZHIp
DQo+ICAJcHRlX3QgKnB0ZTsNCj4gIAlpbnQgaTsNCj4gIA0KPiAtCWlmIChwdWRfbm9uZSgqcHVk
KSkNCj4gLQkJcmV0dXJuIDE7DQo+IC0NCg0KRG8gd2UgbmVlZCB0byByZW1vdmUgdGhpcyBzYWZl
IGd1YXJkPyAgSSBmZWVsIGxpc3QgdGhpcyBpcyBzYW1lIGFzDQprZnJlZSgpIGFjY2VwdGluZyBO
VUxMLg0KDQpUaGFua3MsDQotVG9zaGkNCg0KDQo+ICAJcG1kID0gKHBtZF90ICopcHVkX3BhZ2Vf
dmFkZHIoKnB1ZCk7DQo+ICAJcG1kX3N2ID0gKHBtZF90ICopX19nZXRfZnJlZV9wYWdlKEdGUF9L
RVJORUwpOw0KPiAgCWlmICghcG1kX3N2KQ0KPiBAQCAtODQwLDkgKzgzNyw2IEBAIGludCBwbWRf
ZnJlZV9wdGVfcGFnZShwbWRfdCAqcG1kLCB1bnNpZ25lZCBsb25nIGFkZHIpDQo+ICB7DQo+ICAJ
cHRlX3QgKnB0ZTsNCj4gIA0KPiAtCWlmIChwbWRfbm9uZSgqcG1kKSkNCj4gLQkJcmV0dXJuIDE7
DQo+IC0NCj4gIAlwdGUgPSAocHRlX3QgKilwbWRfcGFnZV92YWRkcigqcG1kKTsNCj4gIAlwbWRf
Y2xlYXIocG1kKTsNCj4gIA0K
