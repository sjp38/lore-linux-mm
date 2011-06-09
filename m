Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 52A3C6B0012
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 14:53:04 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p59IfOIb029010
	for <linux-mm@kvack.org>; Thu, 9 Jun 2011 14:41:24 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p59Ir2v5084924
	for <linux-mm@kvack.org>; Thu, 9 Jun 2011 14:53:02 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p59Ir0AT022979
	for <linux-mm@kvack.org>; Thu, 9 Jun 2011 14:53:01 -0400
Date: Thu, 9 Jun 2011 11:52:59 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 00/10] mm: Linux VM Infrastructure to support Memory
 Power Management
Message-ID: <20110609185259.GA29287@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
 <20110528005640.9076c0b1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110528005640.9076c0b1.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ankita Garg <ankita@in.ibm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org

On Sat, May 28, 2011 at 12:56:40AM -0700, Andrew Morton wrote:
> On Fri, 27 May 2011 18:01:28 +0530 Ankita Garg <ankita@in.ibm.com> wrote:
> 
> > This patchset proposes a generic memory regions infrastructure that can be
> > used to tag boundaries of memory blocks which belongs to a specific memory
> > power management domain and further enable exploitation of platform memory
> > power management capabilities.
> 
> A couple of quick thoughts...
> 
> I'm seeing no estimate of how much energy we might save when this work
> is completed.  But saving energy is the entire point of the entire
> patchset!  So please spend some time thinking about that and update and
> maintain the [patch 0/n] description so others can get some idea of the
> benefit we might get from all of this.  That estimate should include an
> estimate of what proportion of machines are likely to have hardware
> which can use this feature and in what timeframe.
> 
> IOW, if it saves one microwatt on 0.001% of machines, not interested ;)

FWIW, I have seen estimates on the order of a 5% reduction in power
consumption for some common types of embedded devices.

							Thanx, Paul

> Also, all this code appears to be enabled on all machines?  So machines
> which don't have the requisite hardware still carry any additional
> overhead which is added here.  I can see that ifdeffing a feature like
> this would be ghastly but please also have a think about the
> implications of this and add that discussion also.  
> 
> If possible, it would be good to think up some microbenchmarks which
> probe the worst-case performance impact and describe those and present
> the results.  So others can gain an understanding of the runtime costs.
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
