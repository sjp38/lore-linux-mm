Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 47EC76B005A
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 10:42:21 -0400 (EDT)
Message-ID: <4A5605CD.6070705@redhat.com>
Date: Thu, 09 Jul 2009 10:59:25 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5][resend] add per-zone statistics to show_free_areas()
References: <20090709165820.23B7.A69D9226@jp.fujitsu.com> <20090709170535.23BA.A69D9226@jp.fujitsu.com>
In-Reply-To: <20090709170535.23BA.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> Subject: [PATCH] add per-zone statistics to show_free_areas()
> 
> show_free_areas() displays only a limited amount of zone counters. This
> patch includes additional counters in the display to allow easier
> debugging. This may be especially useful if an OOM is due to running out
> of DMA memory.
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
> Acked-by: Wu Fengguang <fengguang.wu@intel.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
