Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8C5126B004D
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 08:33:32 -0400 (EDT)
Date: Thu, 16 Jul 2009 20:33:21 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/3] Rename pgmoved variable in shrink_active_list()
Message-ID: <20090716123321.GA28895@localhost>
References: <20090716094619.9D07.A69D9226@jp.fujitsu.com> <20090716095119.9D0A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090716095119.9D0A.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 16, 2009 at 08:52:34AM +0800, KOSAKI Motohiro wrote:
> Subject: [PATCH] Rename pgmoved variable in shrink_active_list()
> 
> Currently, pgmoved variable have two meanings. it cause harder reviewing a bit.
> This patch separate it.
>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: Wu Fengguang <fengguang.wu@intel.com> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
