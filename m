Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E34296B002C
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 12:35:22 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id c11so4618555wrf.4
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 09:35:22 -0700 (PDT)
Received: from smtp-out4.electric.net (smtp-out4.electric.net. [192.162.216.194])
        by mx.google.com with ESMTPS id e24si4072261edc.275.2018.03.22.09.35.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Mar 2018 09:35:21 -0700 (PDT)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [RFC PATCH 1/8] mm: mmap: unmap large mapping by section
Date: Thu, 22 Mar 2018 16:36:14 +0000
Message-ID: <fd5c7272f19442828fb00dff7cb24fae@AcuMS.aculab.com>
References: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
 <1521581486-99134-2-git-send-email-yang.shi@linux.alibaba.com>
 <20180321131449.GN23100@dhcp22.suse.cz>
 <8e0ded7b-4be4-fa25-f40c-d3116a6db4db@linux.alibaba.com>
 <cf87ade4-5a5c-3919-0fc6-acc40e12659b@linux.alibaba.com>
 <20180321212355.GR23100@dhcp22.suse.cz>
 <952dcae2-a73e-0726-3cc5-9b6a63b417b7@linux.alibaba.com>
 <20180322091008.GZ23100@dhcp22.suse.cz>
 <8b4407dd-78f6-2f6f-3f45-ddb8a2d805c8@linux.alibaba.com>
 <20180322161316.GD28468@bombadil.infradead.org>
 <e36daca9-8bf0-5fad-d68b-a3116cc1a75e@linux.vnet.ibm.com>
In-Reply-To: <e36daca9-8bf0-5fad-d68b-a3116cc1a75e@linux.vnet.ibm.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Laurent Dufour' <ldufour@linux.vnet.ibm.com>, Matthew Wilcox <willy@infradead.org>, Yang Shi <yang.shi@linux.alibaba.com>
Cc: Michal Hocko <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

RnJvbTogIExhdXJlbnQgRHVmb3VyDQo+IFNlbnQ6IDIyIE1hcmNoIDIwMTggMTY6MjkNCi4uLg0K
PiBUaGlzIGJlaW5nIHNhaWQsIGhhdmluZyBhIHBlciBWTUEgbG9jayBjb3VsZCBsZWFkIHRvIHRy
aWNreSBkZWFkIGxvY2sgY2FzZSwNCj4gd2hlbiBtZXJnaW5nIG11bHRpcGxlIFZNQSBoYXBwZW5z
IGluIHBhcmFsbGVsIHNpbmNlIG11bHRpcGxlIFZNQSB3aWxsIGhhdmUgdG8NCj4gYmUgbG9ja2Vk
IGF0IHRoZSBzYW1lIHRpbWUsIGdyYWJiaW5nIHRob3NlIGxvY2sgaW4gYSBmaW5lIG9yZGVyIHdp
bGwgYmUgcmVxdWlyZWQuDQoNCllvdSBjb3VsZCBoYXZlIGEgZ2xvYmFsIGxvY2sgYW5kIHBlciBW
TUEgbG9ja3MuDQpBbnl0aGluZyB0aGF0IG9ubHkgYWNjZXNzZXMgb25lIFZNQSBjb3VsZCByZWxl
YXNlIHRoZSBnbG9iYWwgbG9jayBhZnRlcg0KYWNxdWlyaW5nIHRoZSBwZXIgVk1BIGxvY2suDQpJ
ZiBjb2RlIG5lZWRzIG11bHRpcGxlIFZNQSAnbG9ja2VkJyBpdCBjYW4gbG9jayBhbmQgdW5sb2Nr
IGVhY2ggVk1BDQppbiB0dXJuLCB0aGVuIGtlZXAgdGhlIGdsb2JhbCBsb2NrIGhlbGQuDQoNCglE
YXZpZA0KDQo=
