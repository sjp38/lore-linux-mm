Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 913B76B00FA
	for <linux-mm@kvack.org>; Wed, 20 May 2015 03:18:49 -0400 (EDT)
Received: by obfe9 with SMTP id e9so30259251obf.1
        for <linux-mm@kvack.org>; Wed, 20 May 2015 00:18:49 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id m130si10117008oia.131.2015.05.20.00.18.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 20 May 2015 00:18:48 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/2] trace, ras: move ras_event.h under
 include/trace/events
Date: Wed, 20 May 2015 07:16:25 +0000
Message-ID: <20150520071625.GF27005@hori1.linux.bs1.fc.nec.co.jp>
References: <20150518185226.23154d47@canb.auug.org.au>
 <555A0327.9060709@infradead.org>
 <20150519024933.GA1614@hori1.linux.bs1.fc.nec.co.jp>
 <20150519094636.67c9a4a3@gandalf.local.home>
 <20150520053614.GA6236@hori1.linux.bs1.fc.nec.co.jp>
 <20150520060119.GB27005@hori1.linux.bs1.fc.nec.co.jp>
 <20150520060336.GC27005@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20150520060336.GC27005@hori1.linux.bs1.fc.nec.co.jp>
Content-Language: ja-JP
Content-Type: text/plain; charset="utf-8"
Content-ID: <A39D0BAE64F1BF479625D9C33295B8B7@gisp.nec.co.jp>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Randy Dunlap <rdunlap@infradead.org>, Stephen Rothwell <sfr@canb.auug.org.au>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Jim Davis <jim.epost@gmail.com>, Chen Gong <gong.chen@linux.intel.com>

T24gV2VkLCBNYXkgMjAsIDIwMTUgYXQgMDY6MDM6MzdBTSArMDAwMCwgSG9yaWd1Y2hpIE5hb3lh
KOWggOWPoyDnm7TkuZ8pIHdyb3RlOg0KPiBNb3N0IG9mIGhlYWRlciBmaWxlcyBmb3IgdHJhY2Vw
b2ludHMgYXJlIGxvY2F0ZWQgdG8gaW5jbHVkZS90cmFjZS9ldmVudHMgb3INCj4gdGhlaXIgcmVs
ZXZhbnQgc3ViZGlyZWN0b3JpZXMgdW5kZXIgZHJpdmVycy8uIE9uZSBleGNlcHRpb24gaXMNCj4g
aW5jbHVkZS9yYXMvcmFzX2V2ZW50cy5oLCB3aGljaCBsb29rcyBpbmNvbnNpc3RlbnQuIFNvIGxl
dCdzIG1vdmUgaXQgdG8gdGhlDQo+IGRlZmF1bHQgcGxhY2VzIGZvciBzdWNoIGhlYWRlcnMuDQo+
IA0KPiBTaWduZWQtb2ZmLWJ5OiBOYW95YSBIb3JpZ3VjaGkgPG4taG9yaWd1Y2hpQGFoLmpwLm5l
Yy5jb20+DQoNClNvcnJ5IHRoaXMgZG9lc24ndCBidWlsZCwgSSBzaG91bGQndmUgdGVzdGVkIGNh
cmVmdWxseS4NCkknbGwgcG9zdCBhZ2FpbiBsYXRlciwgc28gcGxlYXNlIGlnbm9yZSB0aGlzLg0K
DQpUaGFua3MsDQpOYW95YSBIb3JpZ3VjaGk=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
