Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5C1136B0012
	for <linux-mm@kvack.org>; Fri, 27 May 2011 17:32:21 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4RLKucL016297
	for <linux-mm@kvack.org>; Fri, 27 May 2011 17:20:56 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4RLWJ77119780
	for <linux-mm@kvack.org>; Fri, 27 May 2011 17:32:19 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4RLWJ5h016392
	for <linux-mm@kvack.org>; Fri, 27 May 2011 17:32:19 -0400
Subject: Re: [PATCH 01/10] mm: Introduce the memory regions data structure
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110527182041.GM5654@dirshya.in.ibm.com>
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
	 <1306499498-14263-2-git-send-email-ankita@in.ibm.com>
	 <1306510203.22505.69.camel@nimitz>
	 <20110527182041.GM5654@dirshya.in.ibm.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Fri, 27 May 2011 14:31:52 -0700
Message-ID: <1306531912.22505.84.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: svaidy@linux.vnet.ibm.com
Cc: Ankita Garg <ankita@in.ibm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, thomas.abraham@linaro.org

On Fri, 2011-05-27 at 23:50 +0530, Vaidyanathan Srinivasan wrote:
> The overall idea is to have a VM data structure that can capture
> various boundaries of memory, and enable the allocations and reclaim
> logic to target certain areas based on the boundaries and properties
> required. 

It's worth noting that we already do targeted reclaim on boundaries
other than zones.  The lumpy reclaim and memory compaction logically do
the same thing.  So, it's at least possible to do this without having
the global LRU designed around the way you want to reclaim.

Also, if you get _too_ dependent on the global LRU, what are you going
to do if our cgroup buddies manage to get cgroup'd pages off the global
LRU?  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
