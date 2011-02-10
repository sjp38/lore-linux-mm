Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 915448D0039
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 10:02:01 -0500 (EST)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p1AEahLK003537
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 09:36:45 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 954A24DE8043
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 10:01:07 -0500 (EST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p1AF1w4f480642
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 10:01:58 -0500
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p1AF1vkH025258
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 08:01:58 -0700
Subject: Re: [PATCH 5/5] have smaps show transparent huge pages
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110210112032.GG17873@csn.ul.ie>
References: <20110209195406.B9F23C9F@kernel>
	 <20110209195413.6D3CB37F@kernel>  <20110210112032.GG17873@csn.ul.ie>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Thu, 10 Feb 2011 07:01:55 -0800
Message-ID: <1297350115.6737.14208.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>

On Thu, 2011-02-10 at 11:20 +0000, Mel Gorman wrote:
> > @@ -394,6 +395,7 @@ static int smaps_pte_range(pmd_t *pmd, u
> >                       spin_lock(&walk->mm->page_table_lock);
> >               } else {
> >                       smaps_pte_entry(*(pte_t *)pmd, addr, HPAGE_SIZE, walk);
> > +                     mss->anonymous_thp += HPAGE_SIZE;
> 
> I should have thought of this for the previous patch but should this be
> HPAGE_PMD_SIZE instead of HPAGE_SIZE? Right now, they are the same value
> but they are not the same thing.

Probably.  There's also a nice BUG() in HPAGE_PMD_SIZE if the THP config
option is off, which is an added bonus.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
