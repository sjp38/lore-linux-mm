Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0FCE56B006C
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 21:58:12 -0500 (EST)
Received: by mail-wg0-f42.google.com with SMTP id z12so16002608wgg.29
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 18:58:11 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id et4si5310474wib.44.2014.12.01.18.58.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Dec 2014 18:58:11 -0800 (PST)
Message-ID: <547D2AB4.2040005@redhat.com>
Date: Mon, 01 Dec 2014 21:57:56 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 4/4] mm: Refactor do_wp_page handling of shared vma
 into a function
References: <1417467491-20071-1-git-send-email-raindel@mellanox.com> <1417467491-20071-5-git-send-email-raindel@mellanox.com>
In-Reply-To: <1417467491-20071-5-git-send-email-raindel@mellanox.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shachar Raindel <raindel@mellanox.com>, linux-mm@kvack.org
Cc: kirill.shutemov@linux.intel.com, mgorman@suse.de, ak@linux.intel.com, matthew.r.wilcox@intel.com, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, haggaie@mellanox.com, aarcange@redhat.com, pfeiner@google.com, hannes@cmpxchg.org, sagig@mellanox.com, walken@google.com

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 12/01/2014 03:58 PM, Shachar Raindel wrote:
> The do_wp_page function is extremely long. Extract the logic for 
> handling a page belonging to a shared vma into a function of its
> own.
> 
> This helps the readability of the code, without doing any
> functional change in it.
> 
> Signed-off-by: Shachar Raindel <raindel@mellanox.com>

Acked-by: Rik van Riel <riel@redhat.com>

- -- 
All rights reversed
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJUfSq0AAoJEM553pKExN6Dww4H+wX6I6UOeQoOtDZqxrpTyvSL
nDXpJ5ltj8eHOdkZKiq5tEzfQygXCAKKqbkfzD0Csqoj96HZFJ7V+uHcxtg8g6+g
0HUpj91XEkVqenBNEuJnlTrbs3XxxUn1fHecm+jD5konfVPaexSNONINsgvArZPd
a0YLMur9PXtuCRhEppfVwRB160BxpkIm4iTnnyF/oaZAz1S/pkiKrb1qhxOanrEP
o2Zry1f4cALiD/yT6+tQCs78pTt23BP0ig7qNQLDiriX2tFwCI37LnYhJzsawF5t
I3B2MD28GdwXYq+RBE3iA+FXdB7cxQIrCHh9OuH+yqm4coPFwJOYET9nCrBruns=
=JXx3
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
