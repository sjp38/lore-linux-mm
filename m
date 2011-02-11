Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id EB5998D0039
	for <linux-mm@kvack.org>; Fri, 11 Feb 2011 09:47:26 -0500 (EST)
Date: Fri, 11 Feb 2011 15:47:17 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [LSF/MM TOPIC] Writeback - current state and future
Message-ID: <20110211144717.GH5187@quack.suse.cz>
References: <20110204164222.GG4104@quack.suse.cz>
 <4D4E7B48.9020500@panasas.com>
 <op.vqhlw3rirwwil4@sfaibish1.corp.emc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <op.vqhlw3rirwwil4@sfaibish1.corp.emc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sorin Faibish <sfaibish@emc.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, Jan Kara <jack@suse.cz>, lsf-pc@lists.linuxfoundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>

On Sun 06-02-11 10:13:41, Sorin Faibish wrote:
> I was thinking to have a special track for all the writeback related
> topics.
  Well, a separate track might be a bit too much I feel ;). I'm interested
also in other things that are happening... We'll see what the program will
be but I can imagine we can discuss for a couple of hours but that might be
just a discussion in a small circle over a <enter preferable drink>.

> I would like also to include a discussion on new cache writeback paterns
> with the target to prevent any cache swaps that are becoming a
> bigger problem
> when dealing with servers wir 100's GB caches. The swap is the worst that
> could happen to the performance of such systems. I will share my
> latest findings
> in the cache writeback in continuation to my previous discussion at
> last LSF.
  I'm not sure what do you exactly mean by 'cache swaps'. If you mean that
your application private cache is swapped out, then I can imagine this is a
problem but I'd need more details to tell how big.

									Honza 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
