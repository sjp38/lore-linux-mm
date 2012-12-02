Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 505FC6B005A
	for <linux-mm@kvack.org>; Sun,  2 Dec 2012 10:10:54 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so1026376eaa.14
        for <linux-mm@kvack.org>; Sun, 02 Dec 2012 07:10:52 -0800 (PST)
Date: Sun, 2 Dec 2012 16:10:48 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 1/2] mm/rmap: Convert the struct anon_vma::mutex to an
 rwsem
Message-ID: <20121202151048.GA12911@gmail.com>
References: <1354305521-11583-1-git-send-email-mingo@kernel.org>
 <CA+55aFwjxm7OYuucHeE2WFr4p+jwr63t=kSdHndta_QkyFbyBQ@mail.gmail.com>
 <20121201094927.GA12366@gmail.com>
 <20121201122649.GA20322@gmail.com>
 <CA+55aFx8QtP0hg8qxn__4vHQuzH7QkhTN-4fwgOpM-A=KuBBjA@mail.gmail.com>
 <20121201184135.GA32449@gmail.com>
 <CA+55aFyq7OaUxcEHXvJhp0T57KN14o-RGxqPmA+ks8ge6zJh5w@mail.gmail.com>
 <20121201201030.GA2704@gmail.com>
 <50BA6649.7050103@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50BA6649.7050103@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>


* Rik van Riel <riel@redhat.com> wrote:

> On 12/01/2012 03:10 PM, Ingo Molnar wrote:
> >
> >Convert the struct anon_vma::mutex to an rwsem, which will help
> >in solving a page-migration scalability problem. (Addressed in
> >a separate patch.)
> >
> >The conversion is simple and straightforward: in every case
> >where we mutex_lock()ed we'll now down_write().
> >
> >Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
> >Cc: Andrew Morton <akpm@linux-foundation.org>
> >Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
> >Cc: Andrea Arcangeli <aarcange@redhat.com>
> >Cc: Rik van Riel <riel@redhat.com>
> >Cc: Mel Gorman <mgorman@suse.de>
> >Cc: Hugh Dickins <hughd@google.com>
> >Signed-off-by: Ingo Molnar <mingo@kernel.org>
> 
> Reviewed-by: Rik van Riel <riel@redhat.com>

Thanks Rik!

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
