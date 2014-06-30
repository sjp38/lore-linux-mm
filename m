Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id CDB126B0039
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 18:09:16 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kq14so9346837pab.34
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 15:09:16 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id th10si24685897pab.18.2014.06.30.15.09.15
        for <linux-mm@kvack.org>;
        Mon, 30 Jun 2014 15:09:16 -0700 (PDT)
Date: Mon, 30 Jun 2014 15:09:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] mm: page_alloc: Reduce cost of the fair zone
 allocation policy
Message-Id: <20140630150914.6db3805c28c60283deb94206@linux-foundation.org>
In-Reply-To: <20140630215121.GQ10819@suse.de>
References: <1404146883-21414-1-git-send-email-mgorman@suse.de>
	<1404146883-21414-5-git-send-email-mgorman@suse.de>
	<20140630141404.e09bdb5fa6a879d17c4556b1@linux-foundation.org>
	<20140630215121.GQ10819@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, 30 Jun 2014 22:51:21 +0100 Mel Gorman <mgorman@suse.de> wrote:

> > That's a large change in system time.  Does this all include kswapd
> > activity?
> > 
> 
> I don't have a profile to quantify that exactly. It takes 7 hours to
> complete a test on that machine in this configuration

That's nuts.  Why should measuring this require more than a few minutes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
