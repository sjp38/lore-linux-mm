Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 60B706B005A
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 19:54:37 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9FNsYCU022994
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 16 Oct 2009 08:54:34 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 279192AEA8D
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 08:54:34 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D1E645DE54
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 08:54:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 27DBF1DB8051
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 08:54:33 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C23E41DB8040
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 08:54:32 +0900 (JST)
Date: Fri, 16 Oct 2009 08:52:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 6/9] swap_info: swap_map of chars not shorts
Message-Id: <20091016085208.6c6870cb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0910152308490.4447@sister.anvils>
References: <Pine.LNX.4.64.0910150130001.2250@sister.anvils>
	<Pine.LNX.4.64.0910150152330.3291@sister.anvils>
	<20091015114435.9470890a.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0910152308490.4447@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 15 Oct 2009 23:17:20 +0100 (BST)
Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:

> On Thu, 15 Oct 2009, KAMEZAWA Hiroyuki wrote:
> > On Thu, 15 Oct 2009 01:53:52 +0100 (BST)
> > Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:
> > > @@ -1175,6 +1175,12 @@ static int try_to_unuse(unsigned int typ
> > >  		 * If that's wrong, then we should worry more about
> > >  		 * exit_mmap() and do_munmap() cases described above:
> > >  		 * we might be resetting SWAP_MAP_MAX too early here.
> > > +		 *
> > > +		 * Yes, that's wrong: though very unlikely, swap count 0x7ffe
> > > +		 * could surely occur if pid_max raised from PID_MAX_DEFAULT;
> > 
> > Just a nitpick.
> > 
> > Hmm, logically, our MAX COUNT is 0x7e after this patch. Then, how about not
> > mentioning to 0x7ffe and PID_MAX ? as..
> > 
> > Yes, that's wrong: we now use SWAP_MAP_MAX as 0x7e, very easy to overflow.
> > next patch will...
> 
> Perhaps we're reading it differently: I was there inserting a comment
> on what was already said above (with no wish to change that existing
> comment), then going on (immediately below) to mention how this patch
> is now lowering SWAP_MAP_MAX to 0x7e, making the situation even worse,
> but no worries because the next patch fixes it.
> 
yes.

> If you are seeing a nit there, I'm afraid it's one too small for my
> eye! 

I don't think it's very troublesome, but in these days, people seems to love
"bisect", Then, comments for change and comments for code should be divided, IMHO.

> And the lifetime of this comment, in Linus's git history, will
> be (I'm guessing) a fraction of a second - becoming a non-issue, it
> rightly gets deleted in the next patch.

ya, thanks.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
