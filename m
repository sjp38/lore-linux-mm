Date: Sat, 6 Nov 2004 13:59:01 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
Message-ID: <20041106125901.GD16434@wotan.suse.de>
References: <4189EC67.40601@yahoo.com.au> <Pine.LNX.4.58.0411040820250.8211@schroedinger.engr.sgi.com> <418AD329.3000609@yahoo.com.au> <Pine.LNX.4.58.0411041733270.11583@schroedinger.engr.sgi.com> <418AE0F0.5050908@yahoo.com.au> <418AE9BB.1000602@yahoo.com.au> <1099622957.29587.101.camel@gaston> <418C55A7.9030100@yahoo.com.au> <Pine.LNX.4.58.0411060120190.22874@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0411060120190.22874@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@kernel.vger.org
List-ID: <linux-mm.kvack.org>

> The patch is by no means perfect. If you think this is worth pursuing then
> I will finish the support for other archs and deal with the locking
> issues etc. This patch may also remove hot spot issues that may arise with
> the use of these two variables and so is of interest to us.

It's probably better to keep the counters. Otherwise there will be massive
slowdown when people run performance monitor applets that read /proc regularly.
We went through this several times already, there used to be some other
/proc field that also walked everything and there were frequent
complaints about it.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
