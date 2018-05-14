Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 54AFE6B0003
	for <linux-mm@kvack.org>; Mon, 14 May 2018 11:28:50 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id s8-v6so6468641pgf.0
        for <linux-mm@kvack.org>; Mon, 14 May 2018 08:28:50 -0700 (PDT)
Received: from esa5.hgst.iphmx.com (esa5.hgst.iphmx.com. [216.71.153.144])
        by mx.google.com with ESMTPS id q66-v6si9715158pfi.235.2018.05.14.08.28.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 May 2018 08:28:47 -0700 (PDT)
From: Bart Van Assche <Bart.VanAssche@wdc.com>
Subject: Re: [PATCH 4/6] block: pass an explicit gfp_t to get_request
Date: Mon, 14 May 2018 15:28:44 +0000
Message-ID: <37bffee5b400e82f22ea1306052d4fbef4da2b0e.camel@wdc.com>
References: <20180509075408.16388-1-hch@lst.de>
	 <20180509075408.16388-5-hch@lst.de>
In-Reply-To: <20180509075408.16388-5-hch@lst.de>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <CD6BB4D3D94E5044B35B0CC306198893@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "willy@infradead.org" <willy@infradead.org>

T24gV2VkLCAyMDE4LTA1LTA5IGF0IDA5OjU0ICswMjAwLCBDaHJpc3RvcGggSGVsbHdpZyB3cm90
ZToNCj4gYmxrX29sZF9nZXRfcmVxdWVzdCBhbHJlYWR5IGhhcyBpdCBhdCBoYW5kLCBhbmQgaW4g
YmxrX3F1ZXVlX2Jpbywgd2hpY2gNCj4gaXMgdGhlIGZhc3QgcGF0aCwgaXQgaXMgY29uc3RhbnQu
DQoNClJldmlld2VkLWJ5OiBCYXJ0IFZhbiBBc3NjaGUgPGJhcnQudmFuYXNzY2hlQHdkYy5jb20+
DQoNCg0K
