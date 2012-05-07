Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 725556B004D
	for <linux-mm@kvack.org>; Mon,  7 May 2012 18:01:57 -0400 (EDT)
Date: Tue, 8 May 2012 00:01:42 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 00/10] (no)bootmem bits for 3.5
Message-ID: <20120507220142.GA1202@cmpxchg.org>
References: <1336390672-14421-1-git-send-email-hannes@cmpxchg.org>
 <20120507204113.GD10521@merkur.ravnborg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120507204113.GD10521@merkur.ravnborg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gavin Shan <shangw@linux.vnet.ibm.com>, David Miller <davem@davemloft.net>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 07, 2012 at 10:41:13PM +0200, Sam Ravnborg wrote:
> Hi Johannes.
> 
> > here are some (no)bootmem fixes and cleanups for 3.5.  Most of it is
> > unifying allocation behaviour across bootmem and nobootmem when it
> > comes to respecting the specified allocation address goal and numa.
> > 
> > But also refactoring the codebases of the two bootmem APIs so that we
> > can think about sharing code between them again.
> 
> Could you check up on CONFIG_HAVE_ARCH_BOOTMEM use in bootmem.c too?
> x86 no longer uses bootmem.c
> avr define it - but to n.
> 
> So no-one is actually using this anymore.
> I have sent patches to remove it from Kconfig for both x86 and avr.
> 
> I looked briefly at cleaning up bootmem.c myslef - but I felt not
> familiar enough with the code to do the cleanup.
> 
> I did not check your patchset - but based on the shortlog you
> did not kill HAVE_ARCH_BOOTMEM.

It was used on x86-32 numa to try all bootmem allocations from node 0
first (see only remaining definition of bootmem_arch_preferred_node),
which AFAICS nobootmem no longer respects.

Shouldn't this be fixed instead?

But yeah, we can remove the bootmem.c parts, I think.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
