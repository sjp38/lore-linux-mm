Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 9CFC46B0005
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 03:08:33 -0500 (EST)
Received: by mail-oa0-f52.google.com with SMTP id k14so1030543oag.11
        for <linux-mm@kvack.org>; Wed, 13 Feb 2013 00:08:32 -0800 (PST)
Message-ID: <1360742910.1473.10.camel@kernel.cn.ibm.com>
Subject: Re: [LSF/MM TOPIC] In-kernel compression in the MM subsystem
From: Simon Jeons <simon.jeons@gmail.com>
Date: Wed, 13 Feb 2013 02:08:30 -0600
In-Reply-To: <73fe6782-21f4-47c5-886f-367374a3e600@default>
References: <601542b0-4c92-4d90-aed8-826235c06eab@default>
	 <1360117134.2403.4.camel@kernel.cn.ibm.com>
	 <73fe6782-21f4-47c5-886f-367374a3e600@default>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

On Wed, 2013-02-06 at 10:40 -0800, Dan Magenheimer wrote:
> > From: Simon Jeons [mailto:simon.jeons@gmail.com]
> > Subject: Re: [LSF/MM TOPIC] In-kernel compression in the MM subsystem
> > 
> > Hi Dan,
> > On Sat, 2013-01-26 at 12:16 -0800, Dan Magenheimer wrote:
> > > There's lots of interesting things going on in kernel memory
> > > management, but one only(?) increases the effective amount
> > > of data that can be stored in a fixed amount of RAM: in-kernel
> > > compression.
> > >
> > > Since ramzswap/compcache (now zram) was first proposed in 2009
> > > as an in-memory compressed swap device, there have been a number
> > > of in-kernel compression solutions proposed, including
> > > zcache, kztmem, and now zswap.  Each shows promise to improve
> > > performance by using compression under memory pressure to
> > > reduce I/O due to swapping and/or paging.  Each is still
> > > in staging (though zram may be promoted by LSFMM 2013)
> > > because each also brings a number of perplexing challenges.
> > >
> > > I think it's time to start converging on which one or more
> > > of these solutions, if any, should be properly promoted and
> > > more fully integrated into the kernel memory management
> > > subsystem.  Before this can occur, it's important to build a
> > > broader understanding and, hopefully, also a broader consensus
> > > among the MM community on a number of key challenges and questions
> > > in order to guide and drive further development and merging.
> > >
> > > I would like to collect a list of issues/questions, and
> > > start a discussion at LSF/MM by presenting this list, select
> > > the most important, then lead a discussion on how ever many
> > > there is time for.  Most likely this is an MM-only discussion
> > > though a subset might be suitable for a cross-talk presentataion.
> > >
> > 
> > Is there benchmark to test each component in tmem?
> 
> Hi Simon --
> 
> I'm not sure what you mean.  Could you add a few words
> to clarify?
> 

Hi Dan,

Some questions about zsmalloc:

1) What's the meaning of comment above USE_PGTABLE_MAPPING macro "This
cause zsmalloc to use page table mapping rather than copying for object
mapping"? 
2) How zsmalloc handle object span two pages? It seems that in function
init_zspage, link->next = obj_location_to_handle(next_page, 0); you
encode next_page and 0 to object, then how can zs_malloc find this free
object? IIUC, this encode skip the object span two pages.
3) Why must map after malloc if want to use a object? 
4) What's the number of ZS_MAX_ALLOC_SIZE and ZS_MIN_ALLOC_SIZE? There
are too many macros to figure it out.

Thanks,
Simon


> Thanks,
> Dan


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
