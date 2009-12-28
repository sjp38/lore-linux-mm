Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E715160021B
	for <linux-mm@kvack.org>; Sun, 27 Dec 2009 23:17:39 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp07.in.ibm.com (8.14.3/8.13.1) with ESMTP id nBS4HYcP008220
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 09:47:34 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBS4HYGr3641432
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 09:47:34 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBS4HYxY023056
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 15:17:34 +1100
Date: Mon, 28 Dec 2009 09:47:31 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH -mmotm-2009-12-10-17-19] Prevent churning of zero page in
 LRU list.
Message-ID: <20091228041731.GI3601@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20091228115315.76b1ecd0.minchan.kim@barrios-desktop>
 <4B38246C.3020209@redhat.com>
 <20091228035639.GG3601@balbir.in.ibm.com>
 <20091228035738.GH3601@balbir.in.ibm.com>
 <4B383017.4070308@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <4B383017.4070308@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* Rik van Riel <riel@redhat.com> [2009-12-27 23:12:07]:

> On 12/27/2009 10:57 PM, Balbir Singh wrote:
> >* Balbir Singh<balbir@linux.vnet.ibm.com>  [2009-12-28 09:26:39]:
> >
> >>* Rik van Riel<riel@redhat.com>  [2009-12-27 22:22:20]:
> >>
> >>>On 12/27/2009 09:53 PM, Minchan Kim wrote:
> >>>>
> >>>>VM doesn't add zero page to LRU list.
>      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> 
> >>Frequent moving of zero page should ideally put it to the head of the
> >>LRU list, leaving it untouched is likely to cause it to be scanned
> >>often - no? Should this be moved to the unevictable list?
> >>
> >
> >Sorry, I replied to wrong email, I should have been clearer that this
> >question is for Minchan Kim.
> 
> The answer to your question is all the way up in
> Minchan Kim's original email.
> 
> The zero page is never on the LRU lists to begin with.
>

Aahh.. my bad... I should have looked at it more closely! 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
