Date: Thu, 3 Jul 2008 19:01:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2.6.26-rc8-mm1] memrlimit: fix mmap_sem deadlock
Message-Id: <20080703190123.1d72e9d1.akpm@linux-foundation.org>
In-Reply-To: <486D81B9.9030704@linux.vnet.ibm.com>
References: <Pine.LNX.4.64.0807032143110.10641@blonde.site>
	<20080703160117.b3781463.akpm@linux-foundation.org>
	<486D81B9.9030704@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Hugh Dickins <hugh@veritas.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 04 Jul 2008 07:19:45 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Andrew Morton wrote:
> > There doesn't seem to have been much discussion regarding your recent
> > objections to the memrlimit patches.  But it caused me to put a big
> > black mark on them.  Perhaps sending it all again would be helpful.
> 
> Black marks are not good, but there have been some silly issues found with them.
> I have been addressing/answering concerns raised so far. Would you like me to
> fold all patches and fixes and send them out for review again?
> 
> 

I was referring to the below (which is where the conversation ended).

It questions the basis of the whole feature.


On Wed, 25 Jun 2008 06:31:05 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Hugh Dickins wrote:
> 
> ...
>
> > (In passing, I'll add that I'm not a great fan of these memrlimits:
> > to me it's loony to be charging people for virtual address space,
> > it's _virtual_, and process A can have as much as it likes without
> > affecting process B in any way.  You're following the lead of RLIMIT_AS,
> > but I've always thought RLIMIT_AS a lame attempt to move into the mmap
> > decade, after RLIMIT_DATA and RLIMIT_STACK no longer made sense.
> > 
> > Taking Alan Cox's Committed_AS as a limited resource charged per mm makes
> > much more sense to me: but yes, it's not perfect, and it is a lot harder
> > to get its accounting right, and to maintain that down the line.  Okay,
> > you've gone for the easier option of tracking total_vm, getting that
> > right is a more achievable target.  And I accept that I may be too
> > pessimistic about it: total_vm may often enough give a rough
> > approximation to something else worth limiting.)
> 
> You seem to have read my mind, my motivation for memrlimits is
> 
> 1. Administrators to set a limit and be sure that a cgroup cannot consume more
> swap + RSS than the assigned virtual memory limit
> 2. It allows applications to fail gracefully or decide what parts to free up
> to get more memory or change their allocation pattern (a scientific application
> deciding what size of matrix to allocate for example).
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
