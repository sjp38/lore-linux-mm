Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id F19236B004F
	for <linux-mm@kvack.org>; Sat, 17 Dec 2011 20:00:33 -0500 (EST)
Date: Sun, 18 Dec 2011 02:00:31 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [PATCH] Use 'do {} while (0)' for empty flush_tlb_fix_spurious_fault()
 macro
In-Reply-To: <CANN689GQyzMGfnxsKmni7wDFpqo4s=D3dpu6w9UxN0tKbqakig@mail.gmail.com>
Message-ID: <alpine.LNX.2.00.1112180158330.21784@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1112180128070.21784@swampdragon.chaosbits.net> <CANN689GQyzMGfnxsKmni7wDFpqo4s=D3dpu6w9UxN0tKbqakig@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-91926389-1324170031=:21784"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: x86@kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@ZenIV.linux.org.uk>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-91926389-1324170031=:21784
Content-Type: TEXT/PLAIN; charset=windows-1252
Content-Transfer-Encoding: 8BIT

On Sat, 17 Dec 2011, Michel Lespinasse wrote:

> On Sat, Dec 17, 2011 at 4:32 PM, Jesper Juhl <jj@chaosbits.net> wrote:
> > If one builds the kernel with -Wempty-body one gets this warning:
> >
> >  mm/memory.c:3432:46: warning: suggest braces around empty body in an ?if? statement [-Wempty-body]
> >
> > due to the fact that 'flush_tlb_fix_spurious_fault' is a macro that
> > can sometimes be defined to nothing.
> >
> > Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> 
> Looks good to me. I'd be happy with either that or Al's alternative suggestion.
> 
> Reviewed-by: Michel Lespinasse <walken@google.com>
> 
Thanks for the review.

I did see Al's suggestion and he does have a point. But since it doesn't 
actually matter much in this specific case I'd say "let's just go with 
this one - it matches what's done nearly everywhere else".
But, If someone disagrees strongly I'll cook up a different patch. :-)

-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.

--8323328-91926389-1324170031=:21784--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
