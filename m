Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id BEBEE6B003D
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 07:44:49 -0400 (EDT)
Date: Wed, 1 Apr 2009 12:46:13 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: add_to_swap_cache with GFP_ATOMIC ?
In-Reply-To: <20090401165516.B1EB.A69D9226@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0904011245130.12751@blonde.anvils>
References: <28c262360903310338k20b8eebbncb86baac9b09e54@mail.gmail.com>
 <Pine.LNX.4.64.0903311154570.19028@blonde.anvils> <20090401165516.B1EB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 1 Apr 2009, KOSAKI Motohiro wrote:
> 
> IOW, GFP_ATOMIC on add_to_swap() was introduced accidentally. the reason 
> was old add_to_page_cache() didn't have gfp_mask parameter and we didn't
>  have the reason of changing add_to_swap() behavior.
> I think it don't have deeply reason and changing GFP_NOIO
> don't cause regression.

You may well be right: we'll see if you send in a patch to change it.
But I won't be sending in that patch myself, that's all :)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
