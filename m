Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3B1106B0037
	for <linux-mm@kvack.org>; Wed, 21 May 2014 15:19:15 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id ey11so1688752pad.4
        for <linux-mm@kvack.org>; Wed, 21 May 2014 12:19:14 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id io2si7468219pbc.125.2014.05.21.12.19.14
        for <linux-mm@kvack.org>;
        Wed, 21 May 2014 12:19:14 -0700 (PDT)
Date: Wed, 21 May 2014 12:19:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] ptrace: task_clear_jobctl_trapping()->wake_up_bit()
 needs mb()
Message-Id: <20140521121912.28188135b8e450cbee62fa27@linux-foundation.org>
In-Reply-To: <20140521092932.GH30445@twins.programming.kicks-ass.net>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
	<1399974350-11089-20-git-send-email-mgorman@suse.de>
	<20140513125313.GR23991@suse.de>
	<20140513141748.GD2485@laptop.programming.kicks-ass.net>
	<20140514161152.GA2615@redhat.com>
	<20140514161755.GQ30445@twins.programming.kicks-ass.net>
	<20140516135116.GA19210@redhat.com>
	<20140516135137.GB19210@redhat.com>
	<20140521092932.GH30445@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Oleg Nesterov <oleg@redhat.com>, David Howells <dhowells@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, 21 May 2014 11:29:32 +0200 Peter Zijlstra <peterz@infradead.org> wrote:

> On Fri, May 16, 2014 at 03:51:37PM +0200, Oleg Nesterov wrote:
> > __wake_up_bit() checks waitqueue_active() and thus the caller needs
> > mb() as wake_up_bit() documents, fix task_clear_jobctl_trapping().
> > 
> > Signed-off-by: Oleg Nesterov <oleg@redhat.com>
> 
> Seeing how you are one of the ptrace maintainers, how do you want this
> routed? Does Andrew pick this up, do I stuff it somewhere?

Thanks, I grabbed it.  ptrace has been pretty quiet lately.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
