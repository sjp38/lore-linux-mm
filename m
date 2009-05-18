Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6BFBF6B004F
	for <linux-mm@kvack.org>; Sun, 17 May 2009 23:33:33 -0400 (EDT)
Date: Mon, 18 May 2009 11:33:37 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/4] vmscan: drop PF_SWAPWRITE from zone_reclaim
Message-ID: <20090518033337.GD5869@localhost>
References: <20090513120155.5879.A69D9226@jp.fujitsu.com> <20090513120627.587F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090513120627.587F.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 13, 2009 at 12:06:51PM +0900, KOSAKI Motohiro wrote:
> Subject: [PATCH] vmscan: drop PF_SWAPWRITE from zone_reclaim
> 
> PF_SWAPWRITE mean ignore write congestion. (see may_write_to_queue())
> 
> foreground reclaim shouldn't ignore it because to write congested device cause
> large IO lantency.
> it isn't better than remote node allocation.

Acked-by: Wu Fengguang <fengguang.wu@intel.com> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
