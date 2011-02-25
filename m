Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2B8718D003A
	for <linux-mm@kvack.org>; Fri, 25 Feb 2011 13:52:57 -0500 (EST)
Date: Fri, 25 Feb 2011 10:52:05 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for February 25 (mm/slub.c)
Message-Id: <20110225105205.5a1309bb.randy.dunlap@oracle.com>
In-Reply-To: <20110225175924.a95d616d.sfr@canb.auug.org.au>
References: <20110225175924.a95d616d.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Fri, 25 Feb 2011 17:59:24 +1100 Stephen Rothwell wrote:

> Hi all,
> 
> Changes since 20110224:


when CONFIG_SLUB_DEBUG is not enabled:

mm/slub.c:2728: error: implicit declaration of function 'slab_ksize'

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
