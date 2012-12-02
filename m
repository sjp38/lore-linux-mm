Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 9EEAD6B0062
	for <linux-mm@kvack.org>; Sun,  2 Dec 2012 10:12:38 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so1026875eaa.14
        for <linux-mm@kvack.org>; Sun, 02 Dec 2012 07:12:37 -0800 (PST)
Date: Sun, 2 Dec 2012 16:12:32 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 2/2, v2] mm/migration: Make rmap_walk_anon() and
 try_to_unmap_anon() more scalable
Message-ID: <20121202151232.GB12911@gmail.com>
References: <1354305521-11583-1-git-send-email-mingo@kernel.org>
 <CA+55aFwjxm7OYuucHeE2WFr4p+jwr63t=kSdHndta_QkyFbyBQ@mail.gmail.com>
 <20121201094927.GA12366@gmail.com>
 <20121201122649.GA20322@gmail.com>
 <CA+55aFx8QtP0hg8qxn__4vHQuzH7QkhTN-4fwgOpM-A=KuBBjA@mail.gmail.com>
 <20121201184135.GA32449@gmail.com>
 <CA+55aFyq7OaUxcEHXvJhp0T57KN14o-RGxqPmA+ks8ge6zJh5w@mail.gmail.com>
 <20121201201538.GB2704@gmail.com>
 <50BA69B7.30002@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50BA69B7.30002@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>


* Rik van Riel <riel@redhat.com> wrote:

> >+static inline void anon_vma_lock_read(struct anon_vma *anon_vma)
> >+{
> >+	down_read(&anon_vma->root->rwsem);
> >+}
> 
> I see you did not rename anon_vma_lock and anon_vma_unlock to 
> anon_vma_lock_write and anon_vma_unlock_write.
> 
> That could get confusing to people touching that code in the 
> future.

Agreed, doing that rename makes perfect sense - I've done that 
in the v2 version attached below.

Thanks,

	Ingo

----------------------->
