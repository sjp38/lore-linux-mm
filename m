Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 174B9280725
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 15:55:42 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id d12so267674616pgt.8
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 12:55:42 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id z95si5255233plh.865.2017.08.22.12.55.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Aug 2017 12:55:41 -0700 (PDT)
From: "Liang, Kan" <kan.liang@intel.com>
Subject: RE: [PATCH 1/2] sched/wait: Break up long wake list walk
Date: Tue, 22 Aug 2017 19:55:37 +0000
Message-ID: <37D7C6CF3E00A74B8858931C1DB2F0775378A377@SHSMSX103.ccr.corp.intel.com>
References: <CA+55aFwzTMrZwh7TE_VeZt8gx5Syoop-kA=Xqs56=FkyakrM6g@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378761B@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy_RNx5TQ8esjPPOKuW-o+fXbZgWapau2MHyexcAZtqsw@mail.gmail.com>
 <20170818122339.24grcbzyhnzmr4qw@techsingularity.net>
 <37D7C6CF3E00A74B8858931C1DB2F077537879BB@SHSMSX103.ccr.corp.intel.com>
 <20170818144622.oabozle26hasg5yo@techsingularity.net>
 <37D7C6CF3E00A74B8858931C1DB2F07753787AE4@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFxZjjqUM4kPvNEeZahPovBHFATiwADj-iPTDN0-jnU67Q@mail.gmail.com>
 <20170818185455.qol3st2nynfa47yc@techsingularity.net>
 <CA+55aFwX0yrUPULrDxTWVCg5c6DKh-yCG84NXVxaptXNQ4O_kA@mail.gmail.com>
 <20170821183234.kzennaaw2zt2rbwz@techsingularity.net>
 <37D7C6CF3E00A74B8858931C1DB2F07753788B58@SHSMSX103.ccr.corp.intel.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A24A@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy=4y0fq9nL2WR1x8vwzJrDOdv++r036LXpR=6Jx8jpzg@mail.gmail.com>
In-Reply-To: <CA+55aFy=4y0fq9nL2WR1x8vwzJrDOdv++r036LXpR=6Jx8jpzg@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo
 Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

IA0KPiBTbyBJIHByb3Bvc2UgdGVzdGluZyB0aGUgYXR0YWNoZWQgdHJpdmlhbCBwYXRjaC4gDQoN
Ckl0IGRvZXNu4oCZdCB3b3JrLiANClRoZSBjYWxsIHN0YWNrIGlzIHRoZSBzYW1lLg0KDQogICAx
MDAuMDAlICAoZmZmZmZmZmY4MjFhZjE0MCkNCiAgICAgICAgICAgIHwNCiAgICAgICAgICAgIC0t
LXdhaXRfb25fcGFnZV9iaXQNCiAgICAgICAgICAgICAgIF9fbWlncmF0aW9uX2VudHJ5X3dhaXQN
CiAgICAgICAgICAgICAgIG1pZ3JhdGlvbl9lbnRyeV93YWl0DQogICAgICAgICAgICAgICBkb19z
d2FwX3BhZ2UNCiAgICAgICAgICAgICAgIF9faGFuZGxlX21tX2ZhdWx0DQogICAgICAgICAgICAg
ICBoYW5kbGVfbW1fZmF1bHQNCiAgICAgICAgICAgICAgIF9fZG9fcGFnZV9mYXVsdA0KICAgICAg
ICAgICAgICAgZG9fcGFnZV9mYXVsdA0KICAgICAgICAgICAgICAgcGFnZV9mYXVsdA0KICAgICAg
ICAgICAgICAgfA0KICAgICAgICAgICAgICAgfC0tNDAuNjIlLS0weDEyM2EyDQogICAgICAgICAg
ICAgICB8ICAgICAgICAgIHN0YXJ0X3RocmVhZA0KICAgICAgICAgICAgICAgfA0KDQoNCj4gSXQg
bWF5IG5vdCBkbyBhbnl0aGluZyBhdCBhbGwuDQo+IEJ1dCB0aGUgZXhpc3RpbmcgY29kZSBpcyBh
Y3R1YWxseSBkb2luZyBleHRyYSB3b3JrIGp1c3QgdG8gYmUgZnJhZ2lsZSwgaW4gY2FzZSB0aGUN
Cj4gc2NlbmFyaW8gYWJvdmUgY2FuIGhhcHBlbi4NCj4gDQo+IENvbW1lbnRzPw0KPiANCj4gICAg
ICAgICAgICAgICAgIExpbnVzDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
