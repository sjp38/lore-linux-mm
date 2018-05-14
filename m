Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A85146B0003
	for <linux-mm@kvack.org>; Mon, 14 May 2018 11:30:29 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g1-v6so10860005pfh.19
        for <linux-mm@kvack.org>; Mon, 14 May 2018 08:30:29 -0700 (PDT)
Received: from esa4.hgst.iphmx.com (esa4.hgst.iphmx.com. [216.71.154.42])
        by mx.google.com with ESMTPS id d24-v6si9585135plr.302.2018.05.14.08.30.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 May 2018 08:30:27 -0700 (PDT)
From: Bart Van Assche <Bart.VanAssche@wdc.com>
Subject: Re: [PATCH 5/6] block: use GFP_NOIO instead of __GFP_DIRECT_RECLAIM
Date: Mon, 14 May 2018 15:30:22 +0000
Message-ID: <8716105a867b898e4785339de5bef1ab1d1f019c.camel@wdc.com>
References: <20180509075408.16388-1-hch@lst.de>
	 <20180509075408.16388-6-hch@lst.de>
In-Reply-To: <20180509075408.16388-6-hch@lst.de>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <4D7FAD006754824DB632F84F817DC78F@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "willy@infradead.org" <willy@infradead.org>

T24gV2VkLCAyMDE4LTA1LTA5IGF0IDA5OjU0ICswMjAwLCBDaHJpc3RvcGggSGVsbHdpZyB3cm90
ZToNCj4gV2UganVzdCBjYW4ndCBkbyBJL08gd2hlbiBkb2luZyBibG9jayBsYXllciByZXF1ZXN0
cyBhbGxvY2F0aW9ucywNCj4gc28gdXNlIEdGUF9OT0lPIGluc3RlYWQgb2YgdGhlIGV2ZW4gbW9y
ZSBsaW1pdGVkIF9fR0ZQX0RJUkVDVF9SRUNMQUlNLg0KDQpSZXZpZXdlZC1ieTogQmFydCBWYW4g
QXNzY2hlIDxiYXJ0LnZhbmFzc2NoZUB3ZGMuY29tPg0KDQoNCg==
