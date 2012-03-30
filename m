Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 74B7C6B0044
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 22:19:58 -0400 (EDT)
Date: Fri, 30 Mar 2012 03:19:45 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 00/16] mm: prepare for converting vm->vm_flags to 64-bit
Message-ID: <20120330021945.GT6589@ZenIV.linux.org.uk>
References: <20120321065140.13852.52315.stgit@zurg>
 <20120321100602.GA5522@barrios>
 <4F69D496.2040509@openvz.org>
 <20120322142647.42395398.akpm@linux-foundation.org>
 <20120322212810.GE6589@ZenIV.linux.org.uk>
 <4F6CA298.4000301@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F6CA298.4000301@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, khlebnikov@openvz.org, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, hughd@google.com, benh@kernel.crashing.org, linux@arm.linux.org.uk

On Fri, Mar 23, 2012 at 12:19:36PM -0400, KOSAKI Motohiro wrote:
> On 3/22/2012 5:28 PM, Al Viro wrote:
> > On Thu, Mar 22, 2012 at 02:26:47PM -0700, Andrew Morton wrote:
> >> It would be nice to find some way of triggering compiler warnings or
> >> sparse warnings if someone mixes a 32-bit type with a vm_flags_t.  Any
> >> thoughts on this?
> >>
> >> (Maybe that's what __nocast does, but Documentation/sparse.txt doesn't
> >> describe it)
> > 
> > Use __bitwise for that - check how gfp_t is handled.
> 
> Hmm..
> 
> If now we activate __bitwise, really plenty driver start create lots warnings.
> Does it make sense?

Huh?  Why would they?  Just adjust definitions of VM_... to include
force-cast to vm_flags_t and we should be OK...

> In fact, x86-32 keep 32bit vma_t forever. thus all x86 specific driver don't
> need any change. Moreover many ancient drivers has no maintainer and I can't
> expect such driver will be fixed even though a warning occur.

What warning?  If something does manual vma->vm_flags = 0xwhatever, then yes,
we do want it dealt with.  If it's vma->vm_flags |= VM_something, there should
be no warnings at all...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
