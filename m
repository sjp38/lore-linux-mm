Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3924B6B00E7
	for <linux-mm@kvack.org>; Thu, 13 Jan 2011 17:25:19 -0500 (EST)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id p0DMOsog002968
	for <linux-mm@kvack.org>; Thu, 13 Jan 2011 14:24:54 -0800
Received: from pxi15 (pxi15.prod.google.com [10.243.27.15])
	by kpbe13.cbf.corp.google.com with ESMTP id p0DMOqQX030368
	for <linux-mm@kvack.org>; Thu, 13 Jan 2011 14:24:52 -0800
Received: by pxi15 with SMTP id 15so329063pxi.33
        for <linux-mm@kvack.org>; Thu, 13 Jan 2011 14:24:52 -0800 (PST)
Date: Thu, 13 Jan 2011 14:24:50 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: RE: [RFC][PATCH 0/2] Tunable watermark
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9C3B8DF647@USINDEVS02.corp.hds.com>
Message-ID: <alpine.DEB.2.00.1101131421220.26770@chino.kir.corp.google.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9C3A30A295@USINDEVS02.corp.hds.com> <alpine.DEB.2.00.1101071416450.23577@chino.kir.corp.google.com> <AANLkTikQPXWkEJwN5fV2vnUS37Fs+GNzFXuFkKXcnzmu@mail.gmail.com> <alpine.DEB.2.00.1101071436220.23858@chino.kir.corp.google.com>
 <65795E11DBF1E645A09CEC7EAEE94B9C3B8DF647@USINDEVS02.corp.hds.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Satoru Moriya <satoru.moriya@hds.com>
Cc: Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Randy Dunlap <rdunlap@xenotime.net>, dle-develop@lists.sourceforge.net, Seiji Aguchi <seiji.aguchi@hds.com>
List-ID: <linux-mm.kvack.org>

On Thu, 13 Jan 2011, Satoru Moriya wrote:

> Currently watermark[low,high] are set by following calculation (lowmem case).
> 
> watermark[low]  = watermark[min] * 1.25
> watermark[high] = watermark[min] * 1.5
> 
> So the difference between watermarks are following:
> 
> min <-- min/4 --> low <-- min/4 --> high
> 
> I think the differences, "min/4", are too small in my case.
> Of course I can make them bigger if I set min_free_kbytes to bigger value. 
> But it means kernel keeps more free memory for PF_MEMALLOC case unnecessarily.
> 
> So I suggest changing coefficients(1.25, 1.5). Also it's better
> to make them accessible from user space to tune in response to application
> requirements.
> 

Userspace can't possibly be held responsible for tuning internal VM 
parameters in response to certain workloads like this; if you have 
evidence that different coefficients work better in different 
circumstances, then present the criteria for which you intend to change 
them from the command line via your new tunables and let's work to make 
the VM more extendable to serve those workloads well.  This should be done 
by showing how background reclaim is ineffective, we enter direct 
compaction or reclaim too aggressively, we don't wait for writeout long 
enough, we prematurely kill applications when unnecessary, etc, which 
would undoubtedly have if you're going to make any sane adjustments via 
these new tunables.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
