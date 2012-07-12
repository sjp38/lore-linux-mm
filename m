Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id A2DEC6B005C
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 06:40:38 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so1532978qcs.14
        for <linux-mm@kvack.org>; Thu, 12 Jul 2012 03:40:37 -0700 (PDT)
Date: Thu, 12 Jul 2012 06:40:30 -0400
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Subject: Re: [PATCH 0/4] zsmalloc improvements
Message-ID: <20120712104029.GA3920@konrad-lan.dumpdata.com>
References: <1341263752-10210-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <20120704204325.GB2924@localhost.localdomain>
 <4FF6FF1F.5090701@linux.vnet.ibm.com>
 <4FFAE37F.70403@linux.vnet.ibm.com>
 <CAPbh3rtXVf_GPKZ2dA2nWaj=h6aYztntQ-oFD5Pg0j65BbOvmA@mail.gmail.com>
 <4FFDE69C.8080205@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FFDE69C.8080205@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Wed, Jul 11, 2012 at 03:48:28PM -0500, Seth Jennings wrote:
> On 07/11/2012 02:42 PM, Konrad Rzeszutek Wilk wrote:
> >>>> Which architecture was this under? It sounds x86-ish? Is this on
> >>>> Westmere and more modern machines? What about Core2 architecture?
> >>>>
> >>>> Oh how did it work on AMD Phenom boxes?
> >>>
> >>> I don't have a Phenom box but I have an Athlon X2 I can try out.
> >>> I'll get this information next Monday.
> >>
> >> Actually, I'm running some production stuff on that box, so
> >> I rather not put testing stuff on it.  Is there any
> >> particular reason that you wanted this information? Do you
> >> have a reason to believe that mapping will be faster than
> >> copy for AMD procs?
> > 
> > Sorry for the late response. Working on some ugly bug that is taking
> > more time than anticipated.
> > My thoughts were that these findings are based on the hardware memory
> > prefetcher. The Intel
> > machines - especially starting with Nehelem have some pretty
> > impressive prefetcher where
> > even doing in a linked list 'prefetch' on the next node is not beneficial.
> > 
> > Perhaps the way to leverage this is to use different modes depending
> > on the bulk of data?
> > When there is a huge amount use the old method, but for small use copy
> > (as it would
> > in theory stay in the cache longer).
> 
> Not sure what you mean by "bulk" or "huge amount" but the
> maximum size of mapped object is PAGE_SIZE and the typical
> size more around PAGE_SIZE/2. So that is what I'm
> considering.  Do you think it makes a difference with copies
> that small?

I was thinking in terms of time. So if there are many requests coming
in at some threshold, then use one method.
> 
> Thanks,
> Seth
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
