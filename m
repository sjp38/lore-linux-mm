Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 53B598E0002
	for <linux-mm@kvack.org>; Tue,  1 Jan 2019 15:11:09 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id n45so37661020qta.5
        for <linux-mm@kvack.org>; Tue, 01 Jan 2019 12:11:09 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o203sor1216381qke.131.2019.01.01.12.11.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 01 Jan 2019 12:11:08 -0800 (PST)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH] mm: Introduce page_size()
Date: Tue, 01 Jan 2019 15:11:04 -0500
Message-ID: <512B2F1D-73EE-46A8-89CC-DBF03CAA0F27@cs.rutgers.edu>
In-Reply-To: <20190101063922.GE6310@bombadil.infradead.org>
References: <20181231134223.20765-1-willy@infradead.org>
 <20181231230222.zq23mor2y5n67ast@kshutemo-mobl1>
 <20190101063922.GE6310@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_9706F31A-18F8-4DF4-A4FF-A602C41F10A6_=";
 micalg=pgp-sha1; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_9706F31A-18F8-4DF4-A4FF-A602C41F10A6_=
Content-Type: text/plain; markup=markdown

On 1 Jan 2019, at 1:39, Matthew Wilcox wrote:

> On Tue, Jan 01, 2019 at 02:02:22AM +0300, Kirill A. Shutemov wrote:
>> On Mon, Dec 31, 2018 at 05:42:23AM -0800, Matthew Wilcox wrote:
>>> It's unnecessarily hard to find out the size of a potentially huge page.
>>> Replace 'PAGE_SIZE << compound_order(page)' with page_size(page).
>>
>> Good idea.
>>
>> Should we add page_mask() and page_shift() too?
>
> I'm not opposed to that at all.  I also have a patch to add compound_nr():
>
> +/* Returns the number of pages in this potentially compound page. */
> +static inline unsigned long compound_nr(struct page *page)
> +{
> +       return 1UL << compound_order(page);
> +}
>
> I just haven't sent it yet ;-)  It should, perhaps, be called page_count()
> or nr_pages() or something.  That covers most of the remaining users of
> compound_order() which look awkward.

We already have hpage_nr_pages() to show the number of pages. Why do we need
another one?


--
Best Regards,
Yan Zi

--=_MailMate_9706F31A-18F8-4DF4-A4FF-A602C41F10A6_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----

iQFKBAEBAgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAlwryVgWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzIxOB/92hps5I6pOBt9ecw/oWINRyC0g
59BKgVRLWCyb2KMb3H3xInHutbm9Qzu0LzBEnc4+XyU5rVUCxHeEn6pta2Tbzaaa
1DsfGAqLQ6mgm4iMlj4QHAxolCU7U/jSZDz4M637DM/zmUqvUwjqtoO1TzyPUfxZ
PIdUbjgUqDrXkjelrAFYELnovMEMxkDjcpEoItdCq00N9MmCJDUPHAyiXOrNMnjo
/3K/Kwtyg3scERZKt7swGYI6WNaC5Bb5pY4yE/30768Zm3wVFBE3DBESYT0i04SR
5NnnMWi820ujELlltuFdM/eSNc9yQGIgs+/UmTdR5D/YHmIwiUVLK0U42tdN
=NEPB
-----END PGP SIGNATURE-----

--=_MailMate_9706F31A-18F8-4DF4-A4FF-A602C41F10A6_=--
