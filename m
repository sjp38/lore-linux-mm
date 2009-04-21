Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 207036B005C
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 23:14:58 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id n3L3F6Uu002022
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 08:45:06 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3L3Avds4231280
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 08:40:57 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id n3L3F6WC022691
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 13:15:06 +1000
Date: Tue, 21 Apr 2009 08:44:20 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [patch 1/3] mm: fix pageref leak in do_swap_page()
Message-ID: <20090421031419.GB30001@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1240259085-25872-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1240259085-25872-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Johannes Weiner <hannes@cmpxchg.org> [2009-04-20 22:24:43]:

> By the time the memory cgroup code is notified about a swapin we
> already hold a reference on the fault page.
> 
> If the cgroup callback fails make sure to unlock AND release the page
> or we leak the reference.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>

Seems reasonable to me, could you make the changelog more verbose and
mention that lookup_swap_cache() gets a reference to the page and we
need to release the extra reference.

BTW, have you had any luck reproducing the issue? How did you catch
the problem?

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
