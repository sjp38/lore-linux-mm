Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 8A2CD6B003D
	for <linux-mm@kvack.org>; Thu,  9 May 2013 18:19:52 -0400 (EDT)
Message-ID: <518C2106.3030402@sr71.net>
Date: Thu, 09 May 2013 15:19:50 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/7] defer clearing of page_private() for swap cache
 pages
References: <20130507211954.9815F9D1@viggo.jf.intel.com> <20130507211955.7DF88A4F@viggo.jf.intel.com> <20130509220739.GA14840@cerebellum>
In-Reply-To: <20130509220739.GA14840@cerebellum>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com

On 05/09/2013 03:07 PM, Seth Jennings wrote:
> mm/memcontrol:4111
> VM_BUG_ON(PageSwapCache(page));
> 
> Seems that mem_cgroup_uncharge_swapcache, somewhat ironically expects the
> SwapCache flag to be unset already.
> 
> Fix might be a simple as removing that VM_BUG_ON() but there might be more to
> it.  There usually is :)

Yeah, I wasn't testing with cgroups around.  I'll go do that and see
what I come up with.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
