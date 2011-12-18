Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 23F026B004F
	for <linux-mm@kvack.org>; Sat, 17 Dec 2011 19:34:25 -0500 (EST)
Date: Sun, 18 Dec 2011 00:34:19 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] Put braces around potentially empty 'if' body in
 handle_pte_fault()
Message-ID: <20111218003419.GE2203@ZenIV.linux.org.uk>
References: <alpine.LNX.2.00.1112180059080.21784@swampdragon.chaosbits.net>
 <1324167535.3323.63.camel@edumazet-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1324167535.3323.63.camel@edumazet-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Jesper Juhl <jj@chaosbits.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Sun, Dec 18, 2011 at 01:18:55AM +0100, Eric Dumazet wrote:
> Thats should be fixed in the reverse way :
> 
> #define flush_tlb_fix_spurious_fault(vma, address) do { } while (0)

There's a better way to do that -
#define f(a) do { } while(0)
does not work as a function returning void -
	f(1), g();
won't work.  OTOH
#define f(a) ((void)0)
works just fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
