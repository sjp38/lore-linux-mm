Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7335C6B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 15:55:46 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id ma3so3156989pbc.13
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 12:55:46 -0800 (PST)
Received: from mail-pb0-x232.google.com (mail-pb0-x232.google.com [2607:f8b0:400e:c01::232])
        by mx.google.com with ESMTPS id sh5si6037191pbc.260.2014.03.06.12.55.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Mar 2014 12:55:45 -0800 (PST)
Received: by mail-pb0-f50.google.com with SMTP id md12so3140614pbc.37
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 12:55:45 -0800 (PST)
Date: Thu, 6 Mar 2014 12:55:43 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 00/11] userspace out of memory handling
In-Reply-To: <20140306204923.GF14033@htj.dyndns.org>
Message-ID: <alpine.DEB.2.02.1403061254240.25499@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com> <20140306204923.GF14033@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, Tim Hockin <thockin@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org

On Thu, 6 Mar 2014, Tejun Heo wrote:

> On Tue, Mar 04, 2014 at 07:58:38PM -0800, David Rientjes wrote:
> > This patchset implements userspace out of memory handling.
> > 
> > It is based on v3.14-rc5.  Individual patches will apply cleanly or you
> > may pull the entire series from
> > 
> > 	git://git.kernel.org/pub/scm/linux/kernel/git/rientjes/linux.git mm/oom
> > 
> > When the system or a memcg is oom, processes running on that system or
> > attached to that memcg cannot allocate memory.  It is impossible for a
> > process to reliably handle the oom condition from userspace.
> 
> ISTR the conclusion last time was nack on the whole approach.  What
> changed between then and now?  I can't detect any fundamental changes
> from the description.
> 

This includes system oom handling alongside memcg oom handling.  If you 
have specific objections, please let us know, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
