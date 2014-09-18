Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 21B036B008C
	for <linux-mm@kvack.org>; Thu, 18 Sep 2014 10:42:29 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id y13so510361pdi.16
        for <linux-mm@kvack.org>; Thu, 18 Sep 2014 07:42:28 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id v11si39946247pas.219.2014.09.18.07.42.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Sep 2014 07:42:27 -0700 (PDT)
Date: Thu, 18 Sep 2014 16:42:22 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 1/4] SCHED: add some "wait..on_bit...timeout()"
 interfaces.
Message-ID: <20140918144222.GP2840@worktop.localdomain>
References: <20140916051911.22257.24658.stgit@notabene.brown>
 <20140916053134.22257.28841.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140916053134.22257.28841.stgit@notabene.brown>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, Ingo Molnar <mingo@redhat.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, Jeff Layton <jeff.layton@primarydata.com>

On Tue, Sep 16, 2014 at 03:31:35PM +1000, NeilBrown wrote:
> In commit c1221321b7c25b53204447cff9949a6d5a7ddddc
>    sched: Allow wait_on_bit_action() functions to support a timeout
> 
> I suggested that a "wait_on_bit_timeout()" interface would not meet my
> need.  This isn't true - I was just over-engineering.
> 
> Including a 'private' field in wait_bit_key instead of a focused
> "timeout" field was just premature generalization.  If some other
> use is ever found, it can be generalized or added later.
> 
> So this patch renames "private" to "timeout" with a meaning "stop
> waiting when "jiffies" reaches or passes "timeout",
> and adds two of the many possible wait..bit..timeout() interfaces:
> 
> wait_on_page_bit_killable_timeout(), which is the one I want to use,
> and out_of_line_wait_on_bit_timeout() which is a reasonably general
> example.  Others can be added as needed.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
>  include/linux/pagemap.h |    2 ++
>  include/linux/wait.h    |    5 ++++-
>  kernel/sched/wait.c     |   36 ++++++++++++++++++++++++++++++++++++
>  mm/filemap.c            |   13 +++++++++++++
>  4 files changed, 55 insertions(+), 1 deletion(-)
> 

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
