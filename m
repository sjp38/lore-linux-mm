Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 175BE6B0044
	for <linux-mm@kvack.org>; Sun,  6 Dec 2009 09:55:43 -0500 (EST)
Message-ID: <4B1BC5EA.5040200@redhat.com>
Date: Sun, 06 Dec 2009 09:55:38 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/7] Introduce __page_check_address
References: <20091204173233.5891.A69D9226@jp.fujitsu.com> <20091204174139.5897.A69D9226@jp.fujitsu.com>
In-Reply-To: <20091204174139.5897.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>

On 12/04/2009 03:42 AM, KOSAKI Motohiro wrote:
>  From 381108e1ff6309f45f45a67acf2a1dd66e41df4f Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> Date: Thu, 3 Dec 2009 15:01:42 +0900
> Subject: [PATCH 2/7] Introduce __page_check_address
>
> page_check_address() need to take ptelock. but it might be contended.
> Then we need trylock version and this patch introduce new helper function.
>
> it will be used latter patch.
>
> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
