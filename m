Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3A2986B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 09:39:30 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id 101so3410735ioj.6
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 06:39:30 -0700 (PDT)
Received: from us-smtp-delivery-194.mimecast.com (us-smtp-delivery-194.mimecast.com. [63.128.21.194])
        by mx.google.com with ESMTPS id 20si1019854itk.76.2017.10.05.06.39.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 05 Oct 2017 06:39:29 -0700 (PDT)
From: Trond Myklebust <trondmy@primarydata.com>
Subject: Re: Why is NFS using a_ops->freepage?
Date: Thu, 5 Oct 2017 13:39:23 +0000
Message-ID: <1507210761.20822.2.camel@primarydata.com>
References: <20171005083657.GA28132@quack2.suse.cz>
In-Reply-To: <20171005083657.GA28132@quack2.suse.cz>
Content-Language: en-US
Content-ID: <AEB8CBF803D3924C9654E071B6AFB516@namprd11.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "jack@suse.cz" <jack@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Cc: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>

SGkgSmFuLA0KDQpPbiBUaHUsIDIwMTctMTAtMDUgYXQgMTA6MzYgKzAyMDAsIEphbiBLYXJhIHdy
b3RlOg0KPiBIZWxsbywNCj4gDQo+IEknbSBkb2luZyBzb21lIHdvcmsgaW4gcGFnZSBjYWNoZSBo
YW5kbGluZyBhbmQgSSBoYXZlIG5vdGljZWQgdGhhdA0KPiBORlMgaXMNCj4gdGhlIG9ubHkgdXNl
ciBvZiBtYXBwaW5nLT5hX29wcy0+ZnJlZXBhZ2UgY2FsbGJhY2suIEZyb20gYSBxdWljayBsb29r
DQo+IEkNCj4gZG9uJ3Qgc2VlIHdoeSBpc24ndCBORlMgdXNpbmcgLT5yZWxlYXNlcGFnZSAvIC0+
aW52YWxpZGF0ZXBhZ2UNCj4gY2FsbGJhY2sgYXMNCj4gYWxsIG90aGVyIGZpbGVzeXN0ZW1zIGRv
PyBJIGFncmVlIHlvdSB3b3VsZCBoYXZlIHRvIHNldCBQYWdlUHJpdmF0ZQ0KPiBiaXQgZm9yDQo+
IHRob3NlIHRvIGdldCBjYWxsZWQgZm9yIHRoZSBkaXJlY3RvcnkgbWFwcGluZyBob3dldmVyIHRo
YXQgd291bGQgc2VlbQ0KPiBsaWtlDQo+IGEgY2xlYW5lciB0aGluZyB0byBkbyBhbnl3YXkgLSBp
biBmYWN0IHlvdSBkbyBoYXZlIHByaXZhdGUgZGF0YSBpbg0KPiB0aGUNCj4gcGFnZS4gIEp1c3Qg
dGhleSBhcmUgbm90IHBvaW50ZWQgdG8gYnkgcGFnZS0+cHJpdmF0ZSBidXQgaW5zdGVhZCBhcmUN
Cj4gc3RvcmVkDQo+IGFzIHBhZ2UgZGF0YS4uLiBBbSBJIG1pc3Npbmcgc29tZXRoaW5nPw0KPiAN
Cj4gCQkJCQkJCQlIb256YQ0KDQpJJ20gbm90IHVuZGVyc3RhbmRpbmcgeW91ciBwb2ludC4gZGVs
ZXRlX2Zyb21fcGFnZV9jYWNoZSgpIGRvZXNuJ3QgY2FsbA0KcmVsZWFzZXBhZ2UgQUZBSUNTLg0K
DQpUaGUgcG9pbnQgb2YgZnJlZXBhZ2UgaXMgdGhhdCBpdCBpcyBjYWxsZWQgYWZ0ZXIgdGhlIHBh
Z2UgaGFzIGJlZW4NCnJlbW92ZWQgZnJvbSB0aGUgcGFnZSBjYWNoZS4NCg0KLS0gDQpUcm9uZCBN
eWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgUHJpbWFyeURhdGENCnRyb25k
Lm15a2xlYnVzdEBwcmltYXJ5ZGF0YS5jb20NCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
