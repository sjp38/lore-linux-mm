Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1ADAD6B0044
	for <linux-mm@kvack.org>; Sun,  6 Dec 2009 14:42:01 -0500 (EST)
Message-ID: <4B1C0902.1050209@redhat.com>
Date: Sun, 06 Dec 2009 14:41:54 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/7] VM_LOCKED check don't need pte lock
References: <20091204173233.5891.A69D9226@jp.fujitsu.com> <20091204174217.589A.A69D9226@jp.fujitsu.com>
In-Reply-To: <20091204174217.589A.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>

On 12/04/2009 03:42 AM, KOSAKI Motohiro wrote:
>  From 24f910b1ac966c21ea5aab825d1f26815b760304 Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> Date: Thu, 3 Dec 2009 16:06:47 +0900
> Subject: [PATCH 3/7] VM_LOCKED check don't need pte lock
>
> Currently, page_referenced_one() check VM_LOCKED after taking ptelock.
> But it's unnecessary. We can check VM_LOCKED before to take lock.
>
> This patch does it.

Nice optimization.

> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
