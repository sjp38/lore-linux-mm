Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 09EF46B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 21:36:09 -0400 (EDT)
Date: Tue, 9 Apr 2013 10:36:06 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: zsmalloc defrag (Was: [PATCH] mm: remove compressed copy from
 zram in-memory)
Message-ID: <20130409013606.GC3467@blaptop>
References: <1365400862-9041-1-git-send-email-minchan@kernel.org>
 <f3c8ef05-a880-47db-86dd-156038fc7d0f@default>
 <20130409012719.GB3467@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130409012719.GB3467@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Shaohua Li <shli@kernel.org>, Bob Liu <bob.liu@oracle.com>, Shuah Khan <shuah@gonehiking.org>

On Tue, Apr 09, 2013 at 10:27:19AM +0900, Minchan Kim wrote:
> Hi Dan,
> 
> On Mon, Apr 08, 2013 at 09:32:38AM -0700, Dan Magenheimer wrote:
> > > From: Minchan Kim [mailto:minchan@kernel.org]
> > > Sent: Monday, April 08, 2013 12:01 AM
> > > Subject: [PATCH] mm: remove compressed copy from zram in-memory
> > 
> > (patch removed)
> > 
> > > Fragment ratio is almost same but memory consumption and compile time
> > > is better. I am working to add defragment function of zsmalloc.
> > 
> > Hi Minchan --
> > 
> > I would be very interested in your design thoughts on
> > how you plan to add defragmentation for zsmalloc.  In
> 
> What I can say now about is only just a word "Compaction".
> As you know, zsmalloc has a transparent handle so we can do whatever
> under user. Of course, there is a tradeoff between performance 
> and memory efficiency. I'm biased to latter for embedded usecase.
> 
> And I might post it because as you know well, zsmalloc

Incomplete sentense,

I might not post it until promoting zsmalloc because as you know well,
zsmalloc/zram's all new stuffs are blocked into staging tree.
Even if we could add it into staging, as you know well, staging is where
every mm guys ignore so we end up needing another round to promote it. sigh.

I hope it gets better after LSF/MM.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
