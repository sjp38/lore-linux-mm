Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 264276B0033
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 15:21:51 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id c195so1056844itb.5
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 12:21:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t145si11636oih.468.2017.09.19.12.21.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Sep 2017 12:21:50 -0700 (PDT)
Message-ID: <1505848907.5486.9.camel@redhat.com>
Subject: Re: [patch v2] madvise.2: Add MADV_WIPEONFORK documentation
From: Rik van Riel <riel@redhat.com>
Date: Tue, 19 Sep 2017 15:21:47 -0400
In-Reply-To: <a1715d1d-7a03-d2db-7a8a-8a2edceae5d1@gmail.com>
References: <20170914130040.6faabb18@cuia.usersys.redhat.com>
	 <CAAF6GDdnY2AmzKx+t4ffCFxJ+RZS++4tmWvoazdVNVSYjra_WA@mail.gmail.com>
	 <20170914150546.74ad3a9a@cuia.usersys.redhat.com>
	 <a1715d1d-7a03-d2db-7a8a-8a2edceae5d1@gmail.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-XZi3YTtVGWBoV0g1jWxu"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, Colm =?ISO-8859-1?Q?MacC=E1rthaigh?= <colm@allcosts.net>
Cc: linux-man@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, nilal@redhat.com, Florian Weimer <fweimer@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>


--=-XZi3YTtVGWBoV0g1jWxu
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: base64

T24gVHVlLCAyMDE3LTA5LTE5IGF0IDIxOjA3ICswMjAwLCBNaWNoYWVsIEtlcnJpc2sgKG1hbi1w
YWdlcykgd3JvdGU6Cgo+IFRoYW5rcy4gSSBhcHBsaWVkIHRoaXMsIGFuZCB0d2Vha2VkIHRoZSBt
YWR2aXNlLjIgdGV4dCBhIGxpdHRsZSwgdG8KPiByZWFkIGFzIGZvbGxvd3MgKHBsZWFzZSBsZXQg
bWUga25vdyBpZiBJIG1lc3NlZCBhbnl0aGluZyB1cCk6Cj4gCj4gwqDCoMKgwqDCoMKgwqBNQURW
X1dJUEVPTkZPUksgKHNpbmNlIExpbnV4IDQuMTQpCj4gwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoFByZXNlbnQgdGhlIGNoaWxkIHByb2Nlc3Mgd2l0aCB6ZXJvLWZpbGxlZAo+IG1lbW9yecKg
wqBpbsKgwqB0aGlzCj4gwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoHJhbmdlwqDCoGFmdGVy
wqDCoGEgZm9yaygyKS7CoMKgVGhpcyBpcyB1c2VmdWwgaW4gZm9ya2luZwo+IHNlcnZlcnMKPiDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgaW4gb3JkZXIgdG8gZW5zdXJlIHRoYXTCoMKgc2Vu
c2l0aXZlwqDCoHBlci0KPiBwcm9jZXNzwqDCoGRhdGHCoMKgKGZvcgo+IMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqBleGFtcGxlLMKgwqBQUk5HwqDCoHNlZWRzLCBjcnlwdG9ncmFwaGljIHNl
Y3JldHMsIGFuZCBzbwo+IG9uKSBpcwo+IMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqBub3Qg
aGFuZGVkIHRvIGNoaWxkIHByb2Nlc3Nlcy4KPiAKPiDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgVGhlIE1BRFZfV0lQRU9ORk9SSyBvcGVyYXRpb24gY2FuIGJlIGFwcGxpZWQKPiBvbmx5wqDC
oHRvwqDCoHByaeKAkAo+IMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqB2YXRlIGFub255bW91
cyBwYWdlcyAoc2VlIG1tYXAoMikpLgoKVGhhdCBsb29rcyBncmVhdC4gVGhhbmsgeW91LCBNaWNo
YWVsIQoKLS0gCkFsbCByaWdodHMgcmV2ZXJzZWQ=


--=-XZi3YTtVGWBoV0g1jWxu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJZwW5LAAoJEM553pKExN6DHx0H/A+rY3gziTqL3ZAWKBcAXoLb
JZDXnNUHB2tN+pQKna07HULQiWPCOve3DnQcMADDEGa8DZY2vHyjmg0gJBLQD96I
fjatk+H7S+//a0Uzj4koAgxGDVS0/10ht9ouxlKpX0y7XD4ts3o1NC2/LXh2sGMe
F3g3CxccDV3br8V2IUAvQYjm1tHuPzrIqLYtGdt8+BQD+zeePTW6Q4AXgjWGc0oK
+S0/iKeyTgrOuHan0DQv+3Fk36Qc96btl4iRpu2OUMW8pA/6cmtSqSW3ru0POzRf
Ks2cytWjeYlY7x4BpSVPUc5IIby76twl18lF8y03AN7A4U7iI/ELmPRE4/OBr/Q=
=7BXP
-----END PGP SIGNATURE-----

--=-XZi3YTtVGWBoV0g1jWxu--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
