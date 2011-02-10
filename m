Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5F6CB8D0039
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 13:20:39 -0500 (EST)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p1AI1gPt030881
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 13:02:43 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 618E34DE804A
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 13:19:45 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p1AIKa8l322160
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 13:20:36 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p1AIKZDn021446
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 13:20:36 -0500
Subject: Re: [PATCH 5/5] have smaps show transparent huge pages
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110210180924.GB3347@random.random>
References: <20110209195406.B9F23C9F@kernel>
	 <20110209195413.6D3CB37F@kernel> <20110210112032.GG17873@csn.ul.ie>
	 <1297350115.6737.14208.camel@nimitz> <20110210150942.GL17873@csn.ul.ie>
	 <20110210180924.GB3347@random.random>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Thu, 10 Feb 2011 10:20:32 -0800
Message-ID: <1297362032.6737.14622.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>

On Thu, 2011-02-10 at 19:09 +0100, Andrea Arcangeli wrote:
> Maybe it'd be cleaner if we didn't need to cast the pmd to pte_t but I
> guess this makes things simpler. 

Yeah, I'm not a huge fan of doing that, either.  But, I'm not sure what
the alternatives are.  We could basically copy smaps_pte_entry() to
smaps_pmd_entry(), and then try to make pmd variants of all of the pte
functions and macros we call in there.

I know there's a least a bit of precedent in the hugetlbfs code for
doing things like this, but it's not a _great_ excuse. :)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
