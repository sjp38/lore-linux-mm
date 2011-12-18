Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 02FC96B004F
	for <linux-mm@kvack.org>; Sat, 17 Dec 2011 20:18:34 -0500 (EST)
Received: by wgbdt12 with SMTP id dt12so4959741wgb.2
        for <linux-mm@kvack.org>; Sat, 17 Dec 2011 17:18:33 -0800 (PST)
Date: Sun, 18 Dec 2011 04:18:28 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] Put braces around potentially empty 'if' body in
 handle_pte_fault()
Message-ID: <20111218011828.GA4445@p183.telecom.by>
References: <alpine.LNX.2.00.1112180059080.21784@swampdragon.chaosbits.net>
 <1324167535.3323.63.camel@edumazet-laptop>
 <20111218003419.GE2203@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111218003419.GE2203@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Jesper Juhl <jj@chaosbits.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Sun, Dec 18, 2011 at 12:34:19AM +0000, Al Viro wrote:
> On Sun, Dec 18, 2011 at 01:18:55AM +0100, Eric Dumazet wrote:
> > Thats should be fixed in the reverse way :
> > 
> > #define flush_tlb_fix_spurious_fault(vma, address) do { } while (0)
> 
> There's a better way to do that -
> #define f(a) do { } while(0)
> does not work as a function returning void -
> 	f(1), g();
> won't work.  OTOH
> #define f(a) ((void)0)
> works just fine.

Two words: static inline.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
