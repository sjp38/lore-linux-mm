Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C46C96B0033
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 05:45:26 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 11so5630944pge.4
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 02:45:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r16si1113223pfk.88.2017.09.19.02.45.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Sep 2017 02:45:25 -0700 (PDT)
Date: Tue, 19 Sep 2017 11:45:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, memory_hotplug: do not back off draining pcp free
 pages from kworker context
Message-ID: <20170919094521.2vqcnqrx3q2h2axb@dhcp22.suse.cz>
References: <20170828093341.26341-1-mhocko@kernel.org>
 <20170828153359.f9b252f99647eebd339a3a89@linux-foundation.org>
 <6e138348-aa28-8660-d902-96efafe1dcb2@I-love.SAKURA.ne.jp>
 <20170829112823.GA12413@dhcp22.suse.cz>
 <20170831053342.fo7x4hnhicxikme4@dhcp22.suse.cz>
 <20170919033821.GR378890@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170919033821.GR378890@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 18-09-17 20:38:22, Tejun Heo wrote:
> Hello, Sorry about the delay.
> 
> On Thu, Aug 31, 2017 at 07:33:42AM +0200, Michal Hocko wrote:
> > > > Michal, are you sure that this patch does not cause deadlock?
> > > > 
> > > > As shown in "[PATCH] mm: Use WQ_HIGHPRI for mm_percpu_wq." thread, currently work
> > > > items on mm_percpu_wq seem to be blocked by other work items not on mm_percpu_wq.
> 
> IIUC that wasn't a deadlock but more a legitimate starvation from too
> many tasks trying to reclaim directly.
> 
> > > But we have a rescuer so we should make a forward progress eventually.
> > > Or am I missing something. Tejun, could you have a look please?
> > 
> > ping... I would really appreaciate if you could double check my thinking
> > Tejun. This is a tricky area and I would like to prevent further subtle
> > issues here.
> 
> So, this shouldn't be an issue.  This may get affected by direct
> reclaim frenzy but it's only a small piece of the whole symptom and we
> gotta fix that at the source.

OK, so there shouldn't be any issue with the patch, right?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
