Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 720D56B0003
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 18:01:57 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id 29so13515000qto.10
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 15:01:57 -0700 (PDT)
Received: from smtp-fw-6001.amazon.com (smtp-fw-6001.amazon.com. [52.95.48.154])
        by mx.google.com with ESMTPS id a57si2180044qta.315.2018.03.12.15.01.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Mar 2018 15:01:56 -0700 (PDT)
From: "Besogonov, Aleksei" <cyberax@amazon.com>
Subject: Re: fallocate on XFS for swap
Date: Mon, 12 Mar 2018 22:01:54 +0000
Message-ID: <A59B9E63-29A2-4C40-960B-E09809DE501F@amazon.com>
References: <8C28C1CB-47F1-48D1-85C9-5373D29EA13E@amazon.com>
 <20180309234422.GA4860@magnolia> <20180310005850.GW18129@dastard>
 <20180310011707.GA4875@magnolia> <20180310013646.GX18129@dastard>
In-Reply-To: <20180310013646.GX18129@dastard>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <B59FA8D4D21F7249A44E5111592E9D71@amazon.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, xfs <linux-xfs@vger.kernel.org>

W3NuaXAgdW5yZWxhdGVkXQ0KDQpTbyBJJ20gbG9va2luZyBhdCB0aGUgWEZTIGNvZGUgYW5kIGl0
IGFwcGVhcnMgdGhhdCB0aGUgaW9tYXAgaXMgbGltaXRlZCB0byAxMDI0KlBBR0VfU0laRSBibG9j
a3MgYXQgYSB0aW1lLCB3aGljaCBpcyB0b28gc21hbGwgZm9yIG1vc3Qgb2Ygc3dhcCB1c2UtY2Fz
ZXMuIEkgY2FuIG9mIGNvdXJzZSBqdXN0IGxvb3AgdGhyb3VnaCB0aGUgZmlsZSBpbiA0TWIgaW5j
cmVtZW50cyBhbmQsIGp1c3QgbGlrZSB0aGUgYm1hcCgpIGNvZGUgZG9lcyB0b2RheS4gQnV0IHRo
aXMganVzdCBkb2Vzbid0IGxvb2sgcmlnaHQgYW5kIGl0J3Mgbm90IGF0b21pYy4gQW5kIGl0IGxv
b2tzIGxpa2UgaW9tYXAgaW4gZXh0MiBkb2Vzbid0IGhhdmUgdGhpcyBsaW1pdGF0aW9uLiANCg0K
VGhlIHN0YXRlZCByYXRpb25hbGUgZm9yIHRoZSBYRlMgbGltaXQgaXM6DQo+LyoNCj4gKiBXZSBj
YXAgdGhlIG1heGltdW0gbGVuZ3RoIHdlIG1hcCBoZXJlIHRvIE1BWF9XUklURUJBQ0tfUEFHRVMg
cGFnZXMNCj4gKiB0byBrZWVwIHRoZSBjaHVua3Mgb2Ygd29yayBkb25lIHdoZXJlIHNvbWV3aGF0
IHN5bW1ldHJpYyB3aXRoIHRoZQ0KPiAqIHdvcmsgd3JpdGViYWNrIGRvZXMuIFRoaXMgaXMgYSBj
b21wbGV0ZWx5IGFyYml0cmFyeSBudW1iZXIgcHVsbGVkDQo+ICogb3V0IG9mIHRoaW4gYWlyIGFz
IGEgYmVzdCBndWVzcyBmb3IgaW5pdGlhbCB0ZXN0aW5nLg0KPiAqDQo+ICogTm90ZSB0aGF0IHRo
ZSB2YWx1ZXMgbmVlZHMgdG8gYmUgbGVzcyB0aGFuIDMyLWJpdHMgd2lkZSB1bnRpbA0KPiAqIHRo
ZSBsb3dlciBsZXZlbCBmdW5jdGlvbnMgYXJlIHVwZGF0ZWQuDQo+ICovDQoNClNvIGNhbiBpdCBi
ZSBsaWZ0ZWQgdG9kYXk/DQoNCg==
