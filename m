Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B08C86B0044
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 09:51:11 -0500 (EST)
Date: Fri, 23 Jan 2009 16:06:32 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch] SLQB slab allocator
Message-ID: <20090123150632.GS15750@one.firstfloor.org>
References: <20090121143008.GV24891@wotan.suse.de> <87hc3qcpo1.fsf@basil.nowhere.org> <20090123112555.GF19986@wotan.suse.de> <20090123115731.GO15750@one.firstfloor.org> <20090123131800.GH19986@wotan.suse.de> <20090123140406.GR15750@one.firstfloor.org> <20090123142753.GK19986@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090123142753.GK19986@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 23, 2009 at 03:27:53PM +0100, Nick Piggin wrote:
>  
> > Although I think I would prefer alloc_percpu, possibly with
> > per_cpu_ptr(first_cpu(node_to_cpumask(node)), ...)
> 
> I don't think we have the NUMA information available early enough
> to do that. 

How early? At mem_init time it should be there because bootmem needed
it already. It meaning the architectural level NUMA information.

> OK, but if it is _possible_ for the node to gain memory, then you
> can't do that of course. 

In theory it could gain memory through memory hotplug.

> > I'm sure such a straight forward change could be still put into .29
> > 
> > > reasonable to merge. But it would be a fine cleanup.
> > 
> > Hmm to be honest it's a little weird to post so much code and then
> > say you can't change large parts of it.
> 
> The cache_line_size() change wouldn't change slqb code significantly.
> I have no problem with it, but I simply won't have time to do it and
> test all architectures and get them merged and hold off merging
> SLQB until they all get merged.

I was mainly refering to the sysfs code here.
 
 
> > Could you perhaps mark all the code you don't want to change?
> 
> Primarily the debug code from SLUB.

Ok so you could fix the sysfs code? @)

Anyways, if you have such shared pieces perhaps it would be better
if you just pull them all out into a separate file. 

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
