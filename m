Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 12BCF6B005A
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 16:27:31 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3896182C518
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 17:05:15 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Nb6dutoN8m6k for <linux-mm@kvack.org>;
	Thu,  9 Jul 2009 17:05:15 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 6890F82C517
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 17:05:08 -0400 (EDT)
Date: Thu, 9 Jul 2009 16:46:36 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 5/5] add shmem vmstat
In-Reply-To: <20090709171452.23C9.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0907091643240.17835@gentwo.org>
References: <20090709165820.23B7.A69D9226@jp.fujitsu.com> <20090709171452.23C9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Thu, 9 Jul 2009, KOSAKI Motohiro wrote:

> Recently, We faced several OOM problem by plenty GEM cache. and generally,
> plenty Shmem/Tmpfs potentially makes memory shortage problem.

"
Recently we encountered OOM problems due to memory use of the GEM cache.
Generally a large amuont of Shmem/Tmpfs pages tend to create a memory
shortage problem.
"

> We often use following calculation to know shmem pages,
>   shmem = NR_ACTIVE_ANON + NR_INACTIVE_ANON - NR_ANON_PAGES
> but it is wrong expression. it doesn't consider isolated page and
> mlocked page.

"
We often use the following calculation to determine the amount of shmem
pages:

shmem = NR_ACTIVE_ANON + NR_INACTIVE_ANON - NR_ANON_PAGES

however the expression does not consider isoalted and mlocked pages.
"

> Then, This patch make explicit Shmem/Tmpfs vm-stat accounting.

"
This patch adds explicit accounting for pages used by shmem and tmpfs.
"

Reviewed-by: Christoph Lameter <cl@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
