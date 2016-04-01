Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 78EA06B0253
	for <linux-mm@kvack.org>; Fri,  1 Apr 2016 16:15:00 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id tt10so98497070pab.3
        for <linux-mm@kvack.org>; Fri, 01 Apr 2016 13:15:00 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m67si22659521pfi.45.2016.04.01.13.14.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Apr 2016 13:14:59 -0700 (PDT)
Date: Fri, 1 Apr 2016 13:14:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: vmscan: reclaim highmem zone if buffer_heads is
 over limit
Message-Id: <20160401131458.e31d45f56a98c62669b35e3d@linux-foundation.org>
In-Reply-To: <20160401080350.GB8916@dhcp22.suse.cz>
References: <1459497658-22203-1-git-send-email-minchan@kernel.org>
	<20160401080350.GB8916@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>

On Fri, 1 Apr 2016 10:03:50 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> On Fri 01-04-16 17:00:58, Minchan Kim wrote:
> [...]
> > [2] commit 5acbd3bfc93b ("mm, oom: rework oom detection")
> 
> I didn't look a tht patch yet but wanted to note that this sha is most
> probably from linux-next and won't be stable. Also this patch will most
> likely see some changes in future so making changes on top which should
> go in independetly will likely just complicate things.

Yes, we'll need two patches please.  One to fix 6b4f7799c6a5 ("mm:
vmscan: invoke slab shrinkers from shrink_zone()") (which is in
mainline) and a second to clean up -mm's "mm, oom: rework oom detection".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
