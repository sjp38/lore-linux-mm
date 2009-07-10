Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A48A16B004D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 21:03:24 -0400 (EDT)
Date: Fri, 10 Jul 2009 09:23:56 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/5] add shmem vmstat
Message-ID: <20090710012356.GA6809@localhost>
References: <20090709165820.23B7.A69D9226@jp.fujitsu.com> <20090709171452.23C9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090709171452.23C9.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 09, 2009 at 04:18:01PM +0800, KOSAKI Motohiro wrote:
> ChangeLog
>   Since v1
>    - Fixed misaccounting bug on page migration
> 
> ========================
> Subject: [PATCH] add shmem vmstat
> 
> Recently, We faced several OOM problem by plenty GEM cache. and generally,
> plenty Shmem/Tmpfs potentially makes memory shortage problem.
> 
> We often use following calculation to know shmem pages,
>   shmem = NR_ACTIVE_ANON + NR_INACTIVE_ANON - NR_ANON_PAGES
> but it is wrong expression. it doesn't consider isolated page and
> mlocked page.
> 
> Then, This patch make explicit Shmem/Tmpfs vm-stat accounting.
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Acked-by: Wu Fengguang <fengguang.wu@intel.com>

Thanks for the nice work!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
