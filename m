Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7A36F6B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 07:21:58 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id v77so30302548wmv.5
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 04:21:58 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o39si8958625wrc.14.2017.02.08.04.21.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Feb 2017 04:21:57 -0800 (PST)
Date: Wed, 8 Feb 2017 13:21:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
Message-ID: <20170208122154.GJ5686@dhcp22.suse.cz>
References: <20170207123708.GO5065@dhcp22.suse.cz>
 <20170207135846.usfrn7e4znjhmogn@techsingularity.net>
 <20170207141911.GR5065@dhcp22.suse.cz>
 <20170207153459.GV5065@dhcp22.suse.cz>
 <20170207162224.elnrlgibjegswsgn@techsingularity.net>
 <20170207164130.GY5065@dhcp22.suse.cz>
 <alpine.DEB.2.20.1702071053380.16150@east.gentwo.org>
 <alpine.DEB.2.20.1702072319200.8117@nanos>
 <20170208073527.GA5686@dhcp22.suse.cz>
 <alpine.DEB.2.20.1702081253590.3536@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1702081253590.3536@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed 08-02-17 13:02:07, Thomas Gleixner wrote:
> On Wed, 8 Feb 2017, Michal Hocko wrote:
[...]
> > [1] http://lkml.kernel.org/r/20170207201950.20482-1-mhocko@kernel.org
> 
> Well, yes. It's simple, but from an RT point of view I really don't like
> it as we have to fix it up again.

I thought that preempt_disable would turn into migrate_disable or
something like that which shouldn't cause too much trouble. Or am I
missing something? Which part of the patch is so RT unfriendly?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
