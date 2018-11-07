Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 381D26B04F9
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 06:01:04 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id z13-v6so10411328wrs.13
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 03:01:04 -0800 (PST)
Received: from eu-smtp-delivery-151.mimecast.com (eu-smtp-delivery-151.mimecast.com. [146.101.78.151])
        by mx.google.com with ESMTPS id 14-v6si632917wmp.92.2018.11.07.03.01.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 03:01:02 -0800 (PST)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v6 1/3] printk: Add line-buffered printk() API.
Date: Wed, 7 Nov 2018 11:01:05 +0000
Message-ID: <8354d714f6b6489d9003d6e04ee10618@AcuMS.aculab.com>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181106143502.GA32748@tigerII.localdomain>
 <42f33aae-a1d1-197f-a1d5-8c5ec88e88d1@i-love.sakura.ne.jp>
In-Reply-To: <42f33aae-a1d1-197f-a1d5-8c5ec88e88d1@i-love.sakura.ne.jp>
Content-Language: en-US
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Tetsuo Handa' <penguin-kernel@i-love.sakura.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

RnJvbTogVGV0c3VvIEhhbmRhDQo+IFNlbnQ6IDA3IE5vdmVtYmVyIDIwMTggMTA6NTMNCj4gDQo+
IE9uIDIwMTgvMTEvMDYgMjM6MzUsIFNlcmdleSBTZW5vemhhdHNreSB3cm90ZToNCj4gPj4gU2lu
Y2Ugd2Ugd2FudCB0byByZW1vdmUgInN0cnVjdCBjb250IiBldmVudHVhbGx5LCB3ZSB3aWxsIHRy
eSB0byByZW1vdmUNCj4gPj4gYm90aCAiaW1wbGljaXQgcHJpbnRrKCkgdXNlcnMgd2hvIGFyZSBl
eHBlY3RpbmcgS0VSTl9DT05UIGJlaGF2aW9yIiBhbmQNCj4gPj4gImV4cGxpY2l0IHByX2NvbnQo
KS9wcmludGsoS0VSTl9DT05UKSB1c2VycyIuIFRoZXJlZm9yZSwgY29udmVydGluZyB0bw0KPiA+
PiB0aGlzIEFQSSBpcyByZWNvbW1lbmRlZC4NCj4gPg0KPiA+IC0gVGhlIHByaW50ay1mYWxsYmFj
ayBzb3VuZHMgbGlrZSBhIGhpbnQgdGhhdCB0aGUgZXhpc3RpbmcgJ2NvbnQnIGhhbmRsaW5nDQo+
ID4gICBiZXR0ZXIgc3RheSBpbiB0aGUga2VybmVsLiBJIGRvbid0IHNlZSBob3cgdGhlIGV4aXN0
aW5nICdjb250JyBpcw0KPiA+ICAgc2lnbmlmaWNhbnRseSB3b3JzZSB0aGFuDQo+ID4gCQlicHJf
d2FybihOVUxMLCAuLi4pLT5wcmludGsoKSAvLyBubyAnY29udCcgc3VwcG9ydA0KPiA+ICAgSSBk
b24ndCBzZWUgd2h5IHdvdWxkIHdlIHdhbnQgdG8gZG8gaXQsIHNvcnJ5LiBJIGRvbid0IHNlZSAi
aXQgdGFrZXMgMTYNCj4gPiAgIHByaW50ay1idWZmZXJzIHRvIG1ha2UgYSB0aGluZyBnbyByaWdo
dCIgYXMgYSBzdXJlIHRoaW5nLg0KPiANCj4gRXhpc3RpbmcgJ2NvbnQnIGhhbmRsaW5nIHdpbGwg
c3RheSBmb3IgYSB3aGlsZS4gQWZ0ZXIgbWFqb3JpdHkgb2YNCj4gcHJfY29udCgpL0tFUk5fQ09O
VCB1c2VycyBhcmUgY29udmVydGVkLCAnY29udCcgc3VwcG9ydCB3aWxsIGJlIHJlbW92ZWQNCj4g
KGUuZy4gS0VSTl9DT05UIGJlY29tZXMgIiIpLg0KDQpBIHRob3VnaDoNCg0KV2h5IG5vdCBtYWtl
IHRoZSBwcmludGYgbG9jayBzbGlnaHRseSAnc3RpY2t5Jz8NCi0gSWYgdGhlIG91dHB1dCBsaW5l
IGlzIGluY29tcGxldGUgc2F2ZSB0aGUgY3B1aWQuDQotIElmIHRoZXJlIGlzIGEgc2F2ZWQgY3B1
aWQgdGhhdCBkb2Vzbid0IG1hdGNoIHRoZSBjdXJyZW50IGNwdSB0aGVuIHNwaW4gZm9yIGEgYml0
Lg0KDQpBbnkgY2FsbGVycyBvZiBwcmludGsoKSBoYXZlIHRvIGFzc3VtZSB0aGV5IHdpbGwgc3Bp
biBvbiB0aGUgYnVmZmVyIGZvciB0aGUNCmxvbmdlc3QgcHJpbnRrIGZvcm1hdHRpbmcgKGFuZCBz
eW1ib2wgbG9va3VwIG1pZ2h0IHRha2UgYSB3aGlsZSkgc28gYSBzaG9ydA0KYWRkaXRpb25hbCBk
ZWxheSB3b24ndCBtYXR0ZXIuDQoNClRoZW4gdHdvIGNhbGxzIHRvIHByaW50aygpIGZvciB0aGUg
c2FtZSBsaW5lIHdvbid0ICh1c3VhbGx5KSBnZXQgc3BsaXQgYW5kDQpub25lIG9mIHRoZSBjYWxs
ZXJzIG5lZWQgYW55IGNoYW5nZXMuDQoNCglEYXZpZA0KDQotDQpSZWdpc3RlcmVkIEFkZHJlc3Mg
TGFrZXNpZGUsIEJyYW1sZXkgUm9hZCwgTW91bnQgRmFybSwgTWlsdG9uIEtleW5lcywgTUsxIDFQ
VCwgVUsNClJlZ2lzdHJhdGlvbiBObzogMTM5NzM4NiAoV2FsZXMpDQo=
