Date: Wed, 21 Nov 2001 10:13:52 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 2.4.14 + Bug in swap_out.
In-Reply-To: <m1vgg41x3x.fsf@frodo.biederman.org>
Message-ID: <Pine.LNX.4.33L.0111211013020.4079-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 20 Nov 2001, Eric W. Biederman wrote:

> 	/* Make sure the mm doesn't disappear when we drop the lock.. */
> 	atomic_inc(&mm->mm_users);
> 	spin_unlock(&mmlist_lock);
>
> 	nr_pages = swap_out_mm(mm, nr_pages, &counter, classzone);
>
> 	mmput(mm);
>
>
> And looking in fork.c mmput under with right circumstances becomes.
> kmem_cache_free(mm_cachep, (mm)))
>
> So it appears that there is nothing that keeps the mm_struct that
> swap_mm points to as being valid.

The atomic_inc(&mm->mm_users) above should make sure this
mm_struct stays valid.

regards,

Rik
-- 
Shortwave goes a long way:  irc.starchat.net  #swl

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
