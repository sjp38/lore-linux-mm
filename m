Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA2FVmsv022801
	for <linux-mm@kvack.org>; Fri, 2 Nov 2007 11:31:48 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA2FE79B047752
	for <linux-mm@kvack.org>; Fri, 2 Nov 2007 09:31:48 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA2Es5tS015565
	for <linux-mm@kvack.org>; Fri, 2 Nov 2007 08:54:05 -0600
Subject: Re: [PATCH 3/3] Add arch-specific walk_memory_remove() for ppc64
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <1193999530.25744.3.camel@johannes.berg>
References: <1193849335.17412.33.camel@dyn9047017100.beaverton.ibm.com>
	 <1193999530.25744.3.camel@johannes.berg>
Content-Type: text/plain
Date: Fri, 02 Nov 2007 07:57:18 -0800
Message-Id: <1194019038.1547.0.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Berg <johannes@sipsolutions.net>
Cc: Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@ozlabs.org, anton@au1.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-11-02 at 10:32 +0000, Johannes Berg wrote:
> > This patch provides a way for an architecture to provide its
> > own walk_memory_resource()
> 
> It seems that the patch description "walk_memory_remove()" is wrong?
> 

Yep. Patch title is wrong.

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
