Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id DC7CC6B0351
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 14:38:52 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id j49so89058946qta.1
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 11:38:52 -0800 (PST)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0091.outbound.protection.outlook.com. [104.47.37.91])
        by mx.google.com with ESMTPS id f14si1803619otc.69.2016.11.17.11.38.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 17 Nov 2016 11:38:52 -0800 (PST)
From: Matthew Wilcox <mawilcox@microsoft.com>
Subject: RE: [PATCH 00/29] Improve radix tree for 4.10
Date: Thu, 17 Nov 2016 19:38:49 +0000
Message-ID: <SN1PR21MB007790B99A9DF521782AAF55CBB10@SN1PR21MB0077.namprd21.prod.outlook.com>
References: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
 <1479341856-30320-37-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1479341856-30320-37-git-send-email-mawilcox@linuxonhyperv.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@linuxonhyperv.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross
 Zwisler <ross.zwisler@linux.intel.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

TXkgYXBvbG9naWVzIGZvciB0aGUgY29uZnVzaW9uIGhlcmUuICBTb21lIG9mIHRoZXNlIHBhdGNo
ZXMgYXJlIGluZGVlZCBkdXBsaWNhdGVzIG9mIGVhY2ggb3RoZXIuICBJIGhhZCBydW4gZ2l0IGZv
cm1hdC1wYXRjaCwgdGhlbiBub3RpY2VkIGEgbWlzdGFrZSwgZWRpdGVkIHRoZSBwYXRjaCBzZXQg
YW5kIHJhbiBnaXQgZm9ybWF0LXBhdGNoIGFnYWluIHdpdGhvdXQgZW1wdHlpbmcgdGhlIGRpcmVj
dG9yeSBvZiBwYXRjaGVzLCBzbyBJIGVuZGVkIHVwIHNlbmRpbmcgMzYgZW1haWxzIGluc3RlYWQg
b2YgMjkuDQoNClRoZXJlIHdlcmUgYWxzbyBhIGNvdXBsZSBvZiBzbWFsbCBidWdzIGNhdWdodCBi
eSAwZGF5IGFuZCBhbiBpbmZlbGljaXR5IGluIHRoZSByeHJwYyBjb2RlIHBvaW50ZWQgb3V0IGJ5
IERhdmUgSG93ZWxscy4gIEluc3RlYWQgb2Ygc3BhbW1pbmcgeW91IGFsbCB3aXRoIGFub3RoZXIg
MjkgZW1haWxzLCB0aGUgbGF0ZXN0IHZlcnNpb24gb2YgdGhlIHBhdGNoc2V0IGNhbiBiZSBmb3Vu
ZCBoZXJlOg0KDQpodHRwOi8vZ2l0LmluZnJhZGVhZC5vcmcvdXNlcnMvd2lsbHkvbGludXgtZGF4
LmdpdC9zaG9ydGxvZy9yZWZzL2hlYWRzL2lkci0yMDE2LTExLTE3DQoNCg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
