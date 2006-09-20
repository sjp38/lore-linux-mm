Message-ID: <451173B5.1000805@yahoo.com.au>
Date: Thu, 21 Sep 2006 03:00:37 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch00/05]: Containers(V2)- Introduction
References: <1158718568.29000.44.camel@galaxy.corp.google.com>	 <4510D3F4.1040009@yahoo.com.au> <1158751720.8970.67.camel@twins>	 <4511626B.9000106@yahoo.com.au> <1158767787.3278.103.camel@taijtu>
In-Reply-To: <1158767787.3278.103.camel@taijtu>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: rohitseth@google.com, CKRM-Tech <ckrm-tech@lists.sourceforge.net>, devel@openvz.org, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

(this time to the lists as well)

Peter Zijlstra wrote:

 > I'd much rather containterize the whole reclaim code, which should not
 > be too hard since he already adds a container pointer to struct page.


Yes, and I tend to agree with you. I probably wasn't clear, but I was
mainly talking about just the memory resource tracking part of this
patchset.

I am less willing to make a judgement about reclaim, because I don't
know very much about the workloads or the guarantees they attempt to
provide.

 > Esp. when we get some of my page reclaim abstractions merged, moving the
 > reclaim from struct zone to a container is not a lot of work. (this is
 > basically what one of the ckrm mm policies did too)


I do agree that it would be nicer to not have a completely different
scheme for doing their own page reclaim, but rather use the existing
code (*provided* that it is designed in the same, minimally intrusive
manner as the page tracking).

I can understand how it is attractive to create a new subsystem to
solve a particular problem, but once it is in the kernel it has to be
maintained regardless, so if it can be done in a way that shares more
of the current infrastructure (nicely) then that would be a better
solution.

I like that they're investigating the use of memory nodes for this.
It seems like the logical starting place.

 > I still have to reread what Rohit does for file backed pages, that gave
 > my head a spin.
 > I've been thinking a bit on that problem, and it would be possible to
 > share all address_space pages equally between attached containers, this
 > would lose some accuracy, since one container could read 10% of the file
 > and another 90%, but I don't think that is a common scenario.


Yeah, I'm not sure about that. I don't think really complex schemes
are needed... but again I might need more knowledge of their workloads
and problems.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
