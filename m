Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C2DEA8D0001
	for <linux-mm@kvack.org>; Fri, 12 Nov 2010 11:22:47 -0500 (EST)
Subject: Re: [PATCH/RFC] MM slub: add a sysfs entry to show the calculated
 number of fallback slabs
From: Richard Kennedy <richard@rsk.demon.co.uk>
In-Reply-To: <alpine.DEB.2.00.1011120911310.11746@router.home>
References: <1289561309.1972.30.camel@castor.rsk>
	 <alpine.DEB.2.00.1011120911310.11746@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 12 Nov 2010 16:22:44 +0000
Message-ID: <1289578964.1972.43.camel@castor.rsk>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2010-11-12 at 09:13 -0600, Christoph Lameter wrote:
> On Fri, 12 Nov 2010, Richard Kennedy wrote:
> 
> > On my desktop workloads (kernel compile etc) I'm seeing surprisingly
> > little slab fragmentation. Do you have any suggestions for test cases
> > that will fragment the memory?
> 
> Do a massive scan through huge amounts of files that triggers inode and
> dentry reclaim?

thanks, I'll give it a try.

> > + * Note that this can give the wrong answer if the user has changed the
> > + * order of this slab via sysfs.
> 
> Not good. Maybe have an additional counter in kmem_cache_node instead?


I know it's not ideal. Of course there already is a counter in
CONFIG_SLUB_STATS but it only counts the total number of fallback slabs
issued since boot time.
I'm not sure if I can reliably decrement a fallback counter when a slab
get freed. If the size was changed then we could have slabs with several
different sizes, and off the top of my head I'm not sure if I can
identify which ones were created as fallback slabs. I don't suppose
there's a spare flag anywhere. 

I'll give this some more thought.

regards
Richard   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
