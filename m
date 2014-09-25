Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id AD8C26B0036
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 01:01:08 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id l18so6236970wgh.21
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 22:01:08 -0700 (PDT)
Received: from mail-wi0-x22b.google.com (mail-wi0-x22b.google.com [2a00:1450:400c:c05::22b])
        by mx.google.com with ESMTPS id i2si261940wiz.1.2014.09.24.22.01.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 24 Sep 2014 22:01:07 -0700 (PDT)
Received: by mail-wi0-f171.google.com with SMTP id ho1so8141484wib.16
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 22:01:06 -0700 (PDT)
Date: Thu, 25 Sep 2014 07:01:03 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 1/5 - resend] SCHED: add some "wait..on_bit...timeout()"
 interfaces.
Message-ID: <20140925050103.GB20431@gmail.com>
References: <20140924012422.4838.29188.stgit@notabene.brown>
 <20140924012832.4838.59410.stgit@notabene.brown>
 <20140924070418.GA990@gmail.com>
 <20140925135519.3ae1fa60@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140925135519.3ae1fa60@notabene.brown>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jeff Layton <jeff.layton@primarydata.com>, Peter Zijlstra <peterz@infradead.org>


* NeilBrown <neilb@suse.de> wrote:

> 
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
> Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> Signed-off-by: NeilBrown <neilb@suse.de>
> 
> ---
> This time with EXPORT_SYMBOL_GPL.

Looks good to me, thanks!

Acked-by: Ingo Molnar <mingo@kernel.org>

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
