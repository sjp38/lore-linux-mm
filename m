Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id D4EDE6B0034
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 04:55:21 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so8326302pdj.8
        for <linux-mm@kvack.org>; Fri, 12 Jul 2013 01:55:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130712084406.GB4328@gmail.com>
References: <1373596462-27115-1-git-send-email-ccross@android.com>
	<1373596462-27115-2-git-send-email-ccross@android.com>
	<51DF9682.9040301@kernel.org>
	<20130712081348.GM25631@dyad.programming.kicks-ass.net>
	<20130712081717.GN25631@dyad.programming.kicks-ass.net>
	<20130712084406.GB4328@gmail.com>
Date: Fri, 12 Jul 2013 11:55:20 +0300
Message-ID: <CAOJsxLEtUGZJR7JLVGu_XctZ60m4X8jRmaaAJ2Dg7c19LyqdUg@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: add a field to store names for private anonymous memory
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Colin Cross <ccross@android.com>, LKML <linux-kernel@vger.kernel.org>, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Dave Hansen <dave.hansen@intel.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Dave Jones <davej@redhat.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Oleg Nesterov <oleg@redhat.com>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, "list@ebiederm.org:DOCUMENTATION <linux-doc@vger.kernel.org>, list@ebiederm.org:MEMORY MANAGEMENT <linux-mm@kvack.org>," <linux-doc@vger.kernel.org>"linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Fri, Jul 12, 2013 at 11:44 AM, Ingo Molnar <mingo@kernel.org> wrote:
> I guess the real question is not whether it's useful, I think it clearly
> is. The question should be: are there real downsides? Does the addition to
> the anon mmap field blow up the size of vma_struct by a pointer, or is
> there still space?

No, it's part of an union of 'struct vma_struct' in the current implementation
so the size doesn't change.

I'd still like to see something that's not restricted to page aligned memory
areas, though.

                                Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
