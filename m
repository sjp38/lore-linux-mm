Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id C892D6B0253
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 17:58:06 -0400 (EDT)
Received: by padfo6 with SMTP id fo6so2650476pad.3
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 14:58:06 -0700 (PDT)
Received: from COL004-OMC1S15.hotmail.com (col004-omc1s15.hotmail.com. [65.55.34.25])
        by mx.google.com with ESMTPS id ha3si12103241pac.129.2015.08.24.14.58.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Aug 2015 14:58:05 -0700 (PDT)
Message-ID: <COL130-W465CD26C1EF1D52CAD2FB4B9620@phx.gbl>
From: Chen Gang <xili_gchen_5257@hotmail.com>
Subject: Re: [PATCH] mm: mmap: Check all failures before set values
Date: Tue, 25 Aug 2015 05:58:05 +0800
In-Reply-To: <55DB93B2.9010705@hotmail.com>
References: <1440349179-18304-1-git-send-email-gang.chen.5i5j@qq.com>
	<20150824113212.GL17078@dhcp22.suse.cz>
 <20150824142555.76d9cf840dcbf8bbd9489b8c@linux-foundation.org>,<55DB93B2.9010705@hotmail.com>
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "gang.chen.5i5j@gmail.com" <gang.chen.5i5j@gmail.com>, Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>

T24gOC8yNS8xNSAwNToyNSwgQW5kcmV3IE1vcnRvbiB3cm90ZToKPiBPbiBNb24sIDI0IEF1ZyAy
MDE1IDEzOjMyOjEzICswMjAwIE1pY2hhbCBIb2NrbyA8bWhvY2tvQGtlcm5lbC5vcmc+IHdyb3Rl
Ogo+Cj4+IE9uIE1vbiAyNC0wOC0xNSAwMDo1OTozOSwgZ2FuZy5jaGVuLjVpNWpAcXEuY29tIHdy
b3RlOgo+Pj4gRnJvbTogQ2hlbiBHYW5nIDxnYW5nLmNoZW4uNWk1akBnbWFpbC5jb20+Cj4+Pgo+
Pj4gV2hlbiBmYWlsdXJlIG9jY3VycyBhbmQgcmV0dXJuLCB2bWEtPnZtX3Bnb2ZmIGlzIGFscmVh
ZHkgc2V0LCB3aGljaCBpcwo+Pj4gbm90IGEgZ29vZCBpZGVhLgo+Pgo+PiBXaHk/IFRoZSB2bWEg
aXMgbm90IGluc2VydGVkIGFueXdoZXJlIGFuZCB0aGUgZmFpbHVyZSBwYXRoIGlzIHN1cHBvc2Vk
Cj4+IHRvIHNpbXBseSBmcmVlIHRoZSB2bWEuCj4KPiBZZXMsIGl0J3MgcHJldHR5IG1hcmdpbmFs
IGJ1dCBJIHN1cHBvc2UgdGhlIGNvZGUgaXMgYSBiaXQgYmV0dGVyIHdpdGgKPiB0aGUgcGF0Y2gg
dGhhbiB3aXRob3V0LiBJIGRpZCB0aGlzOgo+CgpPSywgdGhhbmtzLiBUaGUgY29tbWVudHMgcmVh
bGx5IG5lZWQgdG8gYmUgaW1wcm92ZWQsIGp1c3QgbGlrZSBNaWNoYWwKSG9ja28gc2FpZCBiZWZv
cmUuCgoKVGhhbmtzLgotLQpDaGVuIEdhbmcKCk9wZW4sIHNoYXJlLCBhbmQgYXR0aXR1ZGUgbGlr
ZSBhaXIsIHdhdGVyLCBhbmQgbGlmZSB3aGljaCBHb2QgYmxlc3NlZAogCQkgCSAgIAkJICA=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
