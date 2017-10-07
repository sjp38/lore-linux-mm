Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 25C916B025E
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 22:51:44 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r202so13923253wmd.1
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 19:51:44 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id t18si1148271edd.339.2017.10.06.19.51.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 06 Oct 2017 19:51:42 -0700 (PDT)
Date: Fri, 6 Oct 2017 22:51:31 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2] Revert "vmalloc: back off when the current task is
 killed"
Message-ID: <20171007025131.GA12944@cmpxchg.org>
References: <20171003225504.GA966@cmpxchg.org>
 <20171004185813.GA2136@cmpxchg.org>
 <20171004185906.GB2136@cmpxchg.org>
 <20171004153245.2b08d831688bb8c66ef64708@linux-foundation.org>
 <20171004231821.GA3610@cmpxchg.org>
 <20171005075704.enxdgjteoe4vgbag@dhcp22.suse.cz>
 <55d8bf19-3f29-6264-f954-8749ea234efd@I-love.SAKURA.ne.jp>
 <ceb25fb9-de4d-e401-6d6d-ce240705483c@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ceb25fb9-de4d-e401-6d6d-ce240705483c@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Alan Cox <alan@llwyncelyn.cymru>, Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Sat, Oct 07, 2017 at 11:21:26AM +0900, Tetsuo Handa wrote:
> On 2017/10/05 19:36, Tetsuo Handa wrote:
> > I don't want this patch backported. If you want to backport,
> > "s/fatal_signal_pending/tsk_is_oom_victim/" is the safer way.
> 
> If you backport this patch, you will see "complete depletion of memory reserves"
> and "extra OOM kills due to depletion of memory reserves" using below reproducer.
> 
> ----------
> #include <linux/module.h>
> #include <linux/slab.h>
> #include <linux/oom.h>
> 
> static char *buffer;
> 
> static int __init test_init(void)
> {
> 	set_current_oom_origin();
> 	buffer = vmalloc((1UL << 32) - 480 * 1048576);

That's not a reproducer, that's a kernel module. It's not hard to
crash the kernel from within the kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
