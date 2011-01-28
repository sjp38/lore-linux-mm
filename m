Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id EBCE48D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 06:18:43 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp06.in.ibm.com (8.14.4/8.13.1) with ESMTP id p0SBIcXj026319
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 16:48:38 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0SBIc1P3518468
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 16:48:38 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0SBIbPP001253
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 16:48:38 +0530
Date: Fri, 28 Jan 2011 16:48:33 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/3] Provide control over unmapped pages (v4)
Message-ID: <20110128111833.GD5054@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20110125051003.13762.35120.stgit@localhost6.localdomain6>
 <20110125051015.13762.13429.stgit@localhost6.localdomain6>
 <AANLkTikHLw0Qg+odOB-bDtBSB-5UbTJ5ZOM-ZAdMqXgh@mail.gmail.com>
 <AANLkTi=qXsDjN5Jp4m3QMgVnckoAM7uE9_Hzn6CajP+c@mail.gmail.com>
 <AANLkTinfxXc04S9VwQcJ9thFff=cP=icroaiVLkN-GeH@mail.gmail.com>
 <20110128064851.GB5054@balbir.in.ibm.com>
 <AANLkTikw_j0JJVqEsj1xThoashiOARg+8BgcLKrvkV3U@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <AANLkTikw_j0JJVqEsj1xThoashiOARg+8BgcLKrvkV3U@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

* MinChan Kim <minchan.kim@gmail.com> [2011-01-28 16:24:19]:

> >
> > But the assumption for LRU order to change happens only if the page
> > cannot be successfully freed, which means it is in some way active..
> > and needs to be moved no?
> 
> 1. holded page by someone
> 2. mapped pages
> 3. active pages
> 
> 1 is rare so it isn't the problem.
> Of course, in case of 3, we have to activate it so no problem.
> The problem is 2.
>

2 is a problem, but due to the size aspects not a big one. Like you
said even lumpy reclaim affects it. May be the reclaim code could
honour may_unmap much earlier. 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
