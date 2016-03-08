Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 19E826B0005
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 04:23:16 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id bj10so8737108pad.2
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 01:23:16 -0800 (PST)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id tw5si3497985pac.131.2016.03.08.01.23.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 01:23:15 -0800 (PST)
Received: by mail-pa0-x242.google.com with SMTP id hj7so837089pac.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 01:23:15 -0800 (PST)
Date: Tue, 8 Mar 2016 18:24:35 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm, oom: protect !costly allocations some more (was: Re:
 [PATCH 0/3] OOM detection rework v4)
Message-ID: <20160308092435.GA3860@swordfish>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160225092315.GD17573@dhcp22.suse.cz>
 <20160229210213.GX16930@dhcp22.suse.cz>
 <20160307160838.GB5028@dhcp22.suse.cz>
 <20160308035104.GA447@swordfish>
 <20160308090818.GA13542@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160308090818.GA13542@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <js1304@gmail.com>, Vlastimil Babka <vbabka@suse.cz>

On (03/08/16 10:08), Michal Hocko wrote:
> On Tue 08-03-16 12:51:04, Sergey Senozhatsky wrote:
> > Hello Michal,
> > 
> > On (03/07/16 17:08), Michal Hocko wrote:
> > > On Mon 29-02-16 22:02:13, Michal Hocko wrote:
> > > > Andrew,
> > > > could you queue this one as well, please? This is more a band aid than a
> > > > real solution which I will be working on as soon as I am able to
> > > > reproduce the issue but the patch should help to some degree at least.
> > > 
> > > Joonsoo wasn't very happy about this approach so let me try a different
> > > way. What do you think about the following? Hugh, Sergey does it help
> > > for your load? I have tested it with the Hugh's load and there was no
> > > major difference from the previous testing so at least nothing has blown
> > > up as I am not able to reproduce the issue here.
> > 
> > (next-20160307 + "[PATCH] mm, oom: protect !costly allocations some more")
> > 
> > seems it's significantly less likely to oom-kill now, but I still can see
> > something like this
> 
> Thanks for the testing. This is highly appreciated. If you are able to
> reproduce this then collecting compaction related tracepoints might be
> really helpful.
> 

oh, wow... compaction is disabled, somehow.

  $ zcat /proc/config.gz | grep -i CONFIG_COMPACTION
  # CONFIG_COMPACTION is not set

I should have checked that, sorry!

will enable and re-test.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
