Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 16BF96B003D
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 09:37:46 -0500 (EST)
Message-ID: <4B264DAA.1080900@redhat.com>
Date: Mon, 14 Dec 2009 09:37:30 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/8] Use io_schedule() instead schedule()
References: <20091211164651.036f5340@annuminas.surriel.com> <20091214210823.BBAE.A69D9226@jp.fujitsu.com> <20091214213026.BBBD.A69D9226@jp.fujitsu.com>
In-Reply-To: <20091214213026.BBBD.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On 12/14/2009 07:30 AM, KOSAKI Motohiro wrote:
> All task sleeping point in vmscan (e.g. congestion_wait) use
> io_schedule. then shrink_zone_begin use it too.

I'm not sure we really are in io wait when waiting on this
queue, but there's a fair chance we may be so this is a
reasonable change.

> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
