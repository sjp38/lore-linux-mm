Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 07EAB6B0003
	for <linux-mm@kvack.org>; Mon, 14 May 2018 11:35:22 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id o23-v6so11504551pll.12
        for <linux-mm@kvack.org>; Mon, 14 May 2018 08:35:21 -0700 (PDT)
Received: from esa1.hgst.iphmx.com (esa1.hgst.iphmx.com. [68.232.141.245])
        by mx.google.com with ESMTPS id ba12-v6si9104182plb.384.2018.05.14.08.35.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 May 2018 08:35:20 -0700 (PDT)
From: Bart Van Assche <Bart.VanAssche@wdc.com>
Subject: Re: [PATCH 6/6] block: consistently use GFP_NOIO instead of
 __GFP_NORECLAIM
Date: Mon, 14 May 2018 15:35:17 +0000
Message-ID: <f8876c76af1cbf22a2247de624f614d26b5654ac.camel@wdc.com>
References: <20180509075408.16388-1-hch@lst.de>
	 <20180509075408.16388-7-hch@lst.de>
In-Reply-To: <20180509075408.16388-7-hch@lst.de>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <B052631CFE0F624596FE0C22B4CF6660@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "willy@infradead.org" <willy@infradead.org>

T24gV2VkLCAyMDE4LTA1LTA5IGF0IDA5OjU0ICswMjAwLCBDaHJpc3RvcGggSGVsbHdpZyB3cm90
ZToNCj4gU2FtZSBudW1lcmljYWwgdmFsdWUgKGZvciBub3cgYXQgbGVhc3QpLCBidXQgYSBtdWNo
IGJldHRlciBkb2N1bWVudGF0aW9uDQo+IG9mIGludGVudC4NCg0KVGhlcmUgaXMgYSB0eXBvIGlu
IHRoZSBzdWJqZWN0IG9mIHRoaXMgcGF0Y2g6IF9fR0ZQX05PUkVDTEFJTSBzaG91bGQgYmUNCmNo
YW5nZWQgaW50byBfX0dGUF9SRUNMQUlNLiBPdGhlcndpc2U6DQoNClJldmlld2VkLWJ5OiBCYXJ0
IFZhbiBBc3NjaGUgPGJhcnQudmFuYXNzY2hlQHdkYy5jb20+DQoNCg0KDQo=
