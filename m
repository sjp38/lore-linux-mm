Date: Wed, 4 Feb 2004 10:33:07 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 0/5] mm improvements
Message-Id: <20040204103307.7a288ce3.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.44.0402041337350.3479-100000@localhost.localdomain>
References: <16416.62172.489558.39126@laputa.namesys.com>
	<Pine.LNX.4.44.0402041337350.3479-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nikita@Namesys.COM, piggin@cyberone.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins <hugh@veritas.com> wrote:
>
> > 4. I found that shmem_writepage() has BUG_ON(page_mapped(page))
>  > check. Its removal had no effect, and I am not sure why the check was
>  > there at all.
> 
>  Sorry, that BUG_ON is there for very good reason.  It's no disgrace
>  that your testing didn't notice the effect of passing a mapped page
>  down to shmem_writepage, but it is a serious breakage of tmpfs.

hm.  Can't I force writepage-of-a-mapped-page with msync()?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
