Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 344836B004F
	for <linux-mm@kvack.org>; Wed,  7 Oct 2009 08:20:39 -0400 (EDT)
Message-Id: <4ACCA3B402000078000187BE@vpn.id2.novell.com>
Date: Wed, 07 Oct 2009 13:20:36 +0100
From: "Jan Beulich" <JBeulich@novell.com>
Subject: Re: [PATCH] adjust gfp mask passed on nested vmalloc()
	 invocation
References: <4AC9E38E0200007800017F57@vpn.id2.novell.com>
 <Pine.LNX.4.64.0910062241500.21409@sister.anvils>
 <4ACC62DC0200007800018690@vpn.id2.novell.com>
 <Pine.LNX.4.64.0910071300330.28844@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0910071300330.28844@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>>> Hugh Dickins <hugh.dickins@tiscali.co.uk> 07.10.09 14:08 >>>
>Well, now we've accepted that this code cannot be used in_interrupt(),
>there's no need for your #ifdef CONFIG_HIGHMEM nor for my memset: just
>use __GFP_ZERO as it was before, and your patch would amount to or'ing
>__GFP_HIGHMEM into gfp_mask for the __vmalloc_node case - wouldn't it?

Plus the consolidation of masking the passed in gfp_mask by
GFP_RECLAIM_MASK also for the nested vmalloc() case, in particular to
remove the GFP_DMA* possibly coming in from vmalloc_32(). But yes,
it will become simpler.

Jan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
