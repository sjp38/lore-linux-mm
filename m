Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 43B5328071E
	for <linux-mm@kvack.org>; Fri, 19 May 2017 16:49:02 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id h4so91597555oib.5
        for <linux-mm@kvack.org>; Fri, 19 May 2017 13:49:02 -0700 (PDT)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0112.outbound.protection.outlook.com. [104.47.42.112])
        by mx.google.com with ESMTPS id f66si3951294otb.304.2017.05.19.13.49.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 19 May 2017 13:49:01 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH v5 02/11] mm: mempolicy: add queue_pages_node_check()
Date: Fri, 19 May 2017 16:48:54 -0400
Message-ID: <61FCE04A-0227-4D5E-92E5-81EA06979FD3@cs.rutgers.edu>
In-Reply-To: <20170519202843.lco2rkkivh2a433k@techsingularity.net>
References: <20170420204752.79703-1-zi.yan@sent.com>
 <20170420204752.79703-3-zi.yan@sent.com>
 <f7a78cb0-0d91-bdbd-4a38-27f94fcefa8a@linux.vnet.ibm.com>
 <16799a52-8a03-7099-5f95-3016808ae65f@linux.vnet.ibm.com>
 <20170519160205.hkte6tlw26lfn74h@techsingularity.net>
 <35E3E5BA-2745-4710-A348-B6E5D892DA27@cs.rutgers.edu>
 <20170519202843.lco2rkkivh2a433k@techsingularity.net>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_01D5A9A2-B1BF-41A6-916E-0C5B15CCC42F_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mhocko@kernel.org, dnellans@nvidia.com

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_01D5A9A2-B1BF-41A6-916E-0C5B15CCC42F_=
Content-Type: text/plain; markup=markdown

On 19 May 2017, at 16:28, Mel Gorman wrote:

> On Fri, May 19, 2017 at 12:37:38PM -0400, Zi Yan wrote:
>>> As you say, there is no functional change but the helper name is vague
>>> and gives no hint to what's it's checking for. It's somewhat tolerable as
>>> it is as it's obvious what is being checked but the same is not true with
>>> the helper name.
>>>
>>
>> Does queue_pages_invert_nodemask_check() work? I can change the helper name
>> in the next version.
>>
>
> Not particularly, maybe queue_pages_required and invert the check with a
> comment above it explaining what it's checking for would be ok.
>

queue_pages_required() is too broad, I would take queue_pages_page_nid_check()
and invert the check with a comment above saying

/*
 * Check if the page's nid is in qp->nmask.
 *
 * If MPOL_MF_INVERT is set in qp->flags, check if the nid is
 * in the invert of qp->nmask.
 */

Does it work?

--
Best Regards
Yan Zi

--=_MailMate_01D5A9A2-B1BF-41A6-916E-0C5B15CCC42F_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJZH1o2AAoJEEGLLxGcTqbM6OwIALiPX9YSqT49awBSnaDq0JXE
ksIsRp2cjjqa8FkVjRpfeVJ4TG+FpWm2H5nBGxnUsQHS9vBkq9TkxFrYhSIR3h0c
wPxowE68lOeI2Y5QVlppf/uuhYaKMDtUzwo6fnbMaPm3uTZbhKVpMKKD/UFv7uBi
MnzQqK/rb3ZzQgQgI3x3LXrwu7HwVQ7iNr1lv1Z7+U7Z4Qth3PgILS7MmyqhDuXk
h+QbpVrS/Q+SEZncgFXZeP5Gvq5Vhjz2LJrO4TUHSKXkR7DL9CDHrUHgVOIirehR
VTJYz325E5cxGzdPvJQ2o8t45YTsexC3AYjpopa0ov+u1EoiNSy2F887nb/udwI=
=vnrB
-----END PGP SIGNATURE-----

--=_MailMate_01D5A9A2-B1BF-41A6-916E-0C5B15CCC42F_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
