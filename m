Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 276FA6B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 21:34:58 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id d20-v6so13601602pfn.16
        for <linux-mm@kvack.org>; Thu, 31 May 2018 18:34:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r68-v6sor13774489pfi.57.2018.05.31.18.34.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 May 2018 18:34:57 -0700 (PDT)
From: Nadav Amit <nadav.amit@gmail.com>
Message-Id: <0875D539-4B35-402D-9CCA-09BBA8DDB46E@gmail.com>
Content-Type: multipart/signed;
 boundary="Apple-Mail=_C21D2376-2116-4F8B-B8B9-7E52AF020EE9";
 protocol="application/pgp-signature"; micalg=pgp-sha512
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: Can kfree() sleep at runtime?
Date: Thu, 31 May 2018 18:34:45 -0700
In-Reply-To: <066df211-4d1e-787b-b89d-31b8827ea7a5@gmail.com>
References: <30ecafd7-ed61-907b-f924-77fc37dcc753@gmail.com>
 <20180531140808.GA30221@bombadil.infradead.org>
 <01000163b68a8026-56fb6a35-040b-4af9-8b73-eb3b4a41c595-000000@email.amazonses.com>
 <20180531141452.GC30221@bombadil.infradead.org>
 <01000163b69b6b62-6c5ac940-d6c1-419a-9dc9-697908020c53-000000@email.amazonses.com>
 <066df211-4d1e-787b-b89d-31b8827ea7a5@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia-Ju Bai <baijiaju1990@gmail.com>
Cc: Christopher Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>


--Apple-Mail=_C21D2376-2116-4F8B-B8B9-7E52AF020EE9
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

Jia-Ju Bai <baijiaju1990@gmail.com> wrote:

>=20
>=20
> On 2018/5/31 22:30, Christopher Lameter wrote:
>> On Thu, 31 May 2018, Matthew Wilcox wrote:
>>=20
>>>> Freeing a page in the page allocator also was traditionally not =
sleeping.
>>>> That has changed?
>>> No.  "Your bug" being "The bug in your static analysis tool".  It =
probably
>>> isn't following the data flow correctly (or deeply enough).
>> Well ok this is not going to trigger for kfree(), this is x86 =
specific and
>> requires CONFIG_DEBUG_PAGEALLOC and a free of a page in a huge page.
>>=20
>> Ok that is a very contorted situation but how would a static checker =
deal
>> with that?
>=20
> I admit that my tool does not follow the data flow well, and I need to =
improve it.
> In this case of kfree(), I want know how the data flow leads to my =
mistake.

Note that is only enabled in debug mode:

static inline void
kernel_map_pages(struct page *page, int numpages, int enable)
{
        if (!debug_pagealloc_enabled())
                return;

        __kernel_map_pages(page, numpages, enable);
}

--Apple-Mail=_C21D2376-2116-4F8B-B8B9-7E52AF020EE9
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEE0YCJM4pMIpzxUdmOK4dOkxJsY0AFAlsQorUACgkQK4dOkxJs
Y0As5g//UwJi2Da+1MTTDXrF0fseQgsSj19NMCrxxJHd3aduKLJNx+vZkz3LkltE
jZg4PAe0STe4hvJF/hfOg1CZPWbLh5zHrcmOc8At0QJKgWp9LPKeYSKmonEew6Z1
GUngUmkejqca6e1DE2XS/ugCRtKrcbahyFbjR0//Q4co/+KokXgaINa0UT1BlEiF
lK3wt7ID7it+Y0Yn5W/d5oFAEy9wfxXEZFYqKrDDY2qraKVUleHNhK9SrRcJYwKO
EgL4Dv2NHPzBTwWYuPzSe/a7CtNj7+rMx5wqLyWcNJ5dXaJ6Rq8MA+8CqxV0gahR
dQvErle7rOfp2z1lfgwVlSfEgrA/aKI9odEDuIdzcYqJF5u7T4syIHkPGzApDqPb
JTVUHDrndQGiHY1TuQU1BzaysqGVOec0DQxjfP4iyH5a9PYbQlVEdx5Hyf8mqrn5
1pnJuN1G/6EJ4OJiB3SJOAow6HAWuBJuHLRpVb+SQzEb2pPmSs7AvIG6ynEVNSFA
V528vklsGR7/XTHJYJEDToxiok0PjQ9tEzIA77FwPLeGgjtO/09m2nwtQ3qQ1e43
tcIDoOo4YaRH0W+y3ALv25L5LRx8azlKaGKPnseMltiN8iyTWiieOoO4zUdV2ema
amGI7ZIRyeIRumGyEP6ONvJSp75yw1v7SM8LSdE2/QeezujP1VQ=
=ACvM
-----END PGP SIGNATURE-----

--Apple-Mail=_C21D2376-2116-4F8B-B8B9-7E52AF020EE9--
