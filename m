Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0531D8D0039
	for <linux-mm@kvack.org>; Fri, 11 Feb 2011 11:29:38 -0500 (EST)
Date: Fri, 11 Feb 2011 11:22:18 -0500
Subject: Re: [LSF/MM TOPIC] Writeback - current state and future
From: sfaibish <sfaibish@emc.com>
Content-Type: text/plain; format=flowed; delsp=yes; charset=iso-8859-15
MIME-Version: 1.0
References: <20110204164222.GG4104@quack.suse.cz> <4D4E7B48.9020500@panasas.com> <op.vqhlw3rirwwil4@sfaibish1.corp.emc.com> <20110211144717.GH5187@quack.suse.cz>
Content-Transfer-Encoding: 8bit
Message-ID: <op.vqqyfgtmunckof@usensfaibisl2e.eng.emc.com>
In-Reply-To: <20110211144717.GH5187@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Boaz Harrosh <bharrosh@panasas.com>, lsf-pc@lists.linuxfoundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>

On Fri, 11 Feb 2011 09:47:17 -0500, Jan Kara <jack@suse.cz> wrote:

> On Sun 06-02-11 10:13:41, Sorin Faibish wrote:
>> I was thinking to have a special track for all the writeback related
>> topics.
>   Well, a separate track might be a bit too much I feel ;). I'm  
> interested
> also in other things that are happening... We'll see what the program  
> will
> be but I can imagine we can discuss for a couple of hours but that might  
> be
> just a discussion in a small circle over a <enter preferable drink>.
No problem. I pay for the beer. :) You make the expert pick.

>
>> I would like also to include a discussion on new cache writeback paterns
>> with the target to prevent any cache swaps that are becoming a
>> bigger problem
>> when dealing with servers wir 100's GB caches. The swap is the worst  
>> that
>> could happen to the performance of such systems. I will share my
>> latest findings
>> in the cache writeback in continuation to my previous discussion at
>> last LSF.
>   I'm not sure what do you exactly mean by 'cache swaps'. If you mean  
> that
> your application private cache is swapped out, then I can imagine this  
> is a
> problem but I'd need more details to tell how big.
What I meant is to prevent any global cache swap. Think that you have to  
SWAP
256GB of cache to a 120MB/sec SATA disk. How long it will take? Cannot be
tolerated. Even if you use SSD at say 1GB/sec it is still a long time. Not
typical but common in HPC. I am not sure you saw my latest results but I
had an example where the swap was taking a long time to the point that a
build on a small memory system didn't finish. The good news are that the
latest kernels 37 RC3 made progress. I have additional data to present.
I will present the latest results next week at FAST conference.

/Sorin

>
> 									Honza



-- 
Best Regards

Sorin Faibish
Corporate Distinguished Engineer
Unified Storage Division
         EMC2
where information lives

Phone: 508-249-5745
Cellphone: 617-510-0422
Email : sfaibish@emc.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
