Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8F1256B0033
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 21:13:56 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 93so3743463iol.2
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 18:13:56 -0700 (PDT)
Received: from smtpbgau2.qq.com (smtpbgau2.qq.com. [54.206.34.216])
        by mx.google.com with ESMTPS id a5si10022879oii.346.2017.09.13.18.13.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Sep 2017 18:13:55 -0700 (PDT)
From: "=?utf-8?B?6ZmI5Y2O5omN?=" <chenhc@lemote.com>
Subject: Re: [PATCH V3 2/3] mm: dmapool: Align to ARCH_DMA_MINALIGN innon-coherent DMA mode
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Date: Thu, 14 Sep 2017 09:13:47 +0800
Message-ID: <tencent_31D6F9A339CED0D66B83CBD8@qq.com>
References: <1505294451-21312-1-git-send-email-chenhc@lemote.com>
	<20170913145249.f89678a57842da122aa062fd@linux-foundation.org>
In-Reply-To: <20170913145249.f89678a57842da122aa062fd@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?QW5kcmV3IE1vcnRvbg==?= <akpm@linux-foundation.org>
Cc: =?utf-8?B?RnV4aW4gWmhhbmc=?= <zhangfx@lemote.com>, =?utf-8?B?bGludXgtbW0=?= <linux-mm@kvack.org>, =?utf-8?B?bGludXgta2VybmVs?= <linux-kernel@vger.kernel.org>, =?utf-8?B?c3RhYmxl?= <stable@vger.kernel.org>

SGksIEFuZHJldywNCg0KSXQgd2lsbCBjYXVzZSBkYXRhIGNvcnJ1cHRpb24sIGF0IGxlYXN0
IG9uIE1JUFM6DQpzdGVwIDEsIGRtYV9tYXBfc2luZ2xlDQpzdGVwIDIsIGNhY2hlX2ludmFs
aWRhdGUgKG5vIHdyaXRlYmFjaykNCnN0ZXAgMywgZG1hX2Zyb21fZGV2aWNlDQpzdGVwIDQs
IGRtYV91bm1hcF9zaW5nbGUNCklmIGEgRE1BIGJ1ZmZlciBhbmQgYSBrZXJuZWwgc3RydWN0
dXJlIHNoYXJlIGEgc2FtZSBjYWNoZSBsaW5lLCBhbmQgaWYgdGhlIGtlcm5lbCBzdHJ1Y3R1
cmUgaGFzIGRpcnR5IGRhdGEsIGNhY2hlX2ludmFsaWRhdGUgKG5vIHdyaXRlYmFjaykgbWF5
IGNhdXNlIGRhdGEgbG9zdC4NCiANCkh1YWNhaQ0KIA0KLS0tLS0tLS0tLS0tLS0tLS0tIE9y
aWdpbmFsIC0tLS0tLS0tLS0tLS0tLS0tLQ0KRnJvbTogICJBbmRyZXcgTW9ydG9uIjxha3Bt
QGxpbnV4LWZvdW5kYXRpb24ub3JnPjsNCkRhdGU6ICBUaHUsIFNlcCAxNCwgMjAxNyAwNTo1
MiBBTQ0KVG86ICAiSHVhY2FpIENoZW4iPGNoZW5oY0BsZW1vdGUuY29tPjsgDQpDYzogICJG
dXhpbiBaaGFuZyI8emhhbmdmeEBsZW1vdGUuY29tPjsgImxpbnV4LW1tIjxsaW51eC1tbUBr
dmFjay5vcmc+OyAibGludXgta2VybmVsIjxsaW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3Jn
PjsgInN0YWJsZSI8c3RhYmxlQHZnZXIua2VybmVsLm9yZz47IA0KU3ViamVjdDogIFJlOiBb
UEFUQ0ggVjMgMi8zXSBtbTogZG1hcG9vbDogQWxpZ24gdG8gQVJDSF9ETUFfTUlOQUxJR04g
aW5ub24tY29oZXJlbnQgRE1BIG1vZGUNCg0KIA0KT24gV2VkLCAxMyBTZXAgMjAxNyAxNzoy
MDo1MSArMDgwMCBIdWFjYWkgQ2hlbiA8Y2hlbmhjQGxlbW90ZS5jb20+IHdyb3RlOg0KDQo+
IEluIG5vbi1jb2hlcmVudCBETUEgbW9kZSwga2VybmVsIHVzZXMgY2FjaGUgZmx1c2hpbmcg
b3BlcmF0aW9ucyB0bw0KPiBtYWludGFpbiBJL08gY29oZXJlbmN5LCBzbyB0aGUgZG1hcG9v
bCBvYmplY3RzIHNob3VsZCBiZSBhbGlnbmVkIHRvDQo+IEFSQ0hfRE1BX01JTkFMSUdOLg0K
DQpXaGF0IGFyZSB0aGUgdXNlci12aXNpYmxlIGVmZmVjdHMgb2YgdGhpcyBidWc/



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
