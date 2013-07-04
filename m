Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 26D2A6B0034
	for <linux-mm@kvack.org>; Thu,  4 Jul 2013 04:57:17 -0400 (EDT)
Date: Thu, 4 Jul 2013 10:56:04 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm: add sys_madvise2 and MADV_NAME to name vmas
Message-ID: <20130704085604.GI18898@dyad.programming.kicks-ass.net>
References: <1372901537-31033-1-git-send-email-ccross@android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1372901537-31033-1-git-send-email-ccross@android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Cross <ccross@android.com>
Cc: linux-kernel@vger.kernel.org, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, Rob Landley <rob@landley.net>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Rusty Russell <rusty@rustcorp.com.au>, "Eric W. Biederman" <ebiederm@xmission.com>, Oleg Nesterov <oleg@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Anton Vorontsov <anton.vorontsov@linaro.org>, Pekka Enberg <penberg@kernel.org>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, "open list:GENERIC INCLUDE/A..." <linux-arch@vger.kernel.org>

On Wed, Jul 03, 2013 at 06:31:56PM -0700, Colin Cross wrote:
> Userspace processes often have multiple allocators that each do
> anonymous mmaps to get memory.  When examining memory usage of
> individual processes or systems as a whole, it is useful to be
> able to break down the various heaps that were allocated by
> each layer and examine their size, RSS, and physical memory
> usage.

So why not 'abuse' deleted files?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
