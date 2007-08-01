Message-ID: <385932021.25311@ustc.edu.cn>
Date: Wed, 1 Aug 2007 09:22:22 +0800
From: Fengguang Wu <fengguang.wu@gmail.com>
Subject: Re: make swappiness safer to use
Message-ID: <20070801012222.GA20565@mail.ustc.edu.cn>
References: <20070731215228.GU6910@v2.random> <20070731151244.3395038e.akpm@linux-foundation.org> <20070731224052.GW6910@v2.random> <20070731155109.228b4f19.akpm@linux-foundation.org> <20070731230251.GX6910@v2.random> <20070801011925.GB20109@mail.ustc.edu.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070801011925.GB20109@mail.ustc.edu.cn>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 01, 2007 at 09:19:25AM +0800, Fengguang Wu wrote:
> > +		imbalance *= (vm_swappiness + 1) / 100;
>                              ~~~~~~~~~~~~~~~~~~~~~~~~~ It will be zero!
> 
> Better to scale it up before the division:
> 		imbalance *= (vm_swappiness + 1) * 1024 / 100;
> 
> > +
> > +		/*
> > +		 * If not much of the ram is mapped, makes the imbalance
> > +		 * less relevant, it's high priority we refill the inactive
> > +		 * list with mapped pages only in presence of high ratio of
> > +		 * mapped pages.
> > +		 *
> > +		 * Max temporary value is vm_total_pages*100.
> > +		 */
> > +		imbalance *= mapped_ratio / 100;
> 
> 		imbalance *= mapped_ratio * 1024 / 100;
> 
> > +		/* apply imbalance feedback to swap_tendency */
> > +		swap_tendency += imbalance;
> 
> 		swap_tendency += imbalance / 1024 / 1024;

Or simply move the two ' / 100' to this last line?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
