Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6C0509400BF
	for <linux-mm@kvack.org>; Wed,  5 Oct 2011 12:56:46 -0400 (EDT)
Date: Wed, 5 Oct 2011 09:56:43 -0700
From: Larry Bassel <lbassel@codeaurora.org>
Subject: Re: [Xen-devel] Re: RFC -- new zone type
Message-ID: <20111005165643.GE7007@labbmf-linux.qualcomm.com>
References: <20110928180909.GA7007@labbmf-linux.qualcomm.comCAOFJiu1_HaboUMqtjowA2xKNmGviDE55GUV4OD1vN2hXUf4-kQ@mail.gmail.com>
 <c2d9add1-0095-4319-8936-db1b156559bf@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c2d9add1-0095-4319-8936-db1b156559bf@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-mm@kvack.org, Xen-devel@lists.xensource.com

On 29 Sep 11 09:38, Dan Magenheimer wrote:
[snip]
> 
> You may be interested in the concept of "ephemeral pages"
> introduced by transcendent memory ("tmem") and the cleancache
> patchset which went upstream at 3.0.  If you write a driver
> (called a "backend" in tmem language) that accepts pages
> from cleancache, you would be able to use your 100MB contiguous
> chunk of memory for clean pagecache pages when it is not needed
> for your other purposes, easily discard all the pages when
> you do need the space, then start using it for clean pagecache
> pages again when you don't need it for your purposes anymore
> (and repeat this cycle as many times as necessary).
> 
> You maybe could call your driver "cleanzone".
> 
> Zcache (also upstream in drivers/staging) does something like
> this already, though you might not want/need to use compression
> in your driver.  In zcache, space reclaim is driven by the kernel
> "shrinker" code that runs when memory is low, but another trigger
> could easily be used.  Also there is likely a lot of code in
> zcache (e.g. tmem.c) that you could leverage.
> 
> For more info, see: 
> http://lwn.net/Articles/454795/
> http://oss.oracle.com/projects/tmem 
> 
> I'd be happy to answer any questions if you are still interested
> after you have read the above documentation.

It appears that ephemeral tmem ("cleancache") is at least
close to meeting our needs. We won't need to
have virtualization or compression.

I do have some questions (I've read the references
you included in your email to me last week and a few
of the links from the "project transcendent memory" one, but have
not looked at any of the source yet):

1. Is it currently possible to specify the size of tmem
(as for us it must be convertable into a large contiguous physical
block of specified size)? Is is currently possible to specify
the start of tmem? Are there any alignment constraints on
the start or size?

2. How does one "turn on" and "turn off" tmem (the memory
which tmem uses may also be needed for the large contiguous
memory block, or perhaps may be powered off entirely)?
Is it simply that one always answers "no" for both
get and put requests when it is "off"?

3. How portable is the tmem code? This needs to run
on an ARM system.

4. Apparently hooks are needed in the filesystem code --
which filesystems are currently supported to be used with
tmem? Is it difficult to add hooks for filesystems
that aren't yet supported?

5. There are no dependencies on memory compaction
or memory hotplug (or sparsemem), correct?

Thank you for suggesting tmem and thanks in
advance for answering my questions.

> 
> Thanks,
> Dan
> 

Larry

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
