Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id B8E626B0032
	for <linux-mm@kvack.org>; Wed,  8 Apr 2015 21:27:06 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so132456450pab.3
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 18:27:06 -0700 (PDT)
Received: from COL004-OMC1S1.hotmail.com (col004-omc1s1.hotmail.com. [65.55.34.11])
        by mx.google.com with ESMTPS id bc10si13703429pdb.81.2015.04.08.18.27.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 08 Apr 2015 18:27:05 -0700 (PDT)
Message-ID: <COL130-W8D1CC218459D807A6644EBAFB0@phx.gbl>
From: ZhangNeil <neilzhang1123@hotmail.com>
Subject: RE: [PATCH] mm: show free pages per each migrate type
Date: Thu, 9 Apr 2015 01:27:05 +0000
In-Reply-To: <20150408152011.03d5f94cce0c5ac327bd87c4@linux-foundation.org>
References: 
 <BLU436-SMTP2455A39CB8EF56CED4137DDBAFC0@phx.gbl>,<20150408152011.03d5f94cce0c5ac327bd87c4@linux-foundation.org>
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

T0ssIEkgd2lsbCBwcmVwYXJlIHZlcnNpb24gMiB0byBpbmNsdWRlIHRoZSBkaWZmZXJlbmNlLgoK
QmVzdCBSZWdhcmRzLApOZWlsIFpoYW5nCgotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tCj4gRGF0ZTogV2VkLCA4IEFwciAyMDE1IDE1OjIwOjExIC0wNzAwCj4gRnJvbTog
YWtwbUBsaW51eC1mb3VuZGF0aW9uLm9yZwo+IFRvOiBuZWlsemhhbmcxMTIzQGhvdG1haWwuY29t
Cj4gQ0M6IGxpbnV4LW1tQGt2YWNrLm9yZzsgbGludXgta2VybmVsQHZnZXIua2VybmVsLm9yZwo+
IFN1YmplY3Q6IFJlOiBbUEFUQ0hdIG1tOiBzaG93IGZyZWUgcGFnZXMgcGVyIGVhY2ggbWlncmF0
ZSB0eXBlCj4KPiBPbiBXZWQsIDggQXByIDIwMTUgMDk6NDg6MDYgKzA4MDAgTmVpbCBaaGFuZyA8
bmVpbHpoYW5nMTEyM0Bob3RtYWlsLmNvbT4gd3JvdGU6Cj4KPj4gc2hvdyBkZXRhaWxlZCBmcmVl
IHBhZ2VzIHBlciBlYWNoIG1pZ3JhdGUgdHlwZSBpbiBzaG93X2ZyZWVfYXJlYXMuCj4+Cj4KPiBJ
dCB3b3VsZCBiZSBnb29kIHRvIGluY2x1ZGUgZXhhbXBsZSBiZWZvcmUgYW5kIGFmdGVyIG91dHB1
dCB3aXRoaW4gdGhlCj4gY2hhbmdlbG9nLCBzbyB0aGF0IHBlb3BsZSBjYW4gYmV0dGVyIHVuZGVy
c3RhbmQgdGhlIGVmZmVjdCBhbmQgdmFsdWUgb2YKPiB0aGUgcHJvcG9zZWQgY2hhbmdlLgo+Cj4g
VGhhbmtzLgogCQkgCSAgIAkJICA=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
