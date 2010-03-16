Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0F8266B00E5
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 13:52:23 -0400 (EDT)
Date: Tue, 16 Mar 2010 18:51:23 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] exit: fix oops in sync_mm_rss
Message-ID: <20100316175123.GD5717@random.random>
References: <20100316170808.GA29400@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100316170808.GA29400@redhat.com>
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: cl@linux-foundation.org, lee.schermerhorn@hp.com, rientjes@google.com, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, "David S. Miller" <davem@davemloft.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 16, 2010 at 07:08:08PM +0200, Michael S. Tsirkin wrote:
> The module in question calls use_mm and later unuse_mm from a kernel
> thread.  It is when this kernel thread is destroyed that the crash
> happens.

Looks good to me so the stats are transferred to mm before we lose
track of it.

Ack!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
