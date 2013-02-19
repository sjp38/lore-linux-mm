Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 0F1DA6B0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 13:57:08 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id md12so2399637pbc.30
        for <linux-mm@kvack.org>; Tue, 19 Feb 2013 10:57:08 -0800 (PST)
Date: Tue, 19 Feb 2013 10:56:27 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Should a swapped out page be deleted from swap cache?
In-Reply-To: <512338A6.1030602@gmail.com>
Message-ID: <alpine.LNX.2.00.1302191050330.2248@eggly.anvils>
References: <CAFNq8R4UYvygk8+X+NZgyGjgU5vBsEv1UM6MiUxah6iW8=0HrQ@mail.gmail.com> <alpine.LNX.2.00.1302180939200.2246@eggly.anvils> <512338A6.1030602@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Mason <ric.masonn@gmail.com>
Cc: Li Haifeng <omycle@gmail.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 19 Feb 2013, Ric Mason wrote:
> 
> There is a call of try_to_free_swap in function swap_writepage, if
> swap_writepage is call from shrink_page_list path, PageSwapCache(page) ==
> trure, PageWriteback(page) maybe false, page_swapcount(page) == 0, then will
> delete the page from swap cache and free swap slot, where I miss?

That's correct.  PageWriteback is sure to be false there.  page_swapcount
usually won't be 0 there, but sometimes it will be, and in that case we
do want to delete from swap cache and free the swap slot.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
