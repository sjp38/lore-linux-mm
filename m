Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 70FA76B003D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 10:45:27 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id EA38F82C33B
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 10:48:00 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id oGWaDUBT32oL for <linux-mm@kvack.org>;
	Wed,  4 Feb 2009 10:48:00 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 074D482C518
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 10:46:49 -0500 (EST)
Date: Wed, 4 Feb 2009 10:39:19 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC][PATCH] release mmap_sem before starting migration (Was
 Re: Need to take mmap_sem lock in move_pages.
In-Reply-To: <20090204185501.837ff5d6.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0902041037150.19633@qirst.com>
References: <28631E6913C8074E95A698E8AC93D091B21561@caexch1.virident.info> <20090204183600.f41e8b7e.kamezawa.hiroyu@jp.fujitsu.com> <20090204184028.09a4bbae.kamezawa.hiroyu@jp.fujitsu.com> <20090204185501.837ff5d6.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Swamy Gowda <swamy@virident.com>, linux-kernel@vger.kernel.org, Brice.Goglin@inria.fr, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Feb 2009, KAMEZAWA Hiroyuki wrote:

> mmap_sem can be released after page table walk ends.

No. read lock on mmap_sem must be held since the migrate functions
manipulate page table entries. Concurrent large scale changes to the page
tables (splitting vmas, remapping etc) must not be possible.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
