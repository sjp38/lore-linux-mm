Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6D0626B004D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 06:05:04 -0400 (EDT)
Received: by gxk3 with SMTP id 3so73643gxk.14
        for <linux-mm@kvack.org>; Thu, 09 Jul 2009 03:20:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090709171122.23C3.A69D9226@jp.fujitsu.com>
References: <20090709165820.23B7.A69D9226@jp.fujitsu.com>
	 <20090709171122.23C3.A69D9226@jp.fujitsu.com>
Date: Thu, 9 Jul 2009 19:20:47 +0900
Message-ID: <28c262360907090320r51acdbedwee36e7af54bbd9f1@mail.gmail.com>
Subject: Re: [PATCH 3/5][resend] Show kernel stack usage to /proc/meminfo and
	OOM log
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 9, 2009 at 5:12 PM, KOSAKI
Motohiro<kosaki.motohiro@jp.fujitsu.com> wrote:
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
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
