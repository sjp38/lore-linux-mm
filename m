Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A3F4B8D003A
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 08:40:50 -0500 (EST)
Date: Thu, 24 Feb 2011 14:40:45 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH] page_cgroup: Reduce allocation overhead for
 page_cgroup array for CONFIG_SPARSEMEM v2
Message-ID: <20110224134045.GA22122@tiehlicka.suse.cz>
References: <20110223151047.GA7275@tiehlicka.suse.cz>
 <1298485162.7236.4.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1298485162.7236.4.camel@nimitz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

Here is the second version of the patch. I have used alloc_pages_exact
instead of the complex double array approach.

I still fallback to kmalloc/vmalloc because hotplug can happen quite
some time after boot and we can end up not having enough continuous
pages at that time. 

I am also thinking whether it would make sense to introduce
alloc_pages_exact_node function which would allocate pages from the
given node.

Any thoughts?
---
