Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 075636B01B1
	for <linux-mm@kvack.org>; Thu, 20 May 2010 22:00:32 -0400 (EDT)
Message-ID: <4BF5E92C.5020507@redhat.com>
Date: Thu, 20 May 2010 22:00:12 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] tmpfs: Insert tmpfs cache pages to inactive list at first
References: <20100519174327.9591.A69D9226@jp.fujitsu.com> <alpine.DEB.1.00.1005201822120.19421@tigran.mtv.corp.google.com>
In-Reply-To: <alpine.DEB.1.00.1005201822120.19421@tigran.mtv.corp.google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 05/20/2010 09:31 PM, Hugh Dickins wrote:

> Acked-by: Hugh Dickins<hughd@google.com>
>
> Thanks - though I don't quite agree with your description: I can't
> see why the lru_cache_add_active_anon() was ever justified - that
> "active" came in along with the separate anon and file LRU lists.

I guess I kind of expected that function to be used by
anonymous pages, when I wrote it.  Except we use a
different variant from do_anonymous_page :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
