Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CBDAE6B004F
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 12:31:53 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 186E782C5FC
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 12:51:50 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id gmbyozv1+YFJ for <linux-mm@kvack.org>;
	Tue,  7 Jul 2009 12:51:50 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id C2AC582C5FE
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 12:51:44 -0400 (EDT)
Date: Tue, 7 Jul 2009 12:33:21 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 1/5] add per-zone statistics to show_free_areas()
In-Reply-To: <20090705182259.08F6.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0907071231220.5124@gentwo.org>
References: <20090705181400.08F1.A69D9226@jp.fujitsu.com> <20090705182259.08F6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, 5 Jul 2009, KOSAKI Motohiro wrote:

> Subject: [PATCH] add per-zone statistics to show_free_areas()
>
> Currently, show_free_area() mainly display system memory usage. but it
> doesn't display per-zone memory usage information.

An attempt to rewrite the description:

show_free_areas() displays only a limited amount of zone counters. This
patch includes additional counters in the display to allow easier
debugging. This may be especially useful if an OOM is due to running out
of DMA memory.

Reviewed-by: Christoph Lameter <cl@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
