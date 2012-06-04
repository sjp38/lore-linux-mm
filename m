Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 478466B005C
	for <linux-mm@kvack.org>; Mon,  4 Jun 2012 04:24:10 -0400 (EDT)
Received: from euspt1 (mailout4.w1.samsung.com [210.118.77.14])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M530093V3DE1W60@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 04 Jun 2012 09:24:50 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M53002W63C84M@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 04 Jun 2012 09:24:08 +0100 (BST)
Date: Mon, 04 Jun 2012 10:23:22 +0200
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [PATCH 1/3] proc: add /proc/kpageorder interface
In-reply-to: <4FC92685.9070604@gmail.com>
Message-id: <201206041023.22937.b.zolnierkie@samsung.com>
MIME-version: 1.0
Content-type: Text/Plain; charset=iso-8859-1
Content-transfer-encoding: 7BIT
References: <201206011854.25795.b.zolnierkie@samsung.com>
 <4FC92685.9070604@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Matt Mackall <mpm@selenic.com>

On Friday 01 June 2012 22:31:01 KOSAKI Motohiro wrote:
> (6/1/12 12:54 PM), Bartlomiej Zolnierkiewicz wrote:
> > From: Bartlomiej Zolnierkiewicz<b.zolnierkie@samsung.com>
> > Subject: [PATCH] proc: add /proc/kpageorder interface
> >
> > This makes page order information available to the user-space.
> 
> No usecase new feature always should be NAKed.

It is used to get page orders for Buddy pages and help to monitor
free/used pages.  Sample usage will be posted for inclusion to
Pagemap Demo tools (http://selenic.com/repo/pagemap/).

The similar situation is with /proc/kpagetype..

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
