Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BCBCD6B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 05:19:30 -0400 (EDT)
From: Nikanth Karthikesan <knikanth@suse.de>
Subject: Re: [RFC][PATCH] Per file dirty limit throttling
Date: Wed, 18 Aug 2010 14:52:04 +0530
References: <201008160949.51512.knikanth@suse.de> <201008171039.23701.knikanth@suse.de> <1282033475.1926.2093.camel@laptop>
In-Reply-To: <1282033475.1926.2093.camel@laptop>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <201008181452.05047.knikanth@suse.de>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Bill Davidsen <davidsen@tmr.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

On Tuesday 17 August 2010 13:54:35 Peter Zijlstra wrote:
> On Tue, 2010-08-17 at 10:39 +0530, Nikanth Karthikesan wrote:
> > Oh, nice.  Per-task limit is an elegant solution, which should help
> > during most of the common cases.
> >
> > But I just wonder what happens, when
> > 1. The dirtier is multiple co-operating processes
> > 2. Some app like a shell script, that repeatedly calls dd with seek and
> > skip? People do this for data deduplication, sparse skipping etc..
> > 3. The app dies and comes back again. Like a VM that is rebooted, and
> > continues writing to a disk backed by a file on the host.
> >
> > Do you think, in those cases this might still be useful?
> 
> Those cases do indeed defeat the current per-task-limit, however I think
> the solution to that is to limit the amount of writeback done by each
> blocked process.
> 

Blocked on what? Sorry, I do not understand.

Thanks
Nikanth

> Jan Kara had some good ideas in that department.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
