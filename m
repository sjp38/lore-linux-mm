Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8C8896B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 10:21:10 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id v77so31230231wmv.5
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 07:21:10 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m87si2806065wmc.35.2017.02.08.07.21.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Feb 2017 07:21:09 -0800 (PST)
Date: Wed, 8 Feb 2017 16:21:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
Message-ID: <20170208152106.GP5686@dhcp22.suse.cz>
References: <20170207123708.GO5065@dhcp22.suse.cz>
 <20170207135846.usfrn7e4znjhmogn@techsingularity.net>
 <20170207141911.GR5065@dhcp22.suse.cz>
 <20170207153459.GV5065@dhcp22.suse.cz>
 <20170207162224.elnrlgibjegswsgn@techsingularity.net>
 <20170207164130.GY5065@dhcp22.suse.cz>
 <alpine.DEB.2.20.1702071053380.16150@east.gentwo.org>
 <alpine.DEB.2.20.1702072319200.8117@nanos>
 <20170208073527.GA5686@dhcp22.suse.cz>
 <alpine.DEB.2.20.1702080906540.3955@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1702080906540.3955@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed 08-02-17 09:11:06, Cristopher Lameter wrote:
> On Wed, 8 Feb 2017, Michal Hocko wrote:
> 
> > > Huch? stop_machine() is horrible and heavy weight. Don't go there, there
> > > must be simpler solutions than that.
> >
> > Absolutely agreed. We are in the page allocator path so using the
> > stop_machine* is just ridiculous. And, in fact, there is a much simpler
> > solution [1]
> 
> That is nonsense. stop_machine would be used when adding removing a
> processor. There would be no need to synchronize when looping over active
> cpus anymore. get_online_cpus() etc would be removed from the hot
> path since the cpu masks are guaranteed to be stable.

I have no idea what you are trying to say and how this is related to the
deadlock we are discussing here. We certainly do not need to add
stop_machine the problem. And yeah, dropping get_online_cpus was
possible after considering all fallouts.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
