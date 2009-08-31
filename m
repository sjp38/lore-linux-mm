Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6BF266B004D
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 19:43:11 -0400 (EDT)
Message-ID: <4A9C5FD3.9030102@redhat.com>
Date: Mon, 31 Aug 2009 19:42:11 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/vsmcan: check shrink_active_list() sc->isolate_pages()
 return value.
References: <1251759241-15167-1-git-send-email-macli@brc.ubc.ca>
In-Reply-To: <1251759241-15167-1-git-send-email-macli@brc.ubc.ca>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Vincent Li <macli@brc.ubc.ca>
Cc: linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Vincent Li wrote:
> commit 5343daceec (If sc->isolate_pages() return 0...) make shrink_inactive_list handle
> sc->isolate_pages() return value properly. Add similar proper return value check for
> shrink_active_list() sc->isolate_pages().
> 
> Signed-off-by: Vincent Li <macli@brc.ubc.ca>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
