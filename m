Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id B6CF082F69
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 20:53:27 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id b205so180024688wmb.1
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 17:53:27 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id pe3si41507500wjb.132.2016.02.22.17.53.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Feb 2016 17:53:26 -0800 (PST)
Date: Mon, 22 Feb 2016 17:53:18 -0800
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2] mm: scale kswapd watermarks in proportion to memory
Message-ID: <20160223015318.GA30924@cmpxchg.org>
References: <1456184002-15729-1-git-send-email-hannes@cmpxchg.org>
 <1456191393.7716.28.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456191393.7716.28.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Feb 22, 2016 at 08:36:33PM -0500, Rik van Riel wrote:
> On Mon, 2016-02-22 at 15:33 -0800, Johannes Weiner wrote:
> 
> > Beyond 1G of memory, this will produce bigger watermark steps than 
> 
> Is that supposed to be beyond 16GB?

The old formula formula is

  min = sqrt(kb * 16)
  low = min >> 2

and the new one is

  low = kb * 0.001

and

  sqrt(x/1024 * 16) >> 2 = x/1024 * 0.001

puts x at

  x = 1 << 30

Did I miss something?

> Acked-by: Rik van Riel <riel@redhat.com>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
