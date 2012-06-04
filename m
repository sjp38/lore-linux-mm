Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 4E5866B005D
	for <linux-mm@kvack.org>; Mon,  4 Jun 2012 04:24:10 -0400 (EDT)
Received: from euspt1 (mailout3.w1.samsung.com [210.118.77.13])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M53009E13DA7N60@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 04 Jun 2012 09:24:46 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M53008V33C8Z7@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 04 Jun 2012 09:24:08 +0100 (BST)
Date: Mon, 04 Jun 2012 10:18:13 +0200
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [PATCH 2/2] proc: add ARCH_PFN_OFFSET info to /proc/meminfo
In-reply-to: <4FC92591.1070401@gmail.com>
Message-id: <201206041018.13568.b.zolnierkie@samsung.com>
MIME-version: 1.0
Content-type: Text/Plain; charset=iso-8859-1
Content-transfer-encoding: 7BIT
References: <201206011854.17399.b.zolnierkie@samsung.com>
 <4FC92591.1070401@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Matt Mackall <mpm@selenic.com>

On Friday 01 June 2012 22:26:57 KOSAKI Motohiro wrote:
> (6/1/12 12:54 PM), Bartlomiej Zolnierkiewicz wrote:
> > From: Bartlomiej Zolnierkiewicz<b.zolnierkie@samsung.com>
> > Subject: [PATCH] proc: add ARCH_PFN_OFFSET info to /proc/meminfo
> >
> > ARCH_PFN_OFFSET is needed for user-space to use together with
> > /proc/kpage[count,flags] interfaces.
> >
> > Cc: Matt Mackall<mpm@selenic.com>
> > Signed-off-by: Bartlomiej Zolnierkiewicz<b.zolnierkie@samsung.com>
> > Signed-off-by: Kyungmin Park<kyungmin.park@samsung.com>
> > ---
> >   fs/proc/meminfo.c |    4 ++++
> >   1 file changed, 4 insertions(+)
> >
> > Index: b/fs/proc/meminfo.c
> > ===================================================================
> > --- a/fs/proc/meminfo.c	2012-05-31 16:53:11.589706973 +0200
> > +++ b/fs/proc/meminfo.c	2012-05-31 17:03:17.719237120 +0200
> > @@ -168,6 +168,10 @@ static int meminfo_proc_show(struct seq_
> >
> >   	hugetlb_report_meminfo(m);
> >
> > +	seq_printf(m,
> > +		"ArchPFNOffset:    %6lu\n",
> > +		ARCH_PFN_OFFSET);
> > +
> >   	arch_report_meminfo(m);
> 
> NAK.
> 
> arch specific report should use arch_report_meminfo().

ARCH_PFN_OFFSET is defined for all archs so I think that it makes little
sense to duplicate it in every per-arch arch_report_meminfo()..

Best regards,
--
Bartlomiej Zolnierkiewicz
Samsung Poland R&D Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
