Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 2562A6B0033
	for <linux-mm@kvack.org>; Mon,  8 Jul 2013 14:10:18 -0400 (EDT)
Date: Mon, 8 Jul 2013 20:04:24 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 0/1] mm: mempolicy: (Was: add sys_madvise2 and MADV_NAME to
	name vmas)
Message-ID: <20130708180424.GA6490@redhat.com>
References: <1372901537-31033-1-git-send-email-ccross@android.com> <20130704202232.GA19287@redhat.com> <CAMbhsRRjGjo_-zSigmdsDvY-kfBhmP49bDQzsgHfj5N-y+ZAdw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMbhsRRjGjo_-zSigmdsDvY-kfBhmP49bDQzsgHfj5N-y+ZAdw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Cross <ccross@android.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Hampson, Steven T" <steven.t.hampson@intel.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, Rob Landley <rob@landley.net>, Arnd Bergmann <arnd@arndb.de>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rusty Russell <rusty@rustcorp.com.au>, "Eric W. Biederman" <ebiederm@xmission.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Anton Vorontsov <anton.vorontsov@linaro.org>, Pekka Enberg <penberg@kernel.org>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, "open list:GENERIC INCLUDE/A..." <linux-arch@vger.kernel.org>

On 07/05, Colin Cross wrote:
>
> On Thu, Jul 4, 2013 at 1:22 PM, Oleg Nesterov <oleg@redhat.com> wrote:
> >
> >         MADV_NAME(START, PAGE_SIZE, "MY_NAME");
> >         MADV_NAME(START + PAGE_SIZE, PAGE_SIZE, "MY_NAME");
> >
> > The 1st MADV_NAME will split this vma, the 2nd won't merge. Not that I think
> > this is buggy, just a bit inconsistent imho.
>
> My intention is that any vmas that would be merged without names would
> be merged if they have the same name.  I copied the logic used for
> vm_flags, but I'll take another look.

Please ignore. Sorry I was wrong, I misread this code.

And when I read it now I strongly believe that vma_policy() logic is
buggy.

The patch cc's stable but I do not understand mempolicy.c and I have
no idea how to test it. So this needs the authoritative acks.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
