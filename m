Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3E95C8D0039
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 10:10:53 -0500 (EST)
Date: Wed, 23 Feb 2011 16:10:47 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC PATCH] page_cgroup: Reduce allocation overhead for
 page_cgroup array for CONFIG_SPARSEMEM
Message-ID: <20110223151047.GA7275@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

Hi,

I have just noticed that memory cgroups consume a lot of 2MB slab
objects (8 objects per 1GB of RAM on x86_64 with SPARSEMEM). It turned
out that this memory is allocated for per memory sections page_cgroup
arrays. 

If we consider that the array itself consume something above 1MB (but
still doesn't fit into 1MB kmalloc cache) it is rather big wasting of
(continous) memory (6MB per 1GB of RAM). 


The patch below tries to fix this up. Any thoughts?
---
