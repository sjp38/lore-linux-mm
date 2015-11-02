Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8CB0082F64
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 14:20:57 -0500 (EST)
Received: by ykft191 with SMTP id t191so149471426ykf.0
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 11:20:57 -0800 (PST)
Received: from mail-yk0-x232.google.com (mail-yk0-x232.google.com. [2607:f8b0:4002:c07::232])
        by mx.google.com with ESMTPS id w23si10191894ywa.92.2015.11.02.11.20.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Nov 2015 11:20:56 -0800 (PST)
Received: by ykft191 with SMTP id t191so149471061ykf.0
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 11:20:56 -0800 (PST)
Date: Mon, 2 Nov 2015 14:20:53 -0500
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
Message-ID: <20151102192053.GC9553@mtj.duckdns.org>
References: <20151022140944.GA30579@mtj.duckdns.org>
 <20151022142155.GB30579@mtj.duckdns.org>
 <alpine.DEB.2.20.1510220923130.23591@east.gentwo.org>
 <20151022142429.GC30579@mtj.duckdns.org>
 <alpine.DEB.2.20.1510220925160.23638@east.gentwo.org>
 <20151022143349.GD30579@mtj.duckdns.org>
 <alpine.DEB.2.20.1510220939310.23718@east.gentwo.org>
 <20151022151414.GF30579@mtj.duckdns.org>
 <20151023042649.GB18907@mtj.duckdns.org>
 <20151102150137.GB3442@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151102150137.GB3442@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, David Rientjes <rientjes@google.com>, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

On Mon, Nov 02, 2015 at 04:01:37PM +0100, Michal Hocko wrote:
...
> which is perfectly suited for the stable backport, OOM sysrq resp. any
> sysrq which runs from the WQ context should be as robust as possible and
> shouldn't rely on all the code running from WQ context to issue a sleep
> to get unstuck. So I definitely support something like this patch.

Well, sysrq wouldn't run successfully either on a cpu which is busy
looping with preemption off.  I don't think this calls for a new flag
to modify workqueue behavior especially given that missing such flag
would lead to the same kind of lockup.  It's a shitty solution.  If
the possibility of sysrq getting stuck behind concurrency management
is an issue, queueing them on an unbound or highpri workqueue should
be good enough.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
