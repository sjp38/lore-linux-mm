Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 69E506B007B
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 15:27:12 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8FJ7OBf002460
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 15:07:24 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8FJR5NL331132
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 15:27:05 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8FJR49I011867
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 15:27:05 -0400
Subject: Re: [RFC][PATCH] update /proc/sys/vm/drop_caches documentation
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <m1d3se7t0h.fsf@fess.ebiederm.org>
References: <20100914234714.8AF506EA@kernel.beaverton.ibm.com>
	 <20100915133303.0b232671.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100915135016.C9F1.A69D9226@jp.fujitsu.com>
	 <1284531262.27089.15725.camel@nimitz>  <m1d3se7t0h.fsf@fess.ebiederm.org>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Wed, 15 Sep 2010 12:27:01 -0700
Message-ID: <1284578821.27089.17409.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lnxninja@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, 2010-09-15 at 11:37 -0700, Eric W. Biederman wrote:
> > I'm worried that there are users out there experiencing real problems
> > that aren't reporting it because "workarounds" like this just paper over
> > the issue.
> 
> For what it is worth.  I had a friend ask me about a system that had 50%
> of it's memory consumed by slab caches.  20GB out of 40GB.  The kernel
> was suse? 2.6.27 so it's old, but if you are curious.
> /proc/sys/vm/drop_caches does nothing in that case. 

Was it the reclaimable caches doing it, though?  The other really common
cause is kmalloc() leaks.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
