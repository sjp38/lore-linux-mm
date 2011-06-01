Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 634666B004A
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 14:42:16 -0400 (EDT)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id p51IgCrC006061
	for <linux-mm@kvack.org>; Wed, 1 Jun 2011 11:42:13 -0700
Received: from pxi19 (pxi19.prod.google.com [10.243.27.19])
	by kpbe15.cbf.corp.google.com with ESMTP id p51IfrBH013322
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 1 Jun 2011 11:42:11 -0700
Received: by pxi19 with SMTP id 19so59433pxi.1
        for <linux-mm@kvack.org>; Wed, 01 Jun 2011 11:42:11 -0700 (PDT)
Date: Wed, 1 Jun 2011 11:42:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Make GFP_DMA allocations w/o ZONE_DMA emit a warning
 instead of failing
In-Reply-To: <BANLkTinrviHh40fTfqyeB=SrcNS0yqZM0w@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1106011140050.16198@chino.kir.corp.google.com>
References: <1306922672-9012-1-git-send-email-dbaryshkov@gmail.com> <BANLkTinBkdVd90g3-uiQP41z1S1sXUdRmQ@mail.gmail.com> <BANLkTikrRRzGLbMD47_xJz+xpgftCm1C2A@mail.gmail.com> <alpine.DEB.2.00.1106011017260.13089@chino.kir.corp.google.com>
 <BANLkTinrviHh40fTfqyeB=SrcNS0yqZM0w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 1 Jun 2011, Dmitry Eremin-Solenikov wrote:

> > So you want to continue to allow the page allocator to return pages from
> > anywhere, even when GFP_DMA is specified, just as though it was lowmem?
> 
> Yes and no. I'm asking for the grace period for the drivers authors to be able
> to fix their code. After a grace period of one or two majors this permission
> should be removed and your original patch should be effective.
> 

You don't need to wait for the code to be fixed, you just need to enable 
CONFIG_ZONE_DMA.  This is a configuration issue.  If that GFP_DMA can be 
removed later, that's great, but right now it requires it.  Why can't you 
enable the config option?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
