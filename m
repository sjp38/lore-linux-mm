Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 327866B02F6
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 08:23:53 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so182638608ioi.2
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 05:23:53 -0700 (PDT)
Received: from COL004-OMC1S6.hotmail.com (col004-omc1s6.hotmail.com. [65.55.34.16])
        by mx.google.com with ESMTPS id e41si17767212ioi.126.2015.10.05.05.23.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 05 Oct 2015 05:23:52 -0700 (PDT)
Message-ID: <COL130-W277AB820846A550742188BB9480@phx.gbl>
From: Chen Gang <xili_gchen_5257@hotmail.com>
Subject: RE: [PATCH] mm/mmap.c: Remove redundant vma looping
Date: Mon, 5 Oct 2015 20:23:51 +0800
In-Reply-To: <20151004172645.GO19466@redhat.com>
References: 
 <COL130-W38E921DBAB9CFCFCC45F73B94A0@phx.gbl>,<CAFLxGvyFeyV+kNoD5+4jzfid5dgkZP0uhhQ7Q7Dk-ObDJq4ByA@mail.gmail.com>,<BLU436-SMTP233624CAE8A4C054B5DFFF8B9490@phx.gbl>,<20151004172645.GO19466@redhat.com>
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "aarcange@redhat.com" <aarcange@redhat.com>
Cc: Richard Weinberger <richard.weinberger@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, "oleg@redhat.com" <oleg@redhat.com>, "asha.levin@oracle.com" <asha.levin@oracle.com>, "pfeiner@google.com" <pfeiner@google.com>, "vishnu.ps@samsung.com" <vishnu.ps@samsung.com>, Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>

PiBGcm9tOiBhYXJjYW5nZUByZWRoYXQuY29tCj4KPiBIZWxsbyBDaGVuLAo+Cj4gT24gU3VuLCBP
Y3QgMDQsIDIwMTUgYXQgMTI6NTU6MjlQTSArMDgwMCwgQ2hlbiBHYW5nIHdyb3RlOgo+PiBUaGVv
cmV0aWNhbGx5LCB0aGUgbG9jayBhbmQgdW5sb2NrIG5lZWQgdG8gYmUgc3ltbWV0cmljLCBpZiB3
ZSBoYXZlIHRvCj4+IGxvY2sgZl9tYXBwaW5nIGFsbCBmaXJzdGx5LCB0aGVuIGxvY2sgYWxsIGFu
b25fdm1hLCBwcm9iYWJseSwgd2UgYWxzbwo+PiBuZWVkIHRvIHVubG9jayBhbm9uX3ZtYSBhbGws
IHRoZW4gdW5sb2NrIGFsbCBmX21hcHBpbmcuCj4KPiBUaGV5IGRvbid0IG5lZWQgdG8gYmUgc3lt
bWV0cmljIGJlY2F1c2UgdGhlIHVubG9ja2luZyBvcmRlciBkb2Vzbid0Cj4gbWF0dGVyLiBUbyBh
dm9pZCBsb2NrIGludmVyc2lvbiBkZWFkbG9ja3MgaXQgaXMgZW5vdWdoIHRvIGVuZm9yY2UgdGhl
Cj4gbG9jayBvcmRlci4KCk9LLCB0aGFua3MuIEkgc2hhbGwgY29udGludWUgdG8gZmluZCBhbm90
aGVyIHBhdGNoZXMuIDotKQoKLS0KQ2hlbiBHYW5nCgpPcGVuLCBzaGFyZSwgYW5kIGF0dGl0dWRl
IGxpa2UgYWlyLCB3YXRlciwgYW5kIGxpZmUgd2hpY2ggR29kIGJsZXNzZWQKIAkJIAkgICAJCSAg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
