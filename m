Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C22C06B004F
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 19:10:08 -0400 (EDT)
Message-ID: <4AD7ABE7.40105@crca.org.au>
Date: Fri, 16 Oct 2009 10:10:31 +1100
From: Nigel Cunningham <ncunningham@crca.org.au>
MIME-Version: 1.0
Subject: Re: [PATCH 1/9] swap_info: private to swapfile.c
References: <Pine.LNX.4.64.0910150130001.2250@sister.anvils> <Pine.LNX.4.64.0910150144310.3291@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0910150144310.3291@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Hugh.

Hugh Dickins wrote:
> The swap_info_struct is mostly private to mm/swapfile.c, with only
> one other in-tree user: get_swap_bio().  Adjust its interface to
> map_swap_page(), so that we can then remove get_swap_info_struct().
> 
> But there is a popular user out-of-tree, TuxOnIce: so leave the
> declaration of swap_info_struct in linux/swap.h.

Sorry for the delay in replying.

I don't mind if you don't leave swap_info_struct in
include/linux/swap.h. I'm currently reworking my swap support anyway,
adding support for honouring the priority field. I've also recently
learned that under some circumstances, allocating all available swap can
take quite a while (I have a user who is hibernating with 32GB of RAM!),
so I've been thinking about what I can do to optimise that.

Regards,

Nigel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
