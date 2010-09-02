Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2FBE56B0078
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 11:41:05 -0400 (EDT)
Message-ID: <4C7FC585.9090401@redhat.com>
Date: Thu, 02 Sep 2010 11:40:53 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] vmscan: prevent background aging of anon page in no
 swap system
References: <1283441862-15855-1-git-send-email-minchan.kim@gmail.com>
In-Reply-To: <1283441862-15855-1-git-send-email-minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On 09/02/2010 11:37 AM, Minchan Kim wrote:

> This patch prevents unnecessary anon pages demotion in not-yet-swapon and
> non-configured swap system. Even, in non-configuared swap system
> inactive_anon_is_low can be compiled out.

> Cc: Rik van Riel<riel@redhat.com>
> Cc: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> Cc: Johannes Weiner<hannes@cmpxchg.org>
> Signed-off-by: Ying Han<yinghan@google.com>
> Signed-off-by: Minchan Kim<minchan.kim@gmail.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
