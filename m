Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2FECE6B02F4
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 15:12:54 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m5so152248117pgn.1
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 12:12:54 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id c17si10957467pfh.184.2017.06.20.12.12.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 12:12:53 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: Re: [PATCH 0/4] percpu: add basic stats and tracepoints to percpu
 allocator
Date: Tue, 20 Jun 2017 19:12:49 +0000
Message-ID: <F1DDF17A-B2CE-4EAF-8B6B-1AC4C73451DC@fb.com>
References: <20170619232832.27116-1-dennisz@fb.com>
 <20170620174521.GD21326@htj.duckdns.org>
In-Reply-To: <20170620174521.GD21326@htj.duckdns.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <C83432E33D6A7D44BABE1B7F1047A553@namprd15.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>

T24gNi8yMC8xNywgMTo0NSBQTSwgIlRlanVuIEhlbyIgPGh0ZWp1bkBnbWFpbC5jb20gb24gYmVo
YWxmIG9mIHRqQGtlcm5lbC5vcmc+IHdyb3RlOg0KPiBBcHBsaWVkIHRvIHBlcmNwdS9mb3ItNC4x
My4gIEkgaGFkIHRvIHVwZGF0ZSAwMDAyIGJlY2F1c2Ugb2YgdGhlDQo+IHJlY2VudCBfX3JvX2Fm
dGVyX2luaXQgY2hhbmdlcy4gIENhbiB5b3UgcGxlYXNlIHNlZSB3aGV0aGVyIEkgbWFkZSBhbnkN
Cj4gbWlzdGFrZXMgd2hpbGUgdXBkYXRpbmcgaXQ/DQoNClRoZXJlIGlzIGEgdGFnZ2luZyBtaXNt
YXRjaCBpbiAwMDAyLiBDYW4geW91IHBsZWFzZSBjaGFuZ2Ugb3IgcmVtb3ZlIHRoZSBfX3JlYWRf
bW9zdGx5IGFubm90YXRpb24gaW4gbW0vcGVyY3B1LWludGVybmFsLmg/DQoNClRoYW5rcywNCkRl
bm5pcw0KDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
