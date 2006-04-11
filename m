Date: Tue, 11 Apr 2006 10:28:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] [PATCH] support for oom_die
In-Reply-To: <20060411142909.1899c4c4.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0604111025110.564@schroedinger.engr.sgi.com>
References: <20060411142909.1899c4c4.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 11 Apr 2006, KAMEZAWA Hiroyuki wrote:

> I think 2.6 kernel is very robust against OOM situation but sometimes
> it occurs. Yes, oom_kill works enough and exit oom situation, *when*
> the system wants to survive.
> 
> First, crash-dump is merged (to -mm?). So panic at OOM can be a method to
> preserve *all* information at OOM. Current OOM killer kills process by SIGKILL,
> this doesn't preserve any information about OOM situation. Just message log tell
> something and we have to imagine what happend.
> 
> Second, considering clustering system, it has a failover node replacement 
> system. Because oom_killer tends to kill system slowly, one by one, to detect 
> it and do failover(or not) at OOM is tend to be difficult. (as far as I know)
> Panic at OOM is useful in such system because failover system can replace
> the node immediately.
> 
> I'm sorry if this kind of discussion has been setteled in past.

A user process can cause an oops by using too much memory? Would it not be 
better to terminate the rogue process instead? Otherwise any user can 
bring down the system?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
