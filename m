Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 7E3B86B0087
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 04:27:04 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (mailout3.samsung.com [203.254.224.33])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M5600AUTSETIK30@mailout3.samsung.com> for
 linux-mm@kvack.org; Wed, 06 Jun 2012 17:27:02 +0900 (KST)
Received: from bzolnier-desktop.localnet ([106.116.48.38])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M56002SXST17D30@mmp2.samsung.com> for linux-mm@kvack.org;
 Wed, 06 Jun 2012 17:27:02 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [PATCH 1/3] proc: add /proc/kpageorder interface
Date: Wed, 06 Jun 2012 10:23:13 +0200
References: <201206011854.25795.b.zolnierkie@samsung.com>
 <201206041023.22937.b.zolnierkie@samsung.com> <4FCD0D0D.9050003@gmail.com>
In-reply-to: <4FCD0D0D.9050003@gmail.com>
MIME-version: 1.0
Message-id: <201206061023.13237.b.zolnierkie@samsung.com>
Content-type: Text/Plain; charset=iso-8859-1
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Matt Mackall <mpm@selenic.com>

On Monday 04 June 2012 21:31:25 KOSAKI Motohiro wrote:
> (6/4/12 4:23 AM), Bartlomiej Zolnierkiewicz wrote:
> > On Friday 01 June 2012 22:31:01 KOSAKI Motohiro wrote:
> >> (6/1/12 12:54 PM), Bartlomiej Zolnierkiewicz wrote:
> >>> From: Bartlomiej Zolnierkiewicz<b.zolnierkie@samsung.com>
> >>> Subject: [PATCH] proc: add /proc/kpageorder interface
> >>>
> >>> This makes page order information available to the user-space.
> >>
> >> No usecase new feature always should be NAKed.
> >
> > It is used to get page orders for Buddy pages and help to monitor
> > free/used pages.  Sample usage will be posted for inclusion to
> > Pagemap Demo tools (http://selenic.com/repo/pagemap/).
> >
> > The similar situation is with /proc/kpagetype..
> 
> NAK then.
> 
> First, your explanation didn't describe any usecase. "There is a similar feature"
> is NOT a usecase.
> 
> Second, /proc/kpagetype is one of mistaken feature. It was not designed deeply.
> We have no reason to follow the mistake.

Well, my usecase for /proc/kpagetype is to monitor/debug pageblock changes
(i.e. to verify CMA and compaction operations).  It is not perfect since
interface gives us only a snapshot of pageblocks state at some random time.
However it is a straightforward method and requires only minimal changes
to the existing code.

Maybe there is a better way to do this which would give a more accurate
data and capture every state change (maybe a one involving tracing?) but
I don't know about it.  Do you know such better way to do it?

> Third, pagemap demo doesn't describe YOUR feature's usefull at all.

pagemap demo doesn't include my patches for /proc/kpage[order,type] yet
so it is not surprising at all (it doesn't even work with current kernels
without my other patches).. ;)

> Fourth, pagemap demo is NOT useful at all. It's just toy. Practically, kpagetype
> is only used from pagetype tool.

I don't quite follow it, what pagetype tool are you referring to (kpagetype
is a new interface)?

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
