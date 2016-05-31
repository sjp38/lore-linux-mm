Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8698F6B025E
	for <linux-mm@kvack.org>; Tue, 31 May 2016 17:05:39 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id fg1so337552213pad.1
        for <linux-mm@kvack.org>; Tue, 31 May 2016 14:05:39 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id s75si33098523pfa.111.2016.05.31.14.05.38
        for <linux-mm@kvack.org>;
        Tue, 31 May 2016 14:05:38 -0700 (PDT)
Date: Tue, 31 May 2016 17:13:08 -0400
From: Keith Busch <keith.busch@intel.com>
Subject: Re: [PATCH] mm/swap: lru drain on memory reclaim workqueue
Message-ID: <20160531211308.GE24107@localhost.localdomain>
References: <1464727815-13073-1-git-send-email-keith.busch@intel.com>
 <20160531210116.GA14868@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160531210116.GA14868@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, May 31, 2016 at 05:01:16PM -0400, Tejun Heo wrote:
> So, WQ_MEM_RECLAIM on a shared workqueue doesn't make much sense.
> That flag guarantees single concurrency level to the workqueue.  How
> would multiple users of a shared workqueue coordinate around that?
> What prevents one events_mem_unbound user from depending on, say,
> draining lru?  If lru draining requires a rescuer to guarantee forward
> progress under memory pressure, that rescuer worker must be dedicated
> for that purpose and can't be shared.

Gotchya, that fixes my understanding on the rescuer thread operation. In
this case, could we revive your previous proposal for consideration?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
