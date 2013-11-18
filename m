Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 356DE6B0039
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 14:23:06 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id md12so735727pbc.35
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 11:23:05 -0800 (PST)
Received: from psmtp.com ([74.125.245.133])
        by mx.google.com with SMTP id fn9si10379307pab.275.2013.11.18.11.23.04
        for <linux-mm@kvack.org>;
        Mon, 18 Nov 2013 11:23:04 -0800 (PST)
From: "Jiang, Dave" <dave.jiang@intel.com>
Subject: Re: [v3][PATCH 0/2] v3: fix hugetlb vs. anon-thp copy page
Date: Mon, 18 Nov 2013 19:23:01 +0000
Message-ID: <1384802581.72241.7.camel@djiang5-linux2.ch.intel.com>
References: <20131115225550.737E5C33@viggo.jf.intel.com>
In-Reply-To: <20131115225550.737E5C33@viggo.jf.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <BA603B6EF9F7DB48B446D24202C376D2@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "dhillf@gmail.com" <dhillf@gmail.com>, Naoya
 Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>

T24gRnJpLCAyMDEzLTExLTE1IGF0IDE0OjU1IC0wODAwLCBEYXZlIEhhbnNlbiB3cm90ZToNCj4g
VGhpcyB0b29rIHNvbWUgb2YgTWVsJ3MgY29tbWVudHMgaW4gdG8gY29uc2lkZXJhdGlvbi4gIERh
dmUNCj4gSmlhbmcsIGNvdWxkIHlvdSByZXRlc3QgdGhpcyBpZiB5b3UgZ2V0IGEgY2hhbmNlPyAg
VGhlc2UgaGF2ZQ0KPiBvbmx5IGJlZW4gbGlnaHRseSBjb21waWxlLXRlc3RlZC4NCj4gDQoNCkV2
ZXJ5dGhpbmcgbG9va3MgZ29vZC4gDQoNClRlc3RlZC1ieTogRGF2ZSBKaWFuZyA8ZGF2ZS5qaWFu
Z0BpbnRlbC5jb20+DQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
