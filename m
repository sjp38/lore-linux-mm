Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A601A6B00E5
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 13:54:13 -0400 (EDT)
Message-ID: <4B9FC557.2060002@redhat.com>
Date: Tue, 16 Mar 2010 13:52:23 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] exit: fix oops in sync_mm_rss
References: <20100316170808.GA29400@redhat.com>
In-Reply-To: <20100316170808.GA29400@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: cl@linux-foundation.org, lee.schermerhorn@hp.com, rientjes@google.com, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, "David S. Miller" <davem@davemloft.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 03/16/2010 01:08 PM, Michael S. Tsirkin wrote:

> (note: handle_rx_net is a work item using workqueue in question).
> sync_mm_rss+0x33/0x6f gave me a hint. I also tried reverting
> 34e55232e59f7b19050267a05ff1226e5cd122a5 and the oops goes away.
>
> The module in question calls use_mm and later unuse_mm from a kernel
> thread.  It is when this kernel thread is destroyed that the crash
> happens.
>
> Signed-off-by: Michael S. Tsirkin<mst@redhat.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
