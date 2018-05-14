Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2B2B46B0003
	for <linux-mm@kvack.org>; Mon, 14 May 2018 11:26:42 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id bd7-v6so11550025plb.20
        for <linux-mm@kvack.org>; Mon, 14 May 2018 08:26:42 -0700 (PDT)
Received: from esa1.hgst.iphmx.com (esa1.hgst.iphmx.com. [68.232.141.245])
        by mx.google.com with ESMTPS id v29-v6si8029935pgn.510.2018.05.14.08.26.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 May 2018 08:26:41 -0700 (PDT)
From: Bart Van Assche <Bart.VanAssche@wdc.com>
Subject: Re: [PATCH 3/6] block: sanitize blk_get_request calling conventions
Date: Mon, 14 May 2018 15:26:38 +0000
Message-ID: <51fdc7ba7fbdc70dd323f94c899eeafe69cc8ca0.camel@wdc.com>
References: <20180509075408.16388-1-hch@lst.de>
	 <20180509075408.16388-4-hch@lst.de>
In-Reply-To: <20180509075408.16388-4-hch@lst.de>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <1FBA65168D2E4E4F8DE60ED5301578C4@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "willy@infradead.org" <willy@infradead.org>

T24gV2VkLCAyMDE4LTA1LTA5IGF0IDA5OjU0ICswMjAwLCBDaHJpc3RvcGggSGVsbHdpZyB3cm90
ZToNCj4gU3dpdGNoIGV2ZXJ5b25lIHRvIGJsa19nZXRfcmVxdWVzdF9mbGFncywgYW5kIHRoZW4g
cmVuYW1lDQo+IGJsa19nZXRfcmVxdWVzdF9mbGFncyB0byBibGtfZ2V0X3JlcXVlc3QuDQoNClJl
dmlld2VkLWJ5OiBCYXJ0IFZhbiBBc3NjaGUgPGJhcnQudmFuYXNzY2hlQHdkYy5jb20+DQoNCg0K
DQo=
