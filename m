Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DC3EF6B005C
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 10:44:30 -0400 (EDT)
Message-ID: <4A560651.3090708@redhat.com>
Date: Thu, 09 Jul 2009 11:01:37 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5][resend] Show kernel stack usage to /proc/meminfo
 and OOM log
References: <20090709165820.23B7.A69D9226@jp.fujitsu.com> <20090709171122.23C3.A69D9226@jp.fujitsu.com>
In-Reply-To: <20090709171122.23C3.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> Subject: [PATCH] Show kernel stack usage to /proc/meminfo and OOM log
> 
> The amount of memory allocated to kernel stacks can become significant and
> cause OOM conditions. However, we do not display the amount of memory
> consumed by stacks.'
> 
> Add code to display the amount of memory used for stacks in /proc/meminfo.
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Reviewed-by: <cl@linux-foundation.org>

Reviewed-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
