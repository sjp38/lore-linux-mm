Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id A59576B0032
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 05:28:56 -0400 (EDT)
Received: by mail-ea0-f172.google.com with SMTP id q10so6314249eaj.3
        for <linux-mm@kvack.org>; Fri, 12 Jul 2013 02:28:55 -0700 (PDT)
Date: Fri, 12 Jul 2013 11:28:51 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 2/2] mm: add a field to store names for private anonymous
 memory
Message-ID: <20130712092851.GC5315@gmail.com>
References: <1373596462-27115-1-git-send-email-ccross@android.com>
 <1373596462-27115-2-git-send-email-ccross@android.com>
 <51DF9682.9040301@kernel.org>
 <20130712081348.GM25631@dyad.programming.kicks-ass.net>
 <CAOJsxLHEGBdFtnmhDv2AekUhXB00To5JBjsw0t8eFzJPr8eLZQ@mail.gmail.com>
 <20130712085504.GO25631@dyad.programming.kicks-ass.net>
 <51DFC6AE.3020504@kernel.org>
 <20130712091445.GQ25631@dyad.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130712091445.GQ25631@dyad.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Pekka Enberg <penberg@kernel.org>, Colin Cross <ccross@android.com>, LKML <linux-kernel@vger.kernel.org>, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Dave Hansen <dave.hansen@intel.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Dave Jones <davej@redhat.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Oleg Nesterov <oleg@redhat.com>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, "list@ebiederm.org:DOCUMENTATION" <linux-doc@vger.kernel.org>, "list@ebiederm.org:MEMORY MANAGEMENT" <linux-mm@kvack.org>


* Peter Zijlstra <peterz@infradead.org> wrote:

> > Yeah, I could see that working. It doesn't solve the problems Ingo 
> > mentioned which are also important, though.
> 
> Nothing I've yet seen would do that. Its intrinsic to the fact that we 
> want 'anonymous' text tied to a process instance but require part of 
> that text (symbol information at the very least) to be available after 
> the process instance.
> 
> That are two contradictory requirements. You cannot preserve and not 
> preserve at the same time.
> 
> And pushing the symbol info into the kernel isn't going to fix that 
> either.

I fully agree with you in the JIT case.

I was arguing the utilty of the original, somewhat limited usecase: 
minimally naming allocator areas/heaps, on a high level.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
