Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A602C8D0030
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 14:13:41 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o9TI4W4s021618
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 12:04:32 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id o9TIDY7J244030
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 12:13:34 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o9TIDXg9006915
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 12:13:34 -0600
Subject: Re: oom killer question
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20101029121456.GA6896@osiris.boeblingen.de.ibm.com>
References: <20101029121456.GA6896@osiris.boeblingen.de.ibm.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Fri, 29 Oct 2010 11:13:28 -0700
Message-ID: <1288376008.13539.8991.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Hartmut Beinlich <HBEINLIC@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2010-10-29 at 14:14 +0200, Heiko Carstens wrote:
> present:2068480kB

So, ~2GB available.

>  mlocked:4452kB
>  unevictable:4452kB writeback:0kB mapped:3684kB shmem:0kB 
> slab_reclaimable:1778388kB
> slab_unreclaimable:188388kB kernel_stack:4016kB pagetables:2232kB
> unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:542
> all_unreclaimable? yes

Plus about 1.8GB of unreclaimable slab.  all_unreclaimable is set.  So,
you reclaimed all of the user memory that you could get and swapped out
what could have been swapped out.  What was left was slab.

This OOM looks proper to me.  What was eating all of your slab?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
