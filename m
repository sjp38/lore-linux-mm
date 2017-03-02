Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 056EC6B0038
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 11:40:03 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id c85so106910793qkg.0
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 08:40:03 -0800 (PST)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0120.outbound.protection.outlook.com. [104.47.33.120])
        by mx.google.com with ESMTPS id n14si7292513qtn.205.2017.03.02.08.40.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 08:40:02 -0800 (PST)
From: Matthew Wilcox <mawilcox@microsoft.com>
Subject: RE: [PATCH] radix tree test suite: Fix build with --as-needed
Date: Thu, 2 Mar 2017 16:39:59 +0000
Message-ID: <BY2PR21MB0036FE94684B28B32F367BF6CB280@BY2PR21MB0036.namprd21.prod.outlook.com>
References: <1488446952-25342-1-git-send-email-mpe@ellerman.id.au>
In-Reply-To: <1488446952-25342-1-git-send-email-mpe@ellerman.id.au>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

VGhhbmtzLCBhcHBsaWVkLg0KDQpGcm9tOiBNaWNoYWVsIEVsbGVybWFuIFttYWlsdG86bXBlQGVs
bGVybWFuLmlkLmF1XQ0KPiBDdXJyZW50bHkgdGhlIHJhZGl4IHRyZWUgdGVzdCBzdWl0ZSBkb2Vz
bid0IGJ1aWxkIHdpdGggdG9vbGNoYWlucyB0aGF0DQo+IHVzZSAtLWFzLW5lZWRlZCBieSBkZWZh
dWx0LCBmb3IgZXhhbXBsZSBVYnVudHUnczoNCg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
