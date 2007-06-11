Date: Mon, 11 Jun 2007 20:22:32 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH 10 of 16] stop useless vm trashing while we wait the TIF_MEMDIE task to exit
Message-ID: <20070611182232.GN7443@v2.random>
References: <Pine.LNX.4.64.0706081446200.3646@schroedinger.engr.sgi.com> <20070609015944.GL9380@v2.random> <Pine.LNX.4.64.0706082000370.5145@schroedinger.engr.sgi.com> <20070609140552.GA7130@v2.random> <20070609143852.GB7130@v2.random> <Pine.LNX.4.64.0706110905080.15326@schroedinger.engr.sgi.com> <20070611165032.GJ7443@v2.random> <Pine.LNX.4.64.0706110952001.16068@schroedinger.engr.sgi.com> <20070611175130.GL7443@v2.random> <Pine.LNX.4.64.0706111055140.17264@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706111055140.17264@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 11, 2007 at 10:56:56AM -0700, Christoph Lameter wrote:
> On Mon, 11 Jun 2007, Andrea Arcangeli wrote:
> 
> > Did you measure it or this is just your imagination? I don't buy your
> > hypothetical "several hours spent in oom_kill.c" numbers. How long
> > does "ls /proc" takes? Can your run top at all?
> 
> These are customer reports. 4 hours one and another 2 hours. I can 

How long does "ls /proc" take? Can you run top at all on such a
system (I mean before it reaches the oom point, then it'll hang for
those 4 hours with the mainline kernel, I know this and that's why I
worked to fix it and posted 18 patches so far about it).

> certainly get more reports if I ask them for more details. I will get this 
> on your SUSE radar.

If it takes 4 hours for the function out_of_memory to return, please
report it. If instead as I start to suspect, you're going to show me
the function out_of_memory called one million times and taking a few
seconds for each invocation, please test all my fixes before
reporting, there's a reason I made those changes...

Back to the local-oom: if out_of_memory takes a couple of seconds at
most as I expect (it'll be the same order of ls /proc, actually ls
/proc will be a lot slower), killing the current task in the local-oom
as a performance optimization remains a very dubious argument.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
