Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6DEA76B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 14:46:30 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id s16-v6so9738641pfm.1
        for <linux-mm@kvack.org>; Mon, 21 May 2018 11:46:30 -0700 (PDT)
Received: from esa3.hgst.iphmx.com (esa3.hgst.iphmx.com. [216.71.153.141])
        by mx.google.com with ESMTPS id w18-v6si15309526pfl.359.2018.05.21.11.46.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 11:46:29 -0700 (PDT)
From: Bart Van Assche <Bart.VanAssche@wdc.com>
Subject: Re: [PATCH 00/10] Misc block layer patches for bcachefs
Date: Mon, 21 May 2018 18:46:26 +0000
Message-ID: <18450c81c05a4e65e3fcca4ece3f0fe9bad8170f.camel@wdc.com>
References: <20180518090636.GA14738@kmo-pixel>
	 <8f62d8f870c6b66e90d3e7f57acee481acff57f5.camel@wdc.com>
	 <20180520221733.GA11495@kmo-pixel>
	 <bb4fd32d0baa6554615a7ec3b45cc2b89424328e.camel@wdc.com>
	 <20180520223116.GB11495@kmo-pixel>
	 <b0aa2a8737b2d826fea58dc0bc113ddce50f018a.camel@wdc.com>
	 <20180520232139.GE11495@kmo-pixel>
	 <238bacfbc43245159c1586189a436efbb069306b.camel@wdc.com>
	 <20180520235853.GF11495@kmo-pixel>
	 <d3fbfaa667f5ac64c1f230249e3333594cb4a128.camel@wdc.com>
	 <20180521183742.GC14774@vader>
In-Reply-To: <20180521183742.GC14774@vader>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <0DFEDEF0E0F97B4A9351FD1B3BBB9FA9@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "osandov@osandov.com" <osandov@osandov.com>
Cc: "mingo@kernel.org" <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "kent.overstreet@gmail.com" <kent.overstreet@gmail.com>, "axboe@kernel.dk" <axboe@kernel.dk>

T24gTW9uLCAyMDE4LTA1LTIxIGF0IDExOjM3IC0wNzAwLCBPbWFyIFNhbmRvdmFsIHdyb3RlOg0K
PiBIYXZlIHlvdSBtYWRlIGFueSBwcm9ncmVzcyBpbiBwb3J0aW5nIHNycC10ZXN0IHRvIGJsa3Rl
c3RzIHNvIHdlIGRvbid0DQo+IGhhdmUgdG8gaGF2ZSB0aGlzIGNvbnZlcnNhdGlvbiBhZ2Fpbj8N
Cg0KSGVsbG8gT21hciwNCg0KUG9ydGluZyB0aGUgc3JwLXRlc3Qgc29mdHdhcmUgdG8gdGhlIGJs
a3Rlc3RzIGZyYW1ld29yayBpcyBzdGlsbCBoaWdoIG9uIG15DQp0by1kbyBsaXN0LiBJIHdpbGwg
c3RhcnQgd29ya2luZyBvbiB0aGlzIGFzIHNvb24gYXMgdGhlIHdvcmsgb24gYWRkaW5nIFNNUg0K
c3VwcG9ydCBmb3IgZmlvIGhhcyBiZWVuIGNvbXBsZXRlZC4NCg0KQmFydC4NCg0K
