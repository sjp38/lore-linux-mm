Date: Mon, 11 Jun 2007 10:56:56 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 10 of 16] stop useless vm trashing while we wait the
 TIF_MEMDIE task to exit
In-Reply-To: <20070611175130.GL7443@v2.random>
Message-ID: <Pine.LNX.4.64.0706111055140.17264@schroedinger.engr.sgi.com>
References: <24250f0be1aa26e5c6e3.1181332988@v2.random>
 <Pine.LNX.4.64.0706081446200.3646@schroedinger.engr.sgi.com>
 <20070609015944.GL9380@v2.random> <Pine.LNX.4.64.0706082000370.5145@schroedinger.engr.sgi.com>
 <20070609140552.GA7130@v2.random> <20070609143852.GB7130@v2.random>
 <Pine.LNX.4.64.0706110905080.15326@schroedinger.engr.sgi.com>
 <20070611165032.GJ7443@v2.random> <Pine.LNX.4.64.0706110952001.16068@schroedinger.engr.sgi.com>
 <20070611175130.GL7443@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jun 2007, Andrea Arcangeli wrote:

> Did you measure it or this is just your imagination? I don't buy your
> hypothetical "several hours spent in oom_kill.c" numbers. How long
> does "ls /proc" takes? Can your run top at all?

These are customer reports. 4 hours one and another 2 hours. I can 
certainly get more reports if I ask them for more details. I will get this 
on your SUSE radar.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
