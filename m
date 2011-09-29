Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7DF969000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 12:31:01 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e35.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8TG9rLl029466
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 10:09:53 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8TGUgb4182122
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 10:30:42 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8TGUfgE006913
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 10:30:42 -0600
Subject: Re: [PATCH 2/2] mm: restrict access to /proc/meminfo
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110929161848.GA16348@albatros>
References: <20110927175453.GA3393@albatros>
	 <20110927175642.GA3432@albatros> <20110927193810.GA5416@albatros>
	 <alpine.DEB.2.00.1109271459180.13797@router.home>
	 <alpine.DEB.2.00.1109271328151.24402@chino.kir.corp.google.com>
	 <20110929161848.GA16348@albatros>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 29 Sep 2011 09:30:36 -0700
Message-ID: <1317313836.16137.620.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: David Rientjes <rientjes@google.com>, Christoph Lameter <cl@gentwo.org>, kernel-hardening@lists.openwall.com, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Kees Cook <kees@ubuntu.com>, Valdis.Kletnieks@vt.edu, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@linux.intel.com>, linux-kernel@vger.kernel.org

On Thu, 2011-09-29 at 20:18 +0400, Vasiliy Kulikov wrote:
> I'm not convinced with rounding the information to MBs.  The attacker
> still may fill slabs with new objects to trigger new slab pages
> allocations.  He will be able to see when this MB-granularity barrier is
> overrun thus seeing how many kbs there were before:
> 
>     old = new - filled_obj_size_sum
> 
> As `new' is just increased, it means it is known with KB granularity,
> not MB.  By counting used slab objects he learns filled_obj_size_sum.
> 
> So, rounding gives us nothing, but obscurity. 

I'll agree that it doesn't fundamentally fix anything.  But, it does
make an attack more difficult in the real world.  There's a reason that
real-world attackers are going after slabinfo: it's a fundamentally
*BETTER* than meminfo as a tool with which to aim an attack.  A
MB-rounded meminfo is also fundamentally *BETTER* than a
PAGE_SIZE-rounded meminfo.  I find it hard to call this "nothing".

Anyway...  I'm working on a patch.  Will post soon.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
