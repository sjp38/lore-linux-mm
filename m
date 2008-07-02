Date: Wed, 2 Jul 2008 15:44:06 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [PATCH 4/4] capture pages freed during direct reclaim for allocation by the reclaimer
Message-ID: <20080702144406.GB16591@shadowen.org>
References: <1214935122-20828-1-git-send-email-apw@shadowen.org> <1214935122-20828-5-git-send-email-apw@shadowen.org> <20080702182909.D163.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080702182909.D163.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 02, 2008 at 09:01:59PM +0900, KOSAKI Motohiro wrote:
> Hi Andy,
> 
> I feel this is interesting patch.
> 
> but I'm worry about it become increase OOM occur.
> What do you think?

We do hold onto some nearly free pages for a while longer but only in
direct reclaim, assuming kswapd is running its pages should not get
captured.  I am pushing our machines in test pretty hard, to the
unusable stage mostly without OOM'ing but that is still an artifical
test.  The amount of memory under capture is proportional to the size of
the allocations at the time of capture so one would hope this would only
be significant at very high orders.

> and, Why don't you make patch against -mm tree?

That is historical mostly as there was major churn in the same place when
I was originally making these patches, plus -mm was not bootable on any
of my test systems..  I am not sure if that is still true.  I will have
a look at a recent -mm and see if they will rebase and boot.

Thanks for looking.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
