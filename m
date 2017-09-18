Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5BC936B0253
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 02:55:17 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id g32so15661564ioj.0
        for <linux-mm@kvack.org>; Sun, 17 Sep 2017 23:55:17 -0700 (PDT)
Received: from smtpbg65.qq.com (smtpbg65.qq.com. [103.7.28.233])
        by mx.google.com with ESMTPS id b9si4064725oif.108.2017.09.17.23.55.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 17 Sep 2017 23:55:13 -0700 (PDT)
From: "=?utf-8?B?6ZmI5Y2O5omN?=" <chenhc@lemote.com>
Subject: Re: [PATCH V5 2/3] mm: dmapool: Align to ARCH_DMA_MINALIGN innon-coherent DMA mode
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Date: Mon, 18 Sep 2017 14:55:08 +0800
Message-ID: <tencent_68A77D143FD0DC0E5D6D1C1E@qq.com>
References: <1505708548-4750-1-git-send-email-chenhc@lemote.com>
	<20170918052208.GB29118@infradead.org>
In-Reply-To: <20170918052208.GB29118@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?Q2hyaXN0b3BoIEhlbGx3aWc=?= <hch@infradead.org>
Cc: =?utf-8?B?QW5kcmV3IE1vcnRvbg==?= <akpm@linux-foundation.org>, =?utf-8?B?RnV4aW4gWmhhbmc=?= <zhangfx@lemote.com>, =?utf-8?B?bGludXgtbW0=?= <linux-mm@kvack.org>, =?utf-8?B?bGludXgta2VybmVs?= <linux-kernel@vger.kernel.org>, =?utf-8?B?c3RhYmxl?= <stable@vger.kernel.org>

SGksIENocmlzdG9waCwNCg0KTWF5YmUgeW91IG1pc3NlZCBzb21ldGhpbmcuDQoxLCBwb29s
X2FsbG9jX3BhZ2UoKSB1c2UgZG1hX2FsbG9jX2NvaGVyZW50KCkgdG8gYWxsb2NhdGUgcG9v
bCBwYWdlcywgYW5kIG9mIGNvdXJzZSB0aGVzZSBwYWdlcyBhcmUgYWxpZ25lZCB0byAgQVJD
SF9ETUFfTUlOQUxJR04uDQoyLCBkbWFfcG9vbF9hbGxvYygpIGlzIHRoZSBlbGVtZW50IGFs
bG9jYXRvciwgYnV0IGl0IGRvZXNuJ3QgdXNlIGRtYV9hbGxvY19jb2hlcmVudCgpLiBFbGVt
ZW50cyBvbmx5IGFsaWduIHRvIHBvb2wtPnNpemUsIGJ1dCBwb29sLT5zaXplIGlzIHVzdWFs
bHkgbGVzcyB0aGFuIEFSQ0hfRE1BX01JTkFMSUdOLg0KMywgQVJDSF9ETUFfTUlOQUxJR04g
aXMgbm93IG9ubHkgdXNlZCBpbiBzZXJ2ZXJhbCBkcml2ZXJzLCBubyBkbWFfb3BzIHVzZSBp
dC4NCg0KSHVhY2FpDQogDQotLS0tLS0tLS0tLS0tLS0tLS0gT3JpZ2luYWwgLS0tLS0tLS0t
LS0tLS0tLS0tDQpGcm9tOiAgIkNocmlzdG9waCBIZWxsd2lnIjxoY2hAaW5mcmFkZWFkLm9y
Zz47DQpEYXRlOiAgTW9uLCBTZXAgMTgsIDIwMTcgMDE6MjIgUE0NClRvOiAgIkh1YWNhaSBD
aGVuIjxjaGVuaGNAbGVtb3RlLmNvbT47DQpDYzogICJBbmRyZXcgTW9ydG9uIjxha3BtQGxp
bnV4LWZvdW5kYXRpb24ub3JnPjsgIkZ1eGluIFpoYW5nIjx6aGFuZ2Z4QGxlbW90ZS5jb20+
OyAibGludXgtbW0iPGxpbnV4LW1tQGt2YWNrLm9yZz47ICJsaW51eC1rZXJuZWwiPGxpbnV4
LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmc+OyAic3RhYmxlIjxzdGFibGVAdmdlci5rZXJuZWwu
b3JnPjsNClN1YmplY3Q6ICBSZTogW1BBVENIIFY1IDIvM10gbW06IGRtYXBvb2w6IEFsaWdu
IHRvIEFSQ0hfRE1BX01JTkFMSUdOIGlubm9uLWNvaGVyZW50IERNQSBtb2RlDQogDQpUaGUg
ZG1hcG9vbCBjb2RlIHVzZXMgZG1hX2FsbG9jX2NvaGVyZW50IHRvIGFsbG9jYXRlIGVhY2gg
ZWxlbWVudCwNCmFuZCBkbWFfYWxsb2NfY29oZXJlbnQgbXVzdCBhbGlnbiB0byBBUkNIX0RN
QV9NSU5BTElHTiBhbHJlYWR5Lg0KSWYgeW91IGltcGxlbWVudGF0aW9uIGRvZXNuJ3QgZG8g
dGhhdCBpdCBuZWVkcyB0byBiZSBmaXhlZC4=



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
