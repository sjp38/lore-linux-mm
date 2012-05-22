Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 542A96B0083
	for <linux-mm@kvack.org>; Tue, 22 May 2012 12:19:48 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so14957930obb.14
        for <linux-mm@kvack.org>; Tue, 22 May 2012 09:19:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120518161930.978054128@linux.com>
References: <20120518161906.207356777@linux.com>
	<20120518161930.978054128@linux.com>
Date: Wed, 23 May 2012 01:19:47 +0900
Message-ID: <CAAmzW4Nt0S-xmwmHhw0AJEikE91pZpnCS+NQosrxAaUDi59pew@mail.gmail.com>
Subject: Re: [RFC] Common code 07/12] slabs: Move kmem_cache_create mutex
 handling to common code
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Alex Shi <alex.shi@intel.com>

MjAxMi81LzE5IENocmlzdG9waCBMYW1ldGVyIDxjbEBsaW51eC5jb20+Ogo+IE1vdmUgdGhlIG11
dGV4IGhhbmRsaW5nIGludG8gdGhlIGNvbW1vbiBrbWVtX2NhY2hlX2NyZWF0ZSgpCj4gZnVuY3Rp
b24uCj4KPiCgIKAgoCCgIKAgoCCgIKAgoCCgIKAgoGxpc3RfYWRkKCZzLT5saXN0LCAmc2xhYl9j
YWNoZXMpOwo+IKAgoCCgIKAgoCCgIKAgoCCgIKAgoCCgbXV0ZXhfdW5sb2NrKCZzbGFiX211dGV4
KTsKPiAtIKAgoCCgIKAgoCCgIKAgoCCgIKAgoCBpZiAoc3lzZnNfc2xhYl9hZGQocykpIHsKPiAt
IKAgoCCgIKAgoCCgIKAgoCCgIKAgoCCgIKAgoCCgIG11dGV4X2xvY2soJnNsYWJfbXV0ZXgpOwo+
IC0goCCgIKAgoCCgIKAgoCCgIKAgoCCgIKAgoCCgIKAgbGlzdF9kZWwoJnMtPmxpc3QpOwo+IC0g
oCCgIKAgoCCgIKAgoCCgIKAgoCCgIKAgoCCgIKAga2ZyZWUobik7Cj4gLSCgIKAgoCCgIKAgoCCg
IKAgoCCgIKAgoCCgIKAgoCBrZnJlZShzKTsKPiAtIKAgoCCgIKAgoCCgIKAgoCCgIKAgoCCgIKAg
oCCgIGdvdG8gZXJyOwo+IC0goCCgIKAgoCCgIKAgoCCgIKAgoCCgIH0KPiAtIKAgoCCgIKAgoCCg
IKAgoCCgIKAgoCByZXR1cm4gczsKPiArIKAgoCCgIKAgoCCgIKAgoCCgIKAgoCByID0gc3lzZnNf
c2xhYl9hZGQocyk7Cj4gKyCgIKAgoCCgIKAgoCCgIKAgoCCgIKAgbXV0ZXhfbG9jaygmc2xhYl9t
dXRleCk7Cj4gKwo+ICsgoCCgIKAgoCCgIKAgoCCgIKAgoCCgIGlmICghcikKPiArIKAgoCCgIKAg
oCCgIKAgoCCgIKAgoCCgIKAgoCCgIHJldHVybiBzOwo+ICsKPiArIKAgoCCgIKAgoCCgIKAgoCCg
IKAgoCBsaXN0X2RlbCgmcy0+bGlzdCk7Cj4gKyCgIKAgoCCgIKAgoCCgIKAgoCCgIKAga21lbV9j
YWNoZV9jbG9zZShzKTsKPiCgIKAgoCCgIKAgoCCgIKB9Cj4gLSCgIKAgoCCgIKAgoCCgIGtmcmVl
KG4pOwo+IKAgoCCgIKAgoCCgIKAgoGtmcmVlKHMpOwo+IKAgoCCgIKB9CgpCZWZvcmUgdGhpcyBw
YXRjaCBpcyBhcHBsaWVkLCBjYW4gd2UgbW92ZSBjYWxsaW5nICdzeXNmc19zbGFiX2FkZCcgdG8K
Y29tbW9uIGNvZGUKZm9yIHJlbW92aW5nIHNsYWJfbXV0ZXggZW50aXJlbHkgaW4ga21lbV9jYWNo
ZV9jcmVhdGU/Cg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
