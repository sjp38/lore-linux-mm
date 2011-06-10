Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6EBBE6B0012
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 14:54:27 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p5AIsMxT027223
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 11:54:22 -0700
Received: from pve37 (pve37.prod.google.com [10.241.210.37])
	by wpaz37.hot.corp.google.com with ESMTP id p5AIrsMS018409
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 11:54:21 -0700
Received: by pve37 with SMTP id 37so1410049pve.7
        for <linux-mm@kvack.org>; Fri, 10 Jun 2011 11:54:18 -0700 (PDT)
Date: Fri, 10 Jun 2011 11:54:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Make GFP_DMA allocations w/o ZONE_DMA emit a warning
 instead of failing
In-Reply-To: <20110610091233.GJ24424@n2100.arm.linux.org.uk>
Message-ID: <alpine.DEB.2.00.1106101150280.17197@chino.kir.corp.google.com>
References: <BANLkTinBkdVd90g3-uiQP41z1S1sXUdRmQ@mail.gmail.com> <BANLkTikrRRzGLbMD47_xJz+xpgftCm1C2A@mail.gmail.com> <alpine.DEB.2.00.1106011017260.13089@chino.kir.corp.google.com> <20110601181918.GO3660@n2100.arm.linux.org.uk> <alpine.LFD.2.02.1106012043080.3078@ionos>
 <alpine.DEB.2.00.1106011205410.17065@chino.kir.corp.google.com> <alpine.LFD.2.02.1106012134120.3078@ionos> <4DF1C9DE.4070605@jp.fujitsu.com> <20110610004331.13672278.akpm@linux-foundation.org> <BANLkTimC8K2_H7ZEu2XYoWdA09-3XxpV7Q@mail.gmail.com>
 <20110610091233.GJ24424@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, pavel@ucw.cz

On Fri, 10 Jun 2011, Russell King - ARM Linux wrote:

> > Should one submit a patch adding a warning to GFP_DMA allocations
> > w/o ZONE_DMA, or the idea of the original patch is wrong?
> 
> Linus was far from impressed by the original commit, saying:
> | Using GFP_DMA is reasonable in a driver - on platforms where that
> | matters, it should allocate from the DMA zone, on platforms where it
> | doesn't matter it should be a no-op.
> 
> So no, not even a warning.
> 

Any words of wisdom for users with CONFIG_ZONE_DMA=n that actually use 
drivers where they need GFP_DMA?  The page allocator should just silently 
return memory from anywhere?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
