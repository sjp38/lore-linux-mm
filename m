Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 74A8D6B0044
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 21:44:19 -0500 (EST)
Message-ID: <4B28497A.90606@redhat.com>
Date: Tue, 15 Dec 2009 21:44:10 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/8] Use prepare_to_wait_exclusive() instead prepare_to_wait()
References: <1260855146.6126.30.camel@marge.simson.net> <4B27A417.3040206@redhat.com> <20091216093533.CDF1.A69D9226@jp.fujitsu.com>
In-Reply-To: <20091216093533.CDF1.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mike Galbraith <efault@gmx.de>, lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On 12/15/2009 07:48 PM, KOSAKI Motohiro wrote:

> if we really need wait a bit, Mike's wake_up_batch is best, I think.
> It mean
>   - if another CPU is idle, wake up one process soon. iow, it don't
>     make meaningless idle.
>   - if another CPU is busy, woken process don't start to run awhile.
>     then, zone_watermark_ok() can calculate correct value.

Agreed, that should work great.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
