Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id DE6C18E0002
	for <linux-mm@kvack.org>; Tue,  1 Jan 2019 20:16:29 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id y83so35656136qka.7
        for <linux-mm@kvack.org>; Tue, 01 Jan 2019 17:16:29 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o29sor40886604qve.37.2019.01.01.17.16.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 01 Jan 2019 17:16:29 -0800 (PST)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH] mm: Introduce page_size()
Date: Tue, 01 Jan 2019 20:16:26 -0500
Message-ID: <7342B9ED-D8F3-45F0-B07A-E553478D066C@cs.rutgers.edu>
In-Reply-To: <20190102005829.GF6310@bombadil.infradead.org>
References: <20181231134223.20765-1-willy@infradead.org>
 <20181231230222.zq23mor2y5n67ast@kshutemo-mobl1>
 <20190101063922.GE6310@bombadil.infradead.org>
 <512B2F1D-73EE-46A8-89CC-DBF03CAA0F27@cs.rutgers.edu>
 <20190102005829.GF6310@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_99548DA8-D210-4ECB-B8FF-67E6B190F423_=";
 micalg=pgp-sha1; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_99548DA8-D210-4ECB-B8FF-67E6B190F423_=
Content-Type: text/plain; markup=markdown

On 1 Jan 2019, at 19:58, Matthew Wilcox wrote:

> On Tue, Jan 01, 2019 at 03:11:04PM -0500, Zi Yan wrote:
>> On 1 Jan 2019, at 1:39, Matthew Wilcox wrote:
>>
>>> On Tue, Jan 01, 2019 at 02:02:22AM +0300, Kirill A. Shutemov wrote:
>>>> On Mon, Dec 31, 2018 at 05:42:23AM -0800, Matthew Wilcox wrote:
>>>>> It's unnecessarily hard to find out the size of a potentially huge page.
>>>>> Replace 'PAGE_SIZE << compound_order(page)' with page_size(page).
>>>>
>>>> Good idea.
>>>>
>>>> Should we add page_mask() and page_shift() too?
>>>
>>> I'm not opposed to that at all.  I also have a patch to add compound_nr():
>>>
>>> +/* Returns the number of pages in this potentially compound page. */
>>> +static inline unsigned long compound_nr(struct page *page)
>>> +{
>>> +       return 1UL << compound_order(page);
>>> +}
>>>
>>> I just haven't sent it yet ;-)  It should, perhaps, be called page_count()
>>> or nr_pages() or something.  That covers most of the remaining users of
>>> compound_order() which look awkward.
>>
>> We already have hpage_nr_pages() to show the number of pages. Why do we need
>> another one?
>
> Not all compound pages are PMD sized.

Right, and THPs are also compound pages. Maybe using your compound_nr() in
hpage_nr_pages() to factor out the common code if compound_nr() is going to
be added?

--
Best Regards,
Yan Zi

--=_MailMate_99548DA8-D210-4ECB-B8FF-67E6B190F423_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----

iQFKBAEBAgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAlwsEOoWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzB2ECACg7Nxw3+2xD6a//nCoPYl7x4Ke
01p6qx4iWzLU2pjUupbj4DKTDm56ovLLgy0+OwnX0zelW6cJXbVqPLLDED76SbWl
UhyaFQsfkzWuDMSTxk3emIu2pOYxn17dnAofwdaBl2kEF0xdT97mc7d+2mHRqRWV
qA6f6n58LVYiwSoUBEtbIxQfVW2q62XqzH/WLoMIlRzDjVqsTc/0lnuEhy4WVdOu
iqejtvVAI/1Oll8LYytnK+alaCuJlcsvQLyjrz59AAk3hga1WcFonfxOranD6AFH
Rg5AUXCG/DjGHge+3Tj3jS3wHu9GmYJTQ70P95dA0O8C40DC5EgLz9H6W9QP
=3kP5
-----END PGP SIGNATURE-----

--=_MailMate_99548DA8-D210-4ECB-B8FF-67E6B190F423_=--
