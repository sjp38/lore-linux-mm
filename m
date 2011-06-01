Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1C3B06B004A
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 15:09:20 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p51J9Flg011235
	for <linux-mm@kvack.org>; Wed, 1 Jun 2011 12:09:16 -0700
Received: from pwi16 (pwi16.prod.google.com [10.241.219.16])
	by kpbe19.cbf.corp.google.com with ESMTP id p51J9DKi005887
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 1 Jun 2011 12:09:14 -0700
Received: by pwi16 with SMTP id 16so174994pwi.7
        for <linux-mm@kvack.org>; Wed, 01 Jun 2011 12:09:13 -0700 (PDT)
Date: Wed, 1 Jun 2011 12:09:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Make GFP_DMA allocations w/o ZONE_DMA emit a warning
 instead of failing
In-Reply-To: <alpine.LFD.2.02.1106012043080.3078@ionos>
Message-ID: <alpine.DEB.2.00.1106011205410.17065@chino.kir.corp.google.com>
References: <1306922672-9012-1-git-send-email-dbaryshkov@gmail.com> <BANLkTinBkdVd90g3-uiQP41z1S1sXUdRmQ@mail.gmail.com> <BANLkTikrRRzGLbMD47_xJz+xpgftCm1C2A@mail.gmail.com> <alpine.DEB.2.00.1106011017260.13089@chino.kir.corp.google.com>
 <20110601181918.GO3660@n2100.arm.linux.org.uk> <alpine.LFD.2.02.1106012043080.3078@ionos>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 1 Jun 2011, Thomas Gleixner wrote:

> > That is NOT an unreasonable request, but it seems that its far too much
> > to ask of you.
> 
> Full ack.
> 
> David,
> 
> stop that nonsense already. You changed the behaviour and broke stuff
> which was working fine before for whatever reason. That behaviour was
> in the kernel for ages and we tolerated the abuse.
> 

Did I nack this patch and not realize it?

Does my patch fix the warning for pxaficp_ir that would still be emitted 
with this patch?  If the driver uses GFP_DMA and nobody from the arm side 
is prepared to remove it yet, then I'd suggest merging my patch until that 
can be determined.  Otherwise, you have no guarantees about where the 
memory is actually coming from.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
