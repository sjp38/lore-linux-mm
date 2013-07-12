Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 4BB616B0034
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 05:04:53 -0400 (EDT)
Received: by mail-la0-f52.google.com with SMTP id fo12so7567891lab.39
        for <linux-mm@kvack.org>; Fri, 12 Jul 2013 02:04:51 -0700 (PDT)
Message-ID: <51DFC6AE.3020504@kernel.org>
Date: Fri, 12 Jul 2013 12:04:46 +0300
From: Pekka Enberg <penberg@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm: add a field to store names for private anonymous
 memory
References: <1373596462-27115-1-git-send-email-ccross@android.com> <1373596462-27115-2-git-send-email-ccross@android.com> <51DF9682.9040301@kernel.org> <20130712081348.GM25631@dyad.programming.kicks-ass.net> <CAOJsxLHEGBdFtnmhDv2AekUhXB00To5JBjsw0t8eFzJPr8eLZQ@mail.gmail.com> <20130712085504.GO25631@dyad.programming.kicks-ass.net>
In-Reply-To: <20130712085504.GO25631@dyad.programming.kicks-ass.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Colin Cross <ccross@android.com>, LKML <linux-kernel@vger.kernel.org>, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Dave Hansen <dave.hansen@intel.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Dave Jones <davej@redhat.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Oleg Nesterov <oleg@redhat.com>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@kernel.org>, "list@ebiederm.org:DOCUMENTATION" <linux-doc@vger.kernel.org>, "list@ebiederm.org:MEMORY MANAGEMENT" <linux-mm@kvack.org>linux-doc@vger.kernel.org"linux-mm@kvack.org" <linux-mm@kvack.org>

On 07/12/2013 11:55 AM, Peter Zijlstra wrote:
> Mmap the file PROT_READ|PROT_WRITE|PROT_EXEC, map the _entire_ file, not just
> the text section; make the symbol table larger than you expect. Then write the
> symbol name after you've jit'ed the text but before you use it.
>
> IIRC you once told me you never overwrite text but always append new symbols.
> So you can basically fill the DSO with text/symbols use mmap memory writes.

I don't but I think Hotspot, for example, does recompile method. Dunno
if it's a problem really, we could easily come up with a versioning
scheme for the methods and teach perf to treat the different memory
regions as the same method.

On 07/12/2013 11:55 AM, Peter Zijlstra wrote:
> Once the DSO is full -- equal to your previous anon-exec region being full,
> you simply mmap a new DSO.
>
> Wouldn't that work?

Okay and then whenever 'perf top' sees a non-mapped IP it reloads the
DSO (if it has changed)?

Yeah, I could see that working. It doesn't solve the problems Ingo 
mentioned which are also important, though.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
