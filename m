Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 718136B004F
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 10:57:48 -0400 (EDT)
Message-ID: <4AD73862.4010102@redhat.com>
Date: Thu, 15 Oct 2009 10:57:38 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/9] swap_info: private to swapfile.c
References: <Pine.LNX.4.64.0910150130001.2250@sister.anvils> <Pine.LNX.4.64.0910150144310.3291@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0910150144310.3291@sister.anvils>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nigel Cunningham <ncunningham@crca.org.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> The swap_info_struct is mostly private to mm/swapfile.c, with only
> one other in-tree user: get_swap_bio().  Adjust its interface to
> map_swap_page(), so that we can then remove get_swap_info_struct().
> 
> But there is a popular user out-of-tree, TuxOnIce: so leave the
> declaration of swap_info_struct in linux/swap.h.
> 
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
