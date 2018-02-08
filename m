Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7BBB86B0003
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 09:49:34 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id c62so2282565pfk.21
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 06:49:34 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 32-v6si68362pld.447.2018.02.08.06.49.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Feb 2018 06:49:33 -0800 (PST)
Date: Thu, 8 Feb 2018 06:49:18 -0800
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: INFO: task hung in sync_blockdev
Message-ID: <20180208144918.GF10945@tassilo.jf.intel.com>
References: <001a11447070ac6fcb0564a08cb1@google.com>
 <20180207155229.GC10945@tassilo.jf.intel.com>
 <20180208092839.ebe5rk6mtvkk5da4@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180208092839.ebe5rk6mtvkk5da4@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: syzbot <syzbot+283c3c447181741aea28@syzkaller.appspotmail.com>, akpm@linux-foundation.org, aryabinin@virtuozzo.com, jlayton@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@techsingularity.net, mingo@kernel.org, rgoldwyn@suse.com, syzkaller-bugs@googlegroups.com, linux-fsdevel@vger.kernel.org

> > It seems multiple processes deadlocked on the bd_mutex. 
> > Unfortunately there's no backtrace for the lock acquisitions,
> > so it's hard to see the exact sequence.
> 
> Well, all in the report points to a situation where some IO was submitted
> to the block device and never completed (more exactly it took longer than
> those 120s to complete that IO). It would need more digging into the

Are you sure? I didn't think outstanding IO would take bd_mutex.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
