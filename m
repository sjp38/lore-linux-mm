Date: Thu, 3 Jul 2008 16:01:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2.6.26-rc8-mm1] memrlimit: fix mmap_sem deadlock
Message-Id: <20080703160117.b3781463.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0807032143110.10641@blonde.site>
References: <Pine.LNX.4.64.0807032143110.10641@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: balbir@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jul 2008 21:50:31 +0100 (BST)
Hugh Dickins <hugh@veritas.com> wrote:

> "ps -f" hung after "killall make" of make -j20 kernel builds.  It's
> generally considered bad manners to down_write something you already
> have down_read.  exit_mm up_reads before calling mm_update_next_owner,
> so I guess exec_mmap can safely do so too.  (And with that repositioning
> there's not much point in mm_need_new_owner allowing for NULL mm.)
> 

thanks

> ---
> Fix to memrlimit-cgroup-mm-owner-callback-changes-to-add-task-info.patch
> quite independent of its recent sleeping-inside-spinlock fix; could even
> be applied to 2.6.26, though no deadlock there.  Gosh, I see those patches
> have spawned "Reviewed-by" tags in my name: sorry, no, just "Bug-found-by".

I switched
memrlimit-add-memrlimit-controller-accounting-and-control-memrlimit-improve-fork-and-error-handling.patch
and
memrlimit-cgroup-mm-owner-callback-changes-to-add-task-info-memrlimit-fix-sleep-inside-sleeplock-in-mm_update_next_owner.patch
to Cc:you.

There doesn't seem to have been much discussion regarding your recent
objections to the memrlimit patches.  But it caused me to put a big
black mark on them.  Perhaps sending it all again would be helpful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
