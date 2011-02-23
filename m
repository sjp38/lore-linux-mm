Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 16F188D0039
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 13:19:27 -0500 (EST)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p1NE0mdD029838
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 09:00:48 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p1NIJOmY331466
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 13:19:24 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p1NIJOtN001330
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 13:19:24 -0500
Subject: Re: [RFC PATCH] page_cgroup: Reduce allocation overhead for
 page_cgroup array for CONFIG_SPARSEMEM
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110223151047.GA7275@tiehlicka.suse.cz>
References: <20110223151047.GA7275@tiehlicka.suse.cz>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Wed, 23 Feb 2011 10:19:22 -0800
Message-ID: <1298485162.7236.4.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Wed, 2011-02-23 at 16:10 +0100, Michal Hocko wrote:
> We can reduce this internal fragmentation by splitting the single
> page_cgroup array into more arrays where each one is well kmalloc
> aligned. This patch implements this idea. 

How about using alloc_pages_exact()?  These things aren't allocated
often enough to really get most of the benefits of being in a slab.
That'll at least get you down to a maximum of about PAGE_SIZE wasted.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
