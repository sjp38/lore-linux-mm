Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 62CC96B004F
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 18:17:23 -0400 (EDT)
Date: Thu, 15 Oct 2009 23:17:20 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 6/9] swap_info: swap_map of chars not shorts
In-Reply-To: <20091015114435.9470890a.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0910152308490.4447@sister.anvils>
References: <Pine.LNX.4.64.0910150130001.2250@sister.anvils>
 <Pine.LNX.4.64.0910150152330.3291@sister.anvils>
 <20091015114435.9470890a.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 15 Oct 2009, KAMEZAWA Hiroyuki wrote:
> On Thu, 15 Oct 2009 01:53:52 +0100 (BST)
> Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:
> > @@ -1175,6 +1175,12 @@ static int try_to_unuse(unsigned int typ
> >  		 * If that's wrong, then we should worry more about
> >  		 * exit_mmap() and do_munmap() cases described above:
> >  		 * we might be resetting SWAP_MAP_MAX too early here.
> > +		 *
> > +		 * Yes, that's wrong: though very unlikely, swap count 0x7ffe
> > +		 * could surely occur if pid_max raised from PID_MAX_DEFAULT;
> 
> Just a nitpick.
> 
> Hmm, logically, our MAX COUNT is 0x7e after this patch. Then, how about not
> mentioning to 0x7ffe and PID_MAX ? as..
> 
> Yes, that's wrong: we now use SWAP_MAP_MAX as 0x7e, very easy to overflow.
> next patch will...

Perhaps we're reading it differently: I was there inserting a comment
on what was already said above (with no wish to change that existing
comment), then going on (immediately below) to mention how this patch
is now lowering SWAP_MAP_MAX to 0x7e, making the situation even worse,
but no worries because the next patch fixes it.

If you are seeing a nit there, I'm afraid it's one too small for my
eye!  And the lifetime of this comment, in Linus's git history, will
be (I'm guessing) a fraction of a second - becoming a non-issue, it
rightly gets deleted in the next patch.

Hugh

> 
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> > +		 * and we are now lowering SWAP_MAP_MAX to 0x7e, making it
> > +		 * much easier to reach.  But the next patch will fix that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
