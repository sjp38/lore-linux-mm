Date: Mon, 21 Jan 2008 14:35:09 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/2] Relax restrictions on setting CONFIG_NUMA on x86
Message-ID: <20080121143508.GA8485@csn.ul.ie>
References: <20080118153529.12646.5260.sendpatchset@skynet.skynet.ie> <20080121093702.8FC2.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080121093702.8FC2.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On (21/01/08 09:38), KOSAKI Motohiro didst pronounce:
> Hi 
> 
> > A fix[1] was merged to the x86.git tree that allowed NUMA kernels to boot
> > on normal x86 machines (and not just NUMA-Q, Summit etc.). I took a look
> > at the restrictions on setting NUMA on x86 to see if they could be lifted.
> 
> Interesting!
> 
> I will test tomorrow.

Thanks.

> I think this patch become easy to the porting of fakenuma.
> 

It would be great if that was available, particularly if it could fake
memoryless nodes as that is a place where we've found a few
difficult-to-reproduce bugs.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
