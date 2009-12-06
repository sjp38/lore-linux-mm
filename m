Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 77AA360021B
	for <linux-mm@kvack.org>; Sun,  6 Dec 2009 16:04:05 -0500 (EST)
Message-ID: <4B1C1C3F.5050309@redhat.com>
Date: Sun, 06 Dec 2009 16:03:59 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/7] Try to mark PG_mlocked if wipe_page_reference find
 VM_LOCKED vma
References: <20091204173233.5891.A69D9226@jp.fujitsu.com> <20091204174544.58A6.A69D9226@jp.fujitsu.com>
In-Reply-To: <20091204174544.58A6.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>

On 12/04/2009 03:46 AM, KOSAKI Motohiro wrote:
>  From 519178d353926466fcb7411d19424c5e559b6b80 Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> Date: Fri, 4 Dec 2009 16:51:20 +0900
> Subject: [PATCH 7/7] Try to mark PG_mlocked if wipe_page_reference find VM_LOCKED vma
>
> Both try_to_unmap() and wipe_page_reference() walk each ptes, but
> latter doesn't mark PG_mlocked altough find VM_LOCKED vma.
>
> This patch does it.
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
