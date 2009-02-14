Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2EA896B003D
	for <linux-mm@kvack.org>; Sat, 14 Feb 2009 01:12:33 -0500 (EST)
Date: Fri, 13 Feb 2009 22:12:26 -0800 (PST)
Message-Id: <20090213.221226.264144345.davem@davemloft.net>
Subject: Re: [PATCH 1/2] clean up for early_pfn_to_nid
From: David Miller <davem@davemloft.net>
In-Reply-To: <20090213142032.09b4a4da.akpm@linux-foundation.org>
References: <20090212161920.deedea35.kamezawa.hiroyu@jp.fujitsu.com>
	<20090212162203.db3f07cb.kamezawa.hiroyu@jp.fujitsu.com>
	<20090213142032.09b4a4da.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: kamezawa.hiroyu@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, davem@davemlloft.net, heiko.carstens@de.ibm.com, stable@kernel.org
List-ID: <linux-mm.kvack.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Fri, 13 Feb 2009 14:20:32 -0800

> I queued these as
> 
> mm-clean-up-for-early_pfn_to_nid.patch
> mm-fix-memmap-init-for-handling-memory-hole.patch
> 
> and tagged them as needed-in-2.6.28.x.  I don't recall whether they are
> needed in earlier -stable releases?

Every kernel going back to at least 2.6.24 has this bug.  It's likely
been around even longer, I didn't bother checking.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
