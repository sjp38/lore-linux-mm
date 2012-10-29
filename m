Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 6258D6B005A
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 10:50:05 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id u3so3090886wey.14
        for <linux-mm@kvack.org>; Mon, 29 Oct 2012 07:50:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121029124229.GC11733@Krystal>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com>
 <1351450948-15618-9-git-send-email-levinsasha928@gmail.com> <20121029124229.GC11733@Krystal>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 29 Oct 2012 07:49:42 -0700
Message-ID: <CA+55aFzO8DJJP3HBfgqXFac9r3=bYK+_nYe4cuXiNFg-623s6w@mail.gmail.com>
Subject: Re: [PATCH v7 09/16] SUNRPC/cache: use new hashtable implementation
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Sasha Levin <levinsasha928@gmail.com>, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

On Mon, Oct 29, 2012 at 5:42 AM, Mathieu Desnoyers
<mathieu.desnoyers@efficios.com> wrote:
>
> So defining e.g.:
>
> #include <linux/log2.h>
>
> #define DFR_HASH_BITS  (PAGE_SHIFT - ilog2(BITS_PER_LONG))
>
> would keep the intended behavior in all cases: use one page for the hash
> array.

Well, since that wasn't true before either because of the long-time
bug you point out, clearly the page size isn't all that important. I
think it's more important to have small and simple code, and "9" is
certainly that, compared to playing ilog2 games with not-so-obvious
things.

Because there's no reason to believe that '9' is in any way a worse
random number than something page-shift-related, is there? And getting
away from *previous* overly-complicated size calculations that had
been broken because they were too complicated and random, sounds like
a good idea.

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
