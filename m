Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8AC436B0387
	for <linux-mm@kvack.org>; Sun,  5 Mar 2017 21:19:20 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id b2so195160142pgc.6
        for <linux-mm@kvack.org>; Sun, 05 Mar 2017 18:19:20 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 7si17581018pll.242.2017.03.05.18.19.19
        for <linux-mm@kvack.org>;
        Sun, 05 Mar 2017 18:19:19 -0800 (PST)
Date: Mon, 6 Mar 2017 11:16:10 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 07/11] mm: remove SWAP_AGAIN in ttu
Message-ID: <20170306021610.GE8779@bbox>
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <1488436765-32350-8-git-send-email-minchan@kernel.org>
 <fce4a36a-8b4b-333d-d846-9f6edd86c2e1@linux.vnet.ibm.com>
MIME-Version: 1.0
In-Reply-To: <fce4a36a-8b4b-333d-d846-9f6edd86c2e1@linux.vnet.ibm.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>

On Fri, Mar 03, 2017 at 06:24:06PM +0530, Anshuman Khandual wrote:
> On 03/02/2017 12:09 PM, Minchan Kim wrote:
> > In 2002, [1] introduced SWAP_AGAIN.
> > At that time, ttuo used spin_trylock(&mm->page_table_lock) so it's
> 
> Small nit: Please expand "ttuo" here. TTU in the first place is also
> not very clear but we have that in many places.

No problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
