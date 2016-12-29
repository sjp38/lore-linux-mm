Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 83F636B0069
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 11:08:21 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id t184so208417218qkd.2
        for <linux-mm@kvack.org>; Thu, 29 Dec 2016 08:08:21 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e1si32559281qtg.139.2016.12.29.08.08.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Dec 2016 08:08:20 -0800 (PST)
Message-ID: <1483027695.11006.97.camel@redhat.com>
Subject: Re: [PATCH] mm, page_alloc: convert page_group_by_mobility_disable
 to static key
From: Rik van Riel <riel@redhat.com>
Date: Thu, 29 Dec 2016 11:08:15 -0500
In-Reply-To: <20161220134312.17332-1-vbabka@suse.cz>
References: <20161220134312.17332-1-vbabka@suse.cz>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-PHlqDmcUK1C/XOvmXfZ0"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>


--=-PHlqDmcUK1C/XOvmXfZ0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: base64

T24gVHVlLCAyMDE2LTEyLTIwIGF0IDE0OjQzICswMTAwLCBWbGFzdGltaWwgQmFia2Egd3JvdGU6
Cj4gVGhlIGZsYWcgaXMgcmFyZWx5IGVuYWJsZWQgb3IgZXZlbiBjaGFuZ2VkLCBzbyBpdCdzIGFu
IGlkZWFsIHN0YXRpYwo+IGtleQo+IGNhbmRpZGF0ZS4gU2luY2UgaXQncyBiZWluZyBjaGVja2Vk
IGluIHRoZSBwYWdlIGFsbG9jYXRvciBmYXN0cGF0aAo+IHZpYQo+IGdmcGZsYWdzX3RvX21pZ3Jh
dGV0eXBlKCksIGl0IG1heSBhY3R1YWxseSBzYXZlIHNvbWUgdmFsdWFibGUgY3ljbGVzLgo+IAo+
IEhlcmUncyBhIGRpZmYgZXhjZXJwdCBmcm9tIF9fYWxsb2NfcGFnZXNfbm9kZW1hc2soKSBhc3Nl
bWJseToKPiAKPiDCoMKgwqDCoMKgwqDCoMKgLW1vdmzCoMKgwqDCoHBhZ2VfZ3JvdXBfYnlfbW9i
aWxpdHlfZGlzYWJsZWQoJXJpcCksICVlY3gKPiAJKy5ieXRlIDB4MGYsMHgxZiwweDQ0LDB4MDAs
MAo+IMKgwqDCoMKgwqDCoMKgwqDCoG1vdmzCoMKgwqDCoCVyOWQsICVlYXgKPiDCoMKgwqDCoMKg
wqDCoMKgwqBzaHJswqDCoMKgwqAkMywgJWVheAo+IMKgwqDCoMKgwqDCoMKgwqDCoGFuZGzCoMKg
wqDCoCQzLCAlZWF4Cj4gwqDCoMKgwqDCoMKgwqDCoC10ZXN0bMKgwqDCoCVlY3gsICVlY3gKPiDC
oMKgwqDCoMKgwqDCoMKgLW1vdmzCoMKgwqDCoCQwLCAlZWN4Cj4gwqDCoMKgwqDCoMKgwqDCoC1j
bW92bmXCoMKgJWVjeCwgJWVheAo+IAo+IEkuZS4gYSBOT1AgaW5zdGVhZCBvZiB0ZXN0LCBjb25k
aXRpb25hbCBtb3ZlIGFuZCBzb21lIGFzc2lzdGluZwo+IG1vdmVzLgo+IAo+IFNpZ25lZC1vZmYt
Ynk6IFZsYXN0aW1pbCBCYWJrYSA8dmJhYmthQHN1c2UuY3o+CgpBY2tlZC1ieTogUmlrIHZhbiBS
aWVsIDxyaWVsQHJlZGhhdC5jb20+CgotLSAKQWxsIFJpZ2h0cyBSZXZlcnNlZC4=


--=-PHlqDmcUK1C/XOvmXfZ0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJYZTTwAAoJEM553pKExN6DgdIH/RWBoappXuLM2fdNP42Qaf39
8ebjekdyVc3rqEwMCcEsyzi6YkrrZ0+kvN7lLVbDJXa6oc+7i6ve2gPlFBy7FjJl
IPsPYJY1IhzNzheFok7aVo7k4CkCLBtz4y2GkbLd8wCKCZ2Qy1uLqqOA8PNYuFaC
LDqHW8eNHhBtzy0IahuADwuCrcwC4QEFO4Idrx4KefOBtOILKDxgyim2uaL0iioX
XVwm7mePS3ufL7KwDsQ+2FgKwffKrVJD9eh04mV15s0hWv20iNbxjIrUDSDEBceU
qgm3+TpawxZh/RrDN9dj4cxXI9fbZe9DLNWOvU/CVv3oFbzDVV9FE1yj5ZFTYcQ=
=D9nH
-----END PGP SIGNATURE-----

--=-PHlqDmcUK1C/XOvmXfZ0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
