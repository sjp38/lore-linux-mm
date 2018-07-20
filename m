Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 442776B0003
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 10:43:33 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id i9-v6so8664615qtj.3
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 07:43:33 -0700 (PDT)
Received: from smtp68.iad3a.emailsrvr.com (smtp68.iad3a.emailsrvr.com. [173.203.187.68])
        by mx.google.com with ESMTPS id y4-v6si749755qvb.104.2018.07.20.07.43.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 07:43:32 -0700 (PDT)
From: Mark Vitale <mvitale@sinenomine.net>
Subject: re: [PATCH v4 0/8] mm: Rework hmm to use devm_memremap_pages and
 other fixes
Date: Fri, 20 Jul 2018 14:43:14 +0000
Message-ID: <37267986-A987-4AD7-96CE-C1D2F116A4AC@sinenomine.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <5C1AA35799B0FE489C7AC171780E466F@mex09.mlsrvr.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Dan Williams <dan.j.williams@intel.org>, Andrew Morton <akpm@linux-foundation.org>, Joe Gorse <jgorse@sinenomine.net>, "release-team@openafs.org" <release-team@openafs.org>

On Jul 11, 2018, Dan Williams wrote:
> Changes since v3 [1]:
> * Collect Logan's reviewed-by on patch 3
> * Collect John's and Joe's tested-by on patch 8
> * Update the changelog for patch 1 and 7 to better explain the
>   EXPORT_SYMBOL_GPL rationale.
> * Update the changelog for patch 2 to clarify that it is a cleanup to
>   make the following patch-3 fix easier
>
> [1]: https://lkml.org/lkml/2018/6/19/108
>
> ---
>=20
> Hi Andrew,
>=20
> As requested, here is a resend of the devm_memremap_pages() fixups.
> Please consider for 4.18.

What is the status of this patchset?  OpenAFS is unable to build on
Linux 4.18 without the last patch in this set:

8/8  mm: Fix exports that inadvertently make put_page() EXPORT_SYMBOL_GPL

Will this be merged soon to linux-next, and ultimately to a Linux 4.18 rc?

Thank you,
--
Mark Vitale
mvitale@sinenomine.net
on behalf of the OpenAFS release team
