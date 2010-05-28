Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8B8EE6B01B4
	for <linux-mm@kvack.org>; Fri, 28 May 2010 11:04:08 -0400 (EDT)
Received: by pzk28 with SMTP id 28so845009pzk.11
        for <linux-mm@kvack.org>; Fri, 28 May 2010 08:04:06 -0700 (PDT)
Date: Sat, 29 May 2010 00:03:56 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
Message-ID: <20100528150356.GA12035@barrios-desktop>
References: <20100528143605.7E2A.A69D9226@jp.fujitsu.com>
 <AANLkTikB-8Qu03VrA5Z0LMXM_alSV7SLqzl-MmiLmFGv@mail.gmail.com>
 <20100528145329.7E2D.A69D9226@jp.fujitsu.com>
 <20100528125305.GE11364@uudg.org>
 <20100528140623.GA11041@barrios-desktop>
 <20100528142048.GF5579@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100528142048.GF5579@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, May 28, 2010 at 07:50:48PM +0530, Balbir Singh wrote:
> * MinChan Kim <minchan.kim@gmail.com> [2010-05-28 23:06:23]:
> 
> > > I confess I failed to distinguish memcg OOM and system OOM and used "in
> > > case of OOM kill the selected task the faster you can" as the guideline.
> > > If the exit code path is short that shouldn't be a problem.
> > > 
> > > Maybe the right way to go would be giving the dying task the biggest
> > > priority inside that memcg to be sure that it will be the next process from
> > > that memcg to be scheduled. Would that be reasonable?
> > 
> > Hmm. I can't understand your point. 
> > What do you mean failing distinguish memcg and system OOM?
> > 
> > We already have been distinguish it by mem_cgroup_out_of_memory.
> > (but we have to enable CONFIG_CGROUP_MEM_RES_CTLR). 
> > So task selected in select_bad_process is one out of memcg's tasks when 
> > memcg have a memory pressure. 
> >
> 
> We have a routine to help figure out if the task belongs to the memory
> cgroup that cause the OOM. The OOM entry from memory cgroup is
> different from a regular one. 

I meant it. 
My english is poor. "out of" isn't proper. 

> 
> -- 
> 	Three Cheers,
> 	Balbir

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
