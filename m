Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 99E7160021B
	for <linux-mm@kvack.org>; Sun, 27 Dec 2009 22:57:45 -0500 (EST)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp08.au.ibm.com (8.14.3/8.13.1) with ESMTP id nBS3vgls009908
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 14:57:42 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBS3rSWr1335306
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 14:53:28 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBS3vfZ1018437
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 14:57:41 +1100
Date: Mon, 28 Dec 2009 09:27:38 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH -mmotm-2009-12-10-17-19] Prevent churning of zero page in
 LRU list.
Message-ID: <20091228035738.GH3601@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20091228115315.76b1ecd0.minchan.kim@barrios-desktop>
 <4B38246C.3020209@redhat.com>
 <20091228035639.GG3601@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20091228035639.GG3601@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* Balbir Singh <balbir@linux.vnet.ibm.com> [2009-12-28 09:26:39]:

> * Rik van Riel <riel@redhat.com> [2009-12-27 22:22:20]:
> 
> > On 12/27/2009 09:53 PM, Minchan Kim wrote:
> > >
> > >VM doesn't add zero page to LRU list.
> > >It means zero page's churning in LRU list is pointless.
> > >
> > >As a matter of fact, zero page can't be promoted by mark_page_accessed
> > >since it doesn't have PG_lru.
> > >
> > >This patch prevent unecessary mark_page_accessed call of zero page
> > >alghouth caller want FOLL_TOUCH.
> > >
> > >Signed-off-by: Minchan Kim<minchan.kim@gmail.com>
> > 
> > The code looks correct, but I wonder how frequently we run into
> > the zero page in this code, vs. how much the added cost is of
> > having this extra code in follow_page.
> > 
> > What kind of problem were you running into that motivated you
> > to write this patch?
> >
> 
> Frequent moving of zero page should ideally put it to the head of the
> LRU list, leaving it untouched is likely to cause it to be scanned 
> often - no? Should this be moved to the unevictable list? 
>

Sorry, I replied to wrong email, I should have been clearer that this
question is for Minchan Kim. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
