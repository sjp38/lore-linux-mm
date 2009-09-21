Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B05A66B012D
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 05:17:49 -0400 (EDT)
Date: Mon, 21 Sep 2009 11:17:53 +0200 (CEST)
From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: BUG: sleeping function called from invalid context at
 mm/slub.c:1717
In-Reply-To: <28c262360909160016m19edee02g9215669f854e1026@mail.gmail.com>
Message-ID: <alpine.LNX.2.00.0909211114400.17028@wotan.suse.de>
References: <20090915085441.GF23126@kernel.dk>  <alpine.LNX.2.00.0909151202560.17028@wotan.suse.de> <28c262360909160016m19edee02g9215669f854e1026@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 16 Sep 2009, Minchan Kim wrote:

> We have to change description of hid_input_report.
> 
>  * @interrupt: called from atomic?
> I think it lost meaning.

Good point, I will change it, thanks.

> I am worried that interrupt variable is propagated down to sub 
> functions. Is it right on sub functions?

Yes. This variable is not used for chosing correct allocation flags 
anywhere else, it is just carrying the semantics what the HID core should 
do, what callbacks to call, etc. So it's correct.
But you are right that the name and kerneldocs is confusing, and I will 
fix that.

> One more thing, I am concerned about increasing GFP_ATOMIC customers 
> although we can avoid it. Is it called rarely? Could you find a 
> alternative method to overcome this issue?

This is just a temporary buffer for debugging output, it is freed almost 
immediately later in the function, and even if the allocation fails, 
nothing bad happens (just the debugging output is not delivered to the 
debugfs buffer).

Thanks,

-- 
Jiri Kosina
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
