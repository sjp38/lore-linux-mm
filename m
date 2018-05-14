Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C438F6B0007
	for <linux-mm@kvack.org>; Mon, 14 May 2018 11:14:47 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id l85-v6so10735100pfb.18
        for <linux-mm@kvack.org>; Mon, 14 May 2018 08:14:47 -0700 (PDT)
Received: from esa6.hgst.iphmx.com (esa6.hgst.iphmx.com. [216.71.154.45])
        by mx.google.com with ESMTPS id 38-v6si73625plc.446.2018.05.14.08.14.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 May 2018 08:14:45 -0700 (PDT)
From: Bart Van Assche <Bart.VanAssche@wdc.com>
Subject: Re: [PATCH 1/6] scsi/osd: remove the gfp argument to
 osd_start_request
Date: Mon, 14 May 2018 15:14:42 +0000
Message-ID: <359319f8f1c26c350dfe1c900ebcf3878ffd384c.camel@wdc.com>
References: <20180509075408.16388-1-hch@lst.de>
	 <20180509075408.16388-2-hch@lst.de>
In-Reply-To: <20180509075408.16388-2-hch@lst.de>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <33F680F2A576004C81D57BA76AFCC898@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "willy@infradead.org" <willy@infradead.org>

T24gV2VkLCAyMDE4LTA1LTA5IGF0IDA5OjU0ICswMjAwLCBDaHJpc3RvcGggSGVsbHdpZyB3cm90
ZToNCj4gQWx3YXlzIEdGUF9LRVJORUwsIGFuZCBrZWVwaW5nIGl0IHdvdWxkIGNhdXNlIHNlcmlv
dXMgY29tcGxpY2F0aW9ucyBmb3INCj4gdGhlIG5leHQgY2hhbmdlLg0KDQpUaGlzIHBhdGNoIGRl
c2NyaXB0aW9uIGlzIHZlcnkgYnJpZWYuIFNob3VsZG4ndCB0aGUgZGVzY3JpcHRpb24gb2YgdGhp
cyBwYXRjaA0KbWVudGlvbiB3aGV0aGVyIG9yIG5vdCBhbnkgZnVuY3Rpb25hbGl0eSBpcyBjaGFu
Z2VkIChJIHRoaW5rIG5vIGZ1bmN0aW9uYWxpdHkNCmhhcyBiZWVuIGNoYW5nZWQpPw0KDQpCYXJ0
Lg0KDQoNCg0K
