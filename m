Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id D95586B025E
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 23:43:22 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id q12so7092791plk.16
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 20:43:22 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id l132si3793744pfc.202.2018.01.09.20.43.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jan 2018 20:43:22 -0800 (PST)
From: "Lu, Aaron" <aaron.lu@intel.com>
Subject: Re: [aaron:for_lkp_skl_2sp2_test 151/225]
 drivers/net//ethernet/netronome/nfp/nfp_net_common.c:1188:116: error:
 '__GFP_COLD' undeclared
Date: Wed, 10 Jan 2018 04:43:18 +0000
Message-ID: <1515559436.32635.0.camel@intel.com>
References: <201801100639.1FfQRG2U%fengguang.wu@intel.com>
	 <1515548125.31639.2.camel@intel.com>
	 <20180110044218.gq5nxa4cuvqpamlg@wfg-t540p.sh.intel.com>
In-Reply-To: <20180110044218.gq5nxa4cuvqpamlg@wfg-t540p.sh.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <971FF8CADCACD44B98DD08B7D996766A@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wu, Fengguang" <fengguang.wu@intel.com>
Cc: "kbuild-all@01.org" <kbuild-all@01.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mgorman@suse.de" <mgorman@suse.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

T24gV2VkLCAyMDE4LTAxLTEwIGF0IDEyOjQyICswODAwLCBGZW5nZ3VhbmcgV3Ugd3JvdGU6DQo+
ID4gSSBqdXN0IHJlbW92ZWQgdGhlIGJyYW5jaCwgdGhlcmUgc2hvdWxkIGJlIG5vIG1vcmUgc3Vj
aCByZXBvcnRzLg0KPiANCj4gVGhlIG90aGVyIG9wdGlvbiBpcyB0byBhZGQgInJmYyIgb3IgIlJG
QyIgc29tZXdoZXJlIGluIHRoZSBicmFuY2gNCj4gbmFtZS4gSSdsbCBtYXJrIHN1Y2ggYnJhbmNo
ZXMgYXMgcHJpdmF0ZSByZXBvcnRpbmcgb25lcy4NCg0KV2VsbCB0aGF0J3MgY29vbCwgdGhhbmtz
IGEgbG90IQ==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
