Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id AADF96B0144
	for <linux-mm@kvack.org>; Wed, 20 May 2015 20:18:00 -0400 (EDT)
Received: by pdfh10 with SMTP id h10so87209516pdf.3
        for <linux-mm@kvack.org>; Wed, 20 May 2015 17:18:00 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id wt10si28746739pab.236.2015.05.20.17.17.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 May 2015 17:17:58 -0700 (PDT)
Date: Thu, 21 May 2015 10:17:48 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: Tree for May 18 (mm/memory-failure.c)
Message-ID: <20150521101748.2ff2fb9e@canb.auug.org.au>
In-Reply-To: <20150520130320.1fc1bd7b1c26dae15c5946c5@linux-foundation.org>
References: <20150518185226.23154d47@canb.auug.org.au>
	<555A0327.9060709@infradead.org>
	<20150519024933.GA1614@hori1.linux.bs1.fc.nec.co.jp>
	<555C1EA5.3080700@huawei.com>
	<20150520130320.1fc1bd7b1c26dae15c5946c5@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/gEcqDV543fE+GRdr8+N58q."; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Xie XiuQi <xiexiuqi@huawei.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Randy Dunlap <rdunlap@infradead.org>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Steven Rostedt <rostedt@goodmis.org>, Jim Davis <jim.epost@gmail.com>, Chen Gong <gong.chen@linux.intel.com>

--Sig_/gEcqDV543fE+GRdr8+N58q.
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Wed, 20 May 2015 13:03:20 -0700 Andrew Morton <akpm@linux-foundation.org=
> wrote:
>
> I dropped
>=20
> memory-failure-export-page_type-and-action-result.patch
> memory-failure-change-type-of-action_results-param-3-to-enum.patch
> tracing-add-trace-event-for-memory-failure.patch

OK, I have dropped them from linux-next as well (on the way fixing up
"mm/memory-failure: split thp earlier in memory error handling" and
"mm/memory-failure: me_huge_page() does nothing for thp").

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/gEcqDV543fE+GRdr8+N58q.
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVXSQxAAoJEMDTa8Ir7ZwVnHwP/0EZ3nLyJXhcDHRCDS7XBPDD
zPra6g1qEUW1xaPqF5sQhXE4WvmQ+yK1pL/6wbLaQ6jnCESv/C4QqbI3INnLycrR
V1f1g0qzMzmHn1iygudDcCqbRE1aj/6g5BjM4qGBbb+JbwrAX3ixloZZTmyWjm+Y
mGt19qU5IcmLU/OgOw1A+4IBFUHGVEjbCzanJ9g7p0KBTk+SWa6qYXmmJzz/cyi2
WfYkcHWSzJI0Ih1TZ3f+chENxiFpX7zhw1fUhkRZFZTlPA4DYFRqAH3o6Tq0bvYg
tqg3nzxtqVD3HzbQWVNuBPv23qFgW0PFr6GKvUsqsKyC2GZxamhA9QIZ/UFIz3q8
h6TxNhrh7wQwRaiPwlZrtO+8LwIQnJfDfVuJlT9QJnWZeWkJjkihTjKxZ/fwqyTH
tSlon+aAnf67AgaVeopQn9C33ZAWTLir1nkYjQGpfVIwr3rRWg1GMCK2tc/aJQsD
UKoGR1fgbHXi4/d6e6/3vqNh86D/zDGQH+CPY4KzOVlpooTbt5TxemF5At+C/3fl
hLK/9WWsQsN6tL2GtZcvtPUl6Q04vgZtea92+a17gwRrWGmHJE4m6EAJfPmOUMbQ
pQqN+q9IiOsO3BRpyIYv9crcNtNcqby8e1S1vutUK+PVa/lLQnROC1b3BKNUwQp5
M6TX4NStR6s1Ie9zfAe7
=1VMK
-----END PGP SIGNATURE-----

--Sig_/gEcqDV543fE+GRdr8+N58q.--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
