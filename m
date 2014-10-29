Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 66C2190008B
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 12:42:15 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id ex7so2240873wid.2
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 09:42:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m10si19176207wiz.21.2014.10.29.09.42.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Oct 2014 09:42:13 -0700 (PDT)
Date: Wed, 29 Oct 2014 17:41:36 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/4] mm: gup: add get_user_pages_locked and
 get_user_pages_unlocked
Message-ID: <20141029164136.GJ19606@redhat.com>
References: <1412153797-6667-1-git-send-email-aarcange@redhat.com>
 <1412153797-6667-3-git-send-email-aarcange@redhat.com>
 <20141009104723.GL4750@worktop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141009104723.GL4750@worktop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andres Lagar-Cavilla <andreslc@google.com>, Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>

On Thu, Oct 09, 2014 at 12:47:23PM +0200, Peter Zijlstra wrote:
> On Wed, Oct 01, 2014 at 10:56:35AM +0200, Andrea Arcangeli wrote:
> > +static inline long __get_user_pages_locked(struct task_struct *tsk,
> > +					   struct mm_struct *mm,
> > +					   unsigned long start,
> > +					   unsigned long nr_pages,
> > +					   int write, int force,
> > +					   struct page **pages,
> > +					   struct vm_area_struct **vmas,
> > +					   int *locked,
> > +					   bool notify_drop)
> 
> You might want to consider __always_inline to make sure it does indeed
> get inlined and constant propagation works for @locked and @notify_drop.

Ok, that's included in the last patchset submit.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
