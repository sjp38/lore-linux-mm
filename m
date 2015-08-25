Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id B25196B0255
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 17:33:44 -0400 (EDT)
Received: by pabzx8 with SMTP id zx8so45553993pab.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 14:33:44 -0700 (PDT)
Received: from COL004-OMC2S12.hotmail.com (col004-omc2s12.hotmail.com. [65.55.34.86])
        by mx.google.com with ESMTPS id f4si34992828pas.118.2015.08.25.14.33.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 25 Aug 2015 14:33:43 -0700 (PDT)
Message-ID: <COL130-W94C27965E980E171892A4B9610@phx.gbl>
From: Chen Gang <xili_gchen_5257@hotmail.com>
Subject: Re: [PATCH] mm: mmap: Check all failures before set values
Date: Wed, 26 Aug 2015 05:33:42 +0800
In-Reply-To: <55DCDF7E.6080402@hotmail.com>
References: <1440349179-18304-1-git-send-email-gang.chen.5i5j@qq.com>
 <20150824113212.GL17078@dhcp22.suse.cz> <55DB1D94.3050404@hotmail.com>
 <COL130-W527FEAA0BEC780957B6B18B9620@phx.gbl>
 <20150824135716.GO17078@dhcp22.suse.cz> <55DB9278.2020603@qq.com>
 <20150825113521.GA6285@dhcp22.suse.cz>,<55DCDF7E.6080402@hotmail.com>
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Chen Gang <gang.chen.5i5j@qq.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "gang.chen.5i5j@gmail.com" <gang.chen.5i5j@gmail.com>, Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>

T24gOC8yNS8xNSAxOTozNSwgTWljaGFsIEhvY2tvIHdyb3RlOgo+Cj4gT0ssIEkgZ3Vlc3MgSSB1
bmRlcnN0YW5kIHdoYXQgeW91IG1lYW4uIFlvdSBhcmUgY2VydGFpbmx5IHJpZ2h0IHRoYXQgYQo+
IHBhcnRpYWwgaW5pdGlhbGl6YXRpb24gZm9yIHRoZSBmYWlsdXJlIGNhc2UgaXMgbm90IG5pY2Ug
aW4gZ2VuZXJhbC4gSQo+IHdhcyBqdXN0IG9iamVjdGluZyB0aGF0IHRoZSBjYWxsZXJzIGFyZSBz
dXBwb3NlZCB0byBmcmVlIHRoZSB2bWEgaW4KPiB0aGUgZmFpbHVyZSBjYXNlIHNvIGFueSBwYXJ0
aWFsIGluaXRpYWxpemF0aW9uIGRvZXNuJ3QgbWF0dGVyIGluIHRoaXMKPiBwYXJ0aWN1bGFyIGNh
c2UuCj4KPiBZb3VyIHBhdGNoIHdvdWxkIGJlIG1vcmUgc2Vuc2libGUgaWYgdGhlIGZhaWx1cmUg
Y2FzZSB3YXMgbW9yZQo+IGxpa2VseS4gQnV0IHRoaXMgZnVuY3Rpb24gaXMgdXNlZCBmb3Igc3Bl
Y2lhbCBtYXBwaW5ncyAodmRzbywgdGVtcG9yYXJ5Cj4gdmRzbyBzdGFjaykgd2hpY2ggYXJlIGNy
ZWF0ZWQgZWFybHkgaW4gdGhlIHByb2Nlc3MgbGlmZSB0aW1lIHNvIGJvdGgKPiBmYWlsdXJlIHBh
dGhzIGFyZSBoaWdobHkgdW5saWtlbHkuIElmIHRoaXMgd2FzIGEgcGFydCBvZiBhIGxhcmdlcgo+
IGNoYW5nZXMgd2hlcmUgdGhlIGZ1bmN0aW9uIHdvdWxkIGJlIHVzZWQgZWxzZXdoZXJlIEkgd291
bGRuJ3Qgb2JqZWN0IGF0Cj4gYWxsLgo+CgpPSy4KCj4gVGhlIHJlYXNvbiBJIGFtIHNrZXB0aWNh
bCBhYm91dCBzdWNoIGNoYW5nZXMgaW4gZ2VuZXJhbCBpcyB0aGF0Cj4gdGhlIGVmZmVjdCBpcyB2
ZXJ5IG1hcmdpbmFsIHdoaWxlIGl0IGluY3JlYXNlcyBjaGFuY2VzIG9mIHRoZSBjb2RlCj4gY29u
ZmxpY3RzLgo+Cj4gQnV0IGFzIEkndmUgc2FpZCwgaWYgb3RoZXJzIGZlZWwgdGhpcyBpcyB3b3J0
aHdoaWxlIEkgd2lsbCBub3Qgb2JqZWN0Lgo+CgpPSywgSSBjYW4gdW5kZXJzdGFuZC4KCgpUaGFu
a3MuCi0tCkNoZW4gR2FuZwoKT3Blbiwgc2hhcmUsIGFuZCBhdHRpdHVkZSBsaWtlIGFpciwgd2F0
ZXIsIGFuZCBsaWZlIHdoaWNoIEdvZCBibGVzc2VkCiAJCSAJICAgCQkgIA==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
