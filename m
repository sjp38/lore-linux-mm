Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7B0C56B0031
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 17:48:35 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id rr13so6356623pbb.32
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 14:48:35 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id xs3si23557296pbb.247.2014.06.23.14.48.34
        for <linux-mm@kvack.org>;
        Mon, 23 Jun 2014 14:48:34 -0700 (PDT)
Date: Mon, 23 Jun 2014 14:48:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv2 6/6] mm/zpool: prevent zbud/zsmalloc from unloading
 when used
Message-Id: <20140623144831.83abcda7446956e8d7502f09@linux-foundation.org>
In-Reply-To: <1401747586-11861-7-git-send-email-ddstreet@ieee.org>
References: <1400958369-3588-1-git-send-email-ddstreet@ieee.org>
	<1401747586-11861-1-git-send-email-ddstreet@ieee.org>
	<1401747586-11861-7-git-send-email-ddstreet@ieee.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>, Nitin Gupta <ngupta@vflare.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Mon,  2 Jun 2014 18:19:46 -0400 Dan Streetman <ddstreet@ieee.org> wrote:

> Add try_module_get() to zpool_create_pool(), and module_put() to
> zpool_destroy_pool().  Without module usage counting, the driver module(s)
> could be unloaded while their pool(s) were active, resulting in an oops
> when zpool tried to access them.

Was wondering about that ;)  We may as well fold
this fix into "mm/zpool: implement common zpool api to zbud/zsmalloc"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
