Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 695026B003D
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 17:04:36 -0500 (EST)
Date: Thu, 7 Jan 2010 16:04:00 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 1/7] Allow CONFIG_MIGRATION to be set without
 CONFIG_NUMA
In-Reply-To: <alpine.DEB.2.00.1001071331520.23894@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1001071603260.6864@router.home>
References: <1262795169-9095-1-git-send-email-mel@csn.ul.ie> <1262795169-9095-2-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1001071331520.23894@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 7 Jan 2010, David Rientjes wrote:

> CONFIG_MIGRATION is no longer strictly dependent on CONFIG_NUMA since
> ARCH_ENABLE_MEMORY_HOTREMOVE has allowed it to be configured for UMA
> machines.  All strictly NUMA features in the migration core should be
> isolated under its #ifdef CONFIG_NUMA (sys_move_pages()) in mm/migrate.c
> or by simply not compiling mm/mempolicy.c (sys_migrate_pages()), so this
> patch looks fine as is (although the "help" text for CONFIG_MIGRATION
> could be updated to reflect that it's useful for both memory hot-remove
> and now compaction).

Correct.

Reviewed-by: Christoph Lameter <cl@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
