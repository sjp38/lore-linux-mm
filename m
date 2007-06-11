Date: Mon, 11 Jun 2007 11:39:03 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 10 of 16] stop useless vm trashing while we wait the
 TIF_MEMDIE task to exit
In-Reply-To: <20070611182232.GN7443@v2.random>
Message-ID: <Pine.LNX.4.64.0706111133020.18327@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0706081446200.3646@schroedinger.engr.sgi.com>
 <20070609015944.GL9380@v2.random> <Pine.LNX.4.64.0706082000370.5145@schroedinger.engr.sgi.com>
 <20070609140552.GA7130@v2.random> <20070609143852.GB7130@v2.random>
 <Pine.LNX.4.64.0706110905080.15326@schroedinger.engr.sgi.com>
 <20070611165032.GJ7443@v2.random> <Pine.LNX.4.64.0706110952001.16068@schroedinger.engr.sgi.com>
 <20070611175130.GL7443@v2.random> <Pine.LNX.4.64.0706111055140.17264@schroedinger.engr.sgi.com>
 <20070611182232.GN7443@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jun 2007, Andrea Arcangeli wrote:

> > These are customer reports. 4 hours one and another 2 hours. I can 
> 
> How long does "ls /proc" take? Can you run top at all on such a
> system (I mean before it reaches the oom point, then it'll hang for
> those 4 hours with the mainline kernel, I know this and that's why I
> worked to fix it and posted 18 patches so far about it).

These are big systems and it would take some time to reproduce these 
issues. Thanks for your work. I'd really like to see improvements there. 
If you take care of not worsening the local kill path then I am okay with 
the rest.
 
> > certainly get more reports if I ask them for more details. I will get this 
> > on your SUSE radar.
> 
> If it takes 4 hours for the function out_of_memory to return, please
> report it. If instead as I start to suspect, you're going to show me
> the function out_of_memory called one million times and taking a few
> seconds for each invocation, please test all my fixes before
> reporting, there's a reason I made those changes...

out_of_memory takes about 5-10 minutes each (according to one report). An 
OOM storm will then take the machine out for 4 hours. The on site SE can 
likely tell you more details in the bugzilla.

Another reporter had been waiting for 2 hours after an oom without any 
messages indicating that a single OOM was processed.

> Back to the local-oom: if out_of_memory takes a couple of seconds at
> most as I expect (it'll be the same order of ls /proc, actually ls
> /proc will be a lot slower), killing the current task in the local-oom
> as a performance optimization remains a very dubious argument.

Killing the local process avoids 4 slow scans over a pretty large 
tasklist. But I agree that there may be additionial other issues lurking 
there fore large systems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
