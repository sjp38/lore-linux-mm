Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id DBEF96B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 05:05:12 -0400 (EDT)
Received: by mail-ee0-f46.google.com with SMTP id t10so2388954eei.19
        for <linux-mm@kvack.org>; Thu, 22 May 2014 02:05:12 -0700 (PDT)
Received: from mail-ee0-x229.google.com (mail-ee0-x229.google.com [2a00:1450:4013:c00::229])
        by mx.google.com with ESMTPS id l6si13981330eef.61.2014.05.22.02.05.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 22 May 2014 02:05:11 -0700 (PDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so2409701eei.28
        for <linux-mm@kvack.org>; Thu, 22 May 2014 02:05:10 -0700 (PDT)
Date: Thu, 22 May 2014 11:05:02 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] SCHED: remove proliferation of wait_on_bit action
 functions.
Message-ID: <20140522090502.GB30094@gmail.com>
References: <20140501123738.3e64b2d2@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140501123738.3e64b2d2@notabene.brown>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>, Oleg Nesterov <oleg@redhat.com>, David Howells <dhowells@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, dm-devel@redhat.com, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, Steve French <sfrench@samba.org>, Theodore Ts'o <tytso@mit.edu>, Trond Myklebust <trond.myklebust@primarydata.com>, Ingo Molnar <mingo@redhat.com>, Roland McGrath <roland@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


* NeilBrown <neilb@suse.de> wrote:

> [[ get_maintainer.pl suggested 61 email address for this patch.
>    I've trimmed that list somewhat.  Hope I didn't miss anyone
>    important...
>    I'm hoping it will go in through the scheduler tree, but would
>    particularly like an Acked-by for the fscache parts.  Other acks
>    welcome.
> ]]
> 
> The current "wait_on_bit" interface requires an 'action' function
> to be provided which does the actual waiting.
> There are over 20 such functions, many of them identical.
> Most cases can be satisfied by one of just two functions, one
> which uses io_schedule() and one which just uses schedule().
> 
> So:
>  Rename wait_on_bit and        wait_on_bit_lock to
>         wait_on_bit_action and wait_on_bit_lock_action
>  to make it explicit that they need an action function.
> 
>  Introduce new wait_on_bit{,_lock} and wait_on_bit{,_lock}_io
>  which are *not* given an action function but implicitly use
>  a standard one.
>  The decision to error-out if a signal is pending is now made
>  based on the 'mode' argument rather than being encoded in the action
>  function.

this patch fails to build on x86-32 allyesconfigs.

Could we keep the old names for a while, and remove them in the next 
cycle or so?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
