Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id D92846B0033
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 16:13:25 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id c30so4549346ioj.19
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 13:13:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n8sor145962itn.147.2017.12.18.13.13.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Dec 2017 13:13:24 -0800 (PST)
From: Junaid Shahid <junaids@google.com>
Subject: Re: [PATCH -V3 -mm] mm, swap: Fix race between swapoff and some swap operations
Date: Mon, 18 Dec 2017 13:13:21 -0800
Message-ID: <3897758.H188Yq1CBR@js-desktop.svl.corp.google.com>
In-Reply-To: <877etkwki2.fsf@yhuang-dev.intel.com>
References: <20171218073424.29647-1-ying.huang@intel.com> <877etkwki2.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@fb.com>, Mel Gorman <mgorman@techsingularity.net>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>

On Monday, December 18, 2017 3:41:41 PM PST Huang, Ying wrote:
> 
> A version implemented via stop_machine() could be gotten via a small
> patch as below.  If you still prefer stop_machine(), I can resend a
> version implemented with stop_machine().
> 

For the stop_machine() version, would it work to just put preempt_disable/enable at the start and end of lock_cluster() rather than introducing get/put_swap_device? Something like that might be simpler and would also disable preemption for less duration.

Thanks,
Junaid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
