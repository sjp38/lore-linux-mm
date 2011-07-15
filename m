Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id C92666B004A
	for <linux-mm@kvack.org>; Fri, 15 Jul 2011 03:54:13 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 2/2] hugepage: Allow parallelization of the hugepage fault path
References: <20110125143226.37532ea2@kryten> <20110125143414.1dbb150c@kryten>
Date: Fri, 15 Jul 2011 00:52:38 -0700
In-Reply-To: <20110125143414.1dbb150c@kryten> (Anton Blanchard's message of
	"Tue, 25 Jan 2011 14:34:14 +1100")
Message-ID: <m2zkkg6kvs.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Blanchard <anton@samba.org>
Cc: dwg@au1.ibm.com, mel@csn.ul.ie, akpm@linux-foundation.org, hughd@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Anton Blanchard <anton@samba.org> writes:


> This patch improves the situation by replacing the single mutex with a
> table of mutexes, selected based on a hash of the address_space and
> file offset being faulted (or mm and virtual address for MAP_PRIVATE
> mappings).

It's unclear to me how this solves the original OOM problem.
But then you can still have early oom over all the hugepages if they
happen to hash to different pages, can't you? 

I think it would be better to move out the clearing out of the lock,
and possibly take the lock only when the hugepages are about to 
go OOM.

-Andi


-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
