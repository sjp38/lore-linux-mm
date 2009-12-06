Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BDF3F60021B
	for <linux-mm@kvack.org>; Sun,  6 Dec 2009 15:32:06 -0500 (EST)
Message-ID: <4B1C14BD.1030202@redhat.com>
Date: Sun, 06 Dec 2009 15:31:57 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/7] Replace page_referenced() with wipe_page_reference()
References: <20091204173233.5891.A69D9226@jp.fujitsu.com> <20091204174253.589D.A69D9226@jp.fujitsu.com>
In-Reply-To: <20091204174253.589D.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>

On 12/04/2009 03:43 AM, KOSAKI Motohiro wrote:
>  From d9110c2804a4b88e460edada140b8bb0f7eb3a18 Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> Date: Fri, 4 Dec 2009 11:45:18 +0900
> Subject: [PATCH 4/7] Replace page_referenced() with wipe_page_reference()
>
> page_referenced() imply "test the page was referenced or not", but
> shrink_active_list() use it for drop pte young bit. then, it should be
> renamed.
>
> Plus, vm_flags argument is really ugly. instead, introduce new
> struct page_reference_context, it's for collect some statistics.
>
> This patch doesn't have any behavior change.
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
