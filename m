Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 9115B6B006E
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 01:44:30 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id w10so2788769pde.26
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 22:44:30 -0700 (PDT)
Received: from manager.mioffice.cn ([42.62.48.242])
        by mx.google.com with ESMTP id p1si13236941pdp.169.2014.10.21.22.44.27
        for <linux-mm@kvack.org>;
        Tue, 21 Oct 2014 22:44:29 -0700 (PDT)
From: =?gb2312?B?1uy71A==?= <zhuhui@xiaomi.com>
Subject: Re: [PATCH 1/4] (CMA_AGGRESSIVE) Add CMA_AGGRESSIVE to Kconfig
Date: Wed, 22 Oct 2014 05:44:24 +0000
Message-ID: <2c27ad87839b42ca85c03c9541550d30@cnbox4.mioffice.cn>
References: <1413430551-22392-1-git-send-email-zhuhui@xiaomi.com>
 <1413430551-22392-2-git-send-email-zhuhui@xiaomi.com>
 <201410220126.s9M1Qita026502@spam.xiaomi.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@denx.de>
Cc: "rjw@rjwysocki.net" <rjw@rjwysocki.net>, "len.brown@intel.com" <len.brown@intel.com>, "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mina86@mina86.com" <mina86@mina86.com>, "aneesh.kumar@linux.vnet.ibm.com" <aneesh.kumar@linux.vnet.ibm.com>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, "mgorman@suse.de" <mgorman@suse.de>, "minchan@kernel.org" <minchan@kernel.org>, "nasa4836@gmail.com" <nasa4836@gmail.com>, "ddstreet@ieee.org" <ddstreet@ieee.org>, "hughd@google.com" <hughd@google.com>, "mingo@kernel.org" <mingo@kernel.org>, "rientjes@google.com" <rientjes@google.com>, "peterz@infradead.org" <peterz@infradead.org>, "keescook@chromium.org" <keescook@chromium.org>, "atomlin@redhat.com" <atomlin@redhat.com>, "raistlin@linux.it" <raistlin@linux.it>, "axboe@fb.com" <axboe@fb.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, "k.khlebnikov@samsung.com" <k.khlebnikov@samsung.com>, "msalter@redhat.com" <msalter@redhat.com>, "deller@gmx.de" <deller@gmx.de>, "tangchen@cn.fujitsu.com" <tangchen@cn.fujitsu.com>, "ben@decadent.org.uk" <ben@decadent.org.uk>, "akinobu.mita@gmail.com" <akinobu.mita@gmail.com>, "lauraa@codeaurora.org" <lauraa@codeaurora.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "vdavydov@parallels.com" <vdavydov@parallels.com>, "suleiman@google.com" <suleiman@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

CgpPbiAxMC8yMi8xNCAwOToyNywgUGF2ZWwgTWFjaGVrIHdyb3RlOgo+IEhpIQo+Cj4+IEFkZCBD
TUFfQUdHUkVTU0lWRSBjb25maWcgdGhhdCBkZXBlbmQgb24gQ01BIHRvIExpbnV4IGtlcm5lbCBj
b25maWcuCj4+IEFkZCBDTUFfQUdHUkVTU0lWRV9QSFlfTUFYLCBDTUFfQUdHUkVTU0lWRV9GUkVF
X01JTiBhbmQgQ01BX0FHR1JFU1NJVkVfU0hSSU5LCj4+IHRoYXQgZGVwZW5kIG9uIENNQV9BR0dS
RVNTSVZFLgo+Pgo+PiBJZiBwaHlzaWNhbCBtZW1vcnkgc2l6ZSAobm90IGluY2x1ZGUgQ01BIG1l
bW9yeSkgaW4gYnl0ZSBsZXNzIHRoYW4gb3IgZXF1YWwgdG8KPj4gQ01BX0FHR1JFU1NJVkVfUEhZ
X01BWCwgQ01BIGFnZ3Jlc3NpdmUgc3dpdGNoIChzeXNjdGwgdm0uY21hLWFnZ3Jlc3NpdmUtc3dp
dGNoKQo+PiB3aWxsIGJlIG9wZW5lZC4KPgo+IE9rLi4uCj4KPiBEbyBJIHVuZGVyc3RhbmQgaXQg
Y29ycmVjdGx5IHRoYXQgdGhlcmUgaXMgc29tZSBwcm9ibGVtIHdpdGgKPiBoaWJlcm5hdGlvbiBu
b3Qgd29ya2luZyBvbiBtYWNoaW5lcyBub3Qgd29ya2luZyBvbiBtYWNoaW5lcyB3aXRoIGJpZwo+
IENNQSBhcmVhcy4uLj8KCk5vLCB0aGVzZSBwYXRjaGVzIHdhbnQgdG8gaGFuZGxlIHRoaXMgaXNz
dWUgdGhhdCBtb3N0IG9mIENNQSBtZW1vcnkgaXMgCm5vdCBhbGxvY2F0ZWQgYmVmb3JlIGxvd21l
bW9yeWtpbGxlciBvciBvb21fa2lsbGVyIGJlZ2luIHRvIGtpbGwgdGFza3MuCgo+Cj4gQnV0IGFk
ZGluZyA0IGNvbmZpZyBvcHRpb25zIGVuZC11c2VyIGhhcyBubyBjaGFuY2UgdG8gc2V0IHJpZ2h0
IGNhbgo+IG5vdCBiZSB0aGUgYmVzdCBzb2x1dGlvbiwgY2FuIGl0Pwo+Cj4+ICtjb25maWcgQ01B
X0FHR1JFU1NJVkVfUEhZX01BWAo+PiArCWhleCAiUGh5c2ljYWwgbWVtb3J5IHNpemUgaW4gQnl0
ZXMgdGhhdCBhdXRvIHR1cm4gb24gdGhlIENNQSBhZ2dyZXNzaXZlIHN3aXRjaCIKPj4gKwlkZXBl
bmRzIG9uIENNQV9BR0dSRVNTSVZFCj4+ICsJZGVmYXVsdCAweDQwMDAwMDAwCj4+ICsJaGVscAo+
PiArCSAgSWYgcGh5c2ljYWwgbWVtb3J5IHNpemUgKG5vdCBpbmNsdWRlIENNQSBtZW1vcnkpIGlu
IGJ5dGUgbGVzcyB0aGFuIG9yCj4+ICsJICBlcXVhbCB0byB0aGlzIHZhbHVlLCBDTUEgYWdncmVz
c2l2ZSBzd2l0Y2ggd2lsbCBiZSBvcGVuZWQuCj4+ICsJICBBZnRlciB0aGUgTGludXggYm9vdCwg
c3lzY3RsICJ2bS5jbWEtYWdncmVzc2l2ZS1zd2l0Y2giIGNhbiBjb250cm9sCj4+ICsJICB0aGUg
Q01BIEFHR1JFU1NJVkUgc3dpdGNoLgo+Cj4gRm9yIGV4YW1wbGUuLi4gaG93IGFtIEkgZXhwZWN0
ZWQgdG8gZmlndXJlIHJpZ2h0IHZhbHVlIHRvIHBsYWNlIGhlcmU/CgpJIGFncmVlIHdpdGggdGhh
dC4gIEkgd2lsbCB1cGRhdGUgdGhpcyBjb25maWcgdG8gYXV0byBzZXQgaW4gbmV4dCB2ZXJzaW9u
LgoKVGhhbmtzLApIdWkKCj4KPiAJCQkJCQkJCQlQYXZlbAo+Cg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
