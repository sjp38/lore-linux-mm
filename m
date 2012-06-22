Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 9EC276B012B
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 20:47:14 -0400 (EDT)
Received: by wibhr4 with SMTP id hr4so92192wib.8
        for <linux-mm@kvack.org>; Thu, 21 Jun 2012 17:47:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120621164606.4ae1a71d.akpm@linux-foundation.org>
References: <alpine.DEB.2.00.1206201758500.3068@chino.kir.corp.google.com> <20120621164606.4ae1a71d.akpm@linux-foundation.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 21 Jun 2012 17:46:52 -0700
Message-ID: <CA+55aFzPXMD3N3Oy-om6utDCQYmrBDnDgdqpVC5cgKe-v6uZ3w@mail.gmail.com>
Subject: Re: [patch 3.5-rc3] mm, mempolicy: fix mbind() to do synchronous migration
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@elte.hu>

On Thu, Jun 21, 2012 at 4:46 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> I can't really do anything with this patch - it's a bug added by
> Peter's "mm/mpol: Simplify do_mbind()" and added to linux-next via one
> of Ingo's trees.
>
> And I can't cleanly take the patch over as it's all bound up with the
> other changes for sched/numa balancing.

I took the patch, it looked obviously correct (passing in a boolean
was clearly crap).

I wonder if I should make sparse warn about any casts to/from enums.
They tend to always be wrong.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
