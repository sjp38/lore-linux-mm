Date: Sun, 07 Nov 2004 08:11:24 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
Message-ID: <226170000.1099843883@[10.10.2.4]>
In-Reply-To: <Pine.LNX.4.58.0411060812390.25369@schroedinger.engr.sgi.com>
References: <4189EC67.40601@yahoo.com.au>  <Pine.LNX.4.58.0411040820250.8211@schroedinger.engr.sgi.com><418AD329.3000609@yahoo.com.au>  <Pine.LNX.4.58.0411041733270.11583@schroedinger.engr.sgi.com><418AE0F0.5050908@yahoo.com.au>  <418AE9BB.1000602@yahoo.com.au><1099622957.29587.101.camel@gaston><418C55A7.9030100@yahoo.com.au> <Pine.LNX.4.58.0411060120190.22874@schroedinger.engr.sgi.com><204290000.1099754257@[10.10.2.4]> <Pine.LNX.4.58.0411060812390.25369@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>> I would've thought SGI would be more worried about this kind of thing
>> than anyone else ... what's going to happen when you type 'ps' on a large
>> box, and it does this for 10,000 processes?
> 
> Yes but I think this is preferable because of the generally faster
> operations of the vm without having to continually update statistics. And
> these statistics seem to be quite difficult to properly generate (why else
> introduce anon_rss). Without the counters other optimizations are easier
> to do.
> 
> Doing a ps is not a frequent event. Of course this may cause
> significant load if one does regularly access /proc entities then. Are
> there any threads from the past with some numbers of what the impact was
> when we calculated rss via proc?

Doing ps or top is not unusual at all, and the sysadmins should be able
to monitor their system in a reasonable way without crippling it, or even
effecting it significantly.
 
>> If you want to make it quicker, how about doing per-cpu stats, and totalling
>> them at runtime, which'd be lockless, instead of all the atomic ops?
> 
> That has its own complications and would require lots of memory with
> systems that already have up to 10k cpus.

Ummm 10K cpus? I hope that's a typo for processes, or this discussion is
getting rather silly ....

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
