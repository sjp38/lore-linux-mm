Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id DC2F52803BB
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 07:48:36 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id x13so499707wre.7
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 04:48:36 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u21si3429744wrf.190.2017.08.24.04.48.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Aug 2017 04:48:35 -0700 (PDT)
Date: Thu, 24 Aug 2017 13:48:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Intermittent memory corruption with v4.13-rc6+ and earlier
Message-ID: <20170824114833.GH5943@dhcp22.suse.cz>
References: <20170824113743.GA14737@leverpostej>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170824113743.GA14737@leverpostej>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: linux-kernel@vger.kernel.org, syzkaller@googlegroups.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, will.deacon@arm.com

On Thu 24-08-17 12:37:43, Mark Rutland wrote:
> Hi,
> 
> I'm chasing intermittent memory corruption bugs seen at least on rc5,
> rc6, and yesterday's HEAD (98b9f8a4549909c6), on arm64. 
> 
> It looks like we make use of dangling references to a freed struct file,
> which is caught by KASAN. Without KASAN, I see a number of other
> intermittent issues that I suspect are the result of this memory
> corruption. I've included an example splat below, complete with KASAN's
> alloc/free traces at the end of this mail.

Is it possible this is the same issue as the one fixed by
http://lkml.kernel.org/r/20170823211408.31198-1-ebiggers3@gmail.com?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
