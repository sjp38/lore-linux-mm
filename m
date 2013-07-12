Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 300B06B0033
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 05:28:06 -0400 (EDT)
Date: Fri, 12 Jul 2013 11:27:07 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/2] mm: add a field to store names for private anonymous
 memory
Message-ID: <20130712092707.GR25631@dyad.programming.kicks-ass.net>
References: <1373596462-27115-1-git-send-email-ccross@android.com>
 <1373596462-27115-2-git-send-email-ccross@android.com>
 <51DF9682.9040301@kernel.org>
 <20130712081348.GM25631@dyad.programming.kicks-ass.net>
 <20130712081717.GN25631@dyad.programming.kicks-ass.net>
 <20130712084406.GB4328@gmail.com>
 <20130712090046.GP25631@dyad.programming.kicks-ass.net>
 <20130712091506.GA5315@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130712091506.GA5315@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Pekka Enberg <penberg@kernel.org>, Colin Cross <ccross@android.com>, linux-kernel@vger.kernel.org, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Dave Hansen <dave.hansen@intel.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Dave Jones <davej@redhat.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Oleg Nesterov <oleg@redhat.com>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Fri, Jul 12, 2013 at 11:15:06AM +0200, Ingo Molnar wrote:
> 
> * Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > We need those files anyway.. The current proposal is that the entire VMA 
> > has a single userspace pointer in it. Or rather a 64bit value.
> 
> Yes but accessible via /proc/<PID>/mem or so?

*shudder*.. yes. But you're again opening two files. The only advantage of this
over userspace writing its own files is that the kernel cleans things up for
you.

However from what I understood android runs apps as individual users, and I
think we can do per user tmpfs mounts. So app dies, user exits, mount goes
*poof*.

> I was thinking about it in the context of its original purpose: naming 
> heap areas, which are pretty anonymous right now - /proc/*/maps is full
> of mystery ranges today.

It is.. although I've myself never had trouble with that. Most every memory
debugging that I've used/written over the past two decades was adequately able
to identify memory regions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
