Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 3B2216B002B
	for <linux-mm@kvack.org>; Mon, 27 Aug 2012 00:19:40 -0400 (EDT)
Received: from canuck.infradead.org ([2001:4978:20e::1])
	by merlin.infradead.org with esmtps (Exim 4.76 #1 (Red Hat Linux))
	id 1T5qna-0000Lr-NP
	for linux-mm@kvack.org; Mon, 27 Aug 2012 04:19:38 +0000
Received: from dhcp-089-099-019-018.chello.nl ([89.99.19.18] helo=dyad.programming.kicks-ass.net)
	by canuck.infradead.org with esmtpsa (Exim 4.76 #1 (Red Hat Linux))
	id 1T5qna-0004qH-ER
	for linux-mm@kvack.org; Mon, 27 Aug 2012 04:19:38 +0000
Subject: Re: [PATCH 2/3] mm: Move the tlb flushing into free_pgtables
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1345975899-2236-3-git-send-email-haggaie@mellanox.com>
References: <1345975899-2236-1-git-send-email-haggaie@mellanox.com>
	 <1345975899-2236-3-git-send-email-haggaie@mellanox.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 27 Aug 2012 06:19:14 +0200
Message-ID: <1346041154.2296.1.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Haggai Eran <haggaie@mellanox.com>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Sagi Grimberg <sagig@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Christoph Lameter <clameter@sgi.com>

On Sun, 2012-08-26 at 13:11 +0300, Haggai Eran wrote:
> 
> The conversion of the locks taken for reverse map scanning would
> require taking sleeping locks in free_pgtables() and we cannot sleep
> while gathering pages for a tlb flush. 

We can.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
