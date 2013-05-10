Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 0A29A6B0034
	for <linux-mm@kvack.org>; Fri, 10 May 2013 04:44:15 -0400 (EDT)
Date: Fri, 10 May 2013 17:44:13 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3] mm: remove compressed copy from zram in-memory
Message-ID: <20130510084413.GA2683@blaptop>
References: <1368056517-31065-1-git-send-email-minchan@kernel.org>
 <20130509201540.GB5273@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130509201540.GB5273@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad@darnok.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Shaohua Li <shli@kernel.org>, Dan Magenheimer <dan.magenheimer@oracle.com>

Hi Konrad,

On Thu, May 09, 2013 at 04:15:42PM -0400, Konrad Rzeszutek Wilk wrote:
> On Thu, May 09, 2013 at 08:41:57AM +0900, Minchan Kim wrote:
> 
> Hey Michan,
        ^-n

It's a only thing I can know better than other native speakers. :)

 
> Just a couple of syntax corrections. The code comment could also
> benefit from this.
> 
> Otherwise it looks OK to me.
> 
> > Swap subsystem does lazy swap slot free with expecting the page
>                      ^-a                       ^- the expectation that
> > would be swapped out again so we can avoid unnecessary write.
>                                 ^--that it
> > 
> > But the problem in in-memory swap(ex, zram) is that it consumes
>                   ^^-with
> > memory space until vm_swap_full(ie, used half of all of swap device)
> > condition meet. It could be bad if we use multiple swap device,
>            ^- 'is'   ^^^^^ - 'would'                       ^^^^^-devices                    
> > small in-memory swap and big storage swap or in-memory swap alone.
>                       ^-,                   ^-,
> > 
> > This patch makes swap subsystem free swap slot as soon as swap-read
> > is completed and make the swapcache page dirty so the page should
>                        ^-makes                      ^-'that the'
> > be written out the swap device to reclaim it.
> > It means we never lose it.
> > 
> > I tested this patch with kernel compile workload.
>                           ^-a

Thanks for the correct whole sentence!
But Andrew alreay correted it with his style.
Although he was done, I'm giving a million thanks to you.
Surely, Thanks Andrew, too.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
