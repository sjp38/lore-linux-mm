Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 6B8E66B0062
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 13:31:10 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so1259389pbb.14
        for <linux-mm@kvack.org>; Wed, 31 Oct 2012 10:31:09 -0700 (PDT)
Date: Wed, 31 Oct 2012 10:31:05 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 00/31] numa/core patches
In-Reply-To: <50912478.2040403@redhat.com>
Message-ID: <alpine.LNX.2.00.1210311005220.5685@eggly.anvils>
References: <20121025121617.617683848@chello.nl> <508A52E1.8020203@redhat.com> <1351242480.12171.48.camel@twins> <20121028175615.GC29827@cmpxchg.org> <508F73C5.7050409@redhat.com> <20121031004838.GA1657@cmpxchg.org> <alpine.LNX.2.00.1210302350140.5084@eggly.anvils>
 <50912478.2040403@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhouping Liu <zliu@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, CAI Qian <caiqian@redhat.com>

On Wed, 31 Oct 2012, Zhouping Liu wrote:
> On 10/31/2012 03:26 PM, Hugh Dickins wrote:
> > 
> > There's quite a few put_page()s in do_huge_pmd_numa_page(), and it
> > would help if we could focus on the one which is giving the trouble,
> > but I don't know which that is.  Zhouping, if you can, please would
> > you do an "objdump -ld vmlinux >bigfile" of your kernel, then extract
> > from bigfile just the lines from "<do_huge_pmd_numa_page>:" to whatever
> > is the next function, and post or mail privately just that disassembly.
> > That should be good to identify which of the put_page()s is involved.
> 
> Hugh, I didn't find the next function, as I can't find any words that matched
> "do_huge_pmd_numa_page".
> is there any other methods?

Hmm, do_huge_pmd_numa_page does appear in your stacktrace,
unless I've made a typo but am blind to it.

Were you applying objdump to the vmlinux which gave you the
BUG at mm/memcontrol.c:1134! ?

Maybe just do "objdump -ld mm/huge_memory.o >notsobigfile"
and mail me an attachment of the notsobigfile.

I did try building your config here last night, but ran out of disk
space on this partition, and it was already clear that my gcc version
differs from yours, so not quite matching.

> also I tried to use kdump to dump vmcore file,
> but unluckily kdump didn't
> work well, if you think it useful to dump vmcore file, I can try it again and
> provide more info.

It would take me awhile to get up to speed on using that,
I'd prefer to start with just the objdump of huge_memory.o.

I forgot last night to say that I did try stress (but not on a kernel
of your config), but didn't see the BUG: I expect there are too many
differences in our environments, and I'd have to tweak things one way
or another to get it to happen - probably a waste of time.

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
