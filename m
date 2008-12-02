Date: Tue, 2 Dec 2008 16:11:42 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] fs: shrink struct dentry
Message-ID: <20081202151141.GC3235@wotan.suse.de>
References: <20081201083343.GC2529@wotan.suse.de> <20081201175113.GA16828@totally.trollied.org.uk> <20081201180455.GJ10790@wotan.suse.de> <20081201193818.GB16828@totally.trollied.org.uk> <20081202070608.GA28080@wotan.suse.de> <20081202130410.GA24222@totally.trollied.org.uk> <20081202134926.GA3235@wotan.suse.de> <20081202144918.GB24222@totally.trollied.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081202144918.GB24222@totally.trollied.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Levon <levon@movementarian.org>
Cc: linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, robert.richter@amd.com, oprofile-list@lists.sf.net
List-ID: <linux-mm.kvack.org>

On Tue, Dec 02, 2008 at 02:49:18PM +0000, John Levon wrote:
> On Tue, Dec 02, 2008 at 02:49:26PM +0100, Nick Piggin wrote:
> 
> > > I can't believe I'm having to argue that you need to test your code. So
> > > I think I'll stop.
> > 
> > Code was tested. It doesn't affect my normal oprofile usage (it's
> > utterly within the noise, in case that wasn't obvious to you).
> 
> Then, heck, why didn't you say so?! I just went and read the whole
> exchange and this is the first time you actually stated you tested the
> impact of your patch on oprofile overhead.

This was just in running some silly benchmark like oprofile+tbench,
but I'm fairly sure it a) probably didn't have many entries in the
cookies cache -- at least not enough to create big hash chains, and
b) wasn't hitting get_dcookie very often, and c) AFAIKS, all paths to
get_dcookie go through fast_get_dcookie so I actually can't see any
possible way that this patch could increase the number of hash lookups
anyway.

Given that, I was 99.9% sure it will be OK. But I like confirmation
from you.

I didn't do any major test where I try to force thousands of entries
into dcookie subsystem or anything, but if you care to give a test
case I can try.

mmap_sem and find_vma is much more annoying in oprofile :) Speaking of
which: is there a mode it can be set in to do kernel only profiling so
it does not bother with userspace samples at all? That would be really
nice for profiling the kernel in the kinds of workloads that hit
mmap_sem and vma cache often because oprofile interferes with that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
