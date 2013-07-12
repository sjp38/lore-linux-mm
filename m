Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 4581C6B0032
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 04:21:56 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id kx10so8746152pab.13
        for <linux-mm@kvack.org>; Fri, 12 Jul 2013 01:21:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130712081348.GM25631@dyad.programming.kicks-ass.net>
References: <1373596462-27115-1-git-send-email-ccross@android.com>
	<1373596462-27115-2-git-send-email-ccross@android.com>
	<51DF9682.9040301@kernel.org>
	<20130712081348.GM25631@dyad.programming.kicks-ass.net>
Date: Fri, 12 Jul 2013 11:21:55 +0300
Message-ID: <CAOJsxLHEGBdFtnmhDv2AekUhXB00To5JBjsw0t8eFzJPr8eLZQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: add a field to store names for private anonymous memory
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Colin Cross <ccross@android.com>, LKML <linux-kernel@vger.kernel.org>, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Dave Hansen <dave.hansen@intel.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Dave Jones <davej@redhat.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Oleg Nesterov <oleg@redhat.com>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@kernel.org>, "list@ebiederm.org:DOCUMENTATION <linux-doc@vger.kernel.org>, list@ebiederm.org:MEMORY MANAGEMENT <linux-mm@kvack.org>," <linux-doc@vger.kernel.org>"linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Jul 12, 2013 at 11:13 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> I also don't see it helping with the JIT stuff; you still need to write out a
> file with symbol information, we still need to find the file. A less hacky
> solution for the entire JIT thing is you writing a proper ELF-DSO and
> mmap()'ing that :-)
>
> Storing a JIT specific userspace pointer in the VMA doesn't help with any of
> that.

I'm thinking about corner cases like 'perf top' here. I don't see how we can
write out a ELF-DSO because the JIT compiler can generate new symbols
at any given time.

That's what made me think it'd be best for the _kernel_ to know about the
symbols so that perf could take advantage of that as well.

                                    Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
