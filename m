Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A85A36B006A
	for <linux-mm@kvack.org>; Sun, 10 Oct 2010 02:50:56 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Results of my VFS scaling evaluation.
References: <1286580739.3153.57.camel@bobble.smo.corp.google.com>
Date: Sun, 10 Oct 2010 08:50:49 +0200
In-Reply-To: <1286580739.3153.57.camel@bobble.smo.corp.google.com> (Frank
	Mayhar's message of "Fri, 08 Oct 2010 16:32:19 -0700")
Message-ID: <8739seh77a.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Frank Mayhar <fmayhar@google.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, mrubin@google.com
List-ID: <linux-mm.kvack.org>

Frank Mayhar <fmayhar@google.com> writes:

> Nick Piggin has been doing work on lock contention in VFS, in particular
> to remove the dcache and inode locks, and we are very interested in this
> work.  He has entirely eliminated two of the most contended locks,
> replacing them with a combination of more granular locking, seqlocks,
> RCU lists and other mechanisms that reduce locking and contention in
> general. He has published this work at
>
> git://git.kernel.org/pub/scm/linux/kernel/git/npiggin/linux-npiggin.git
>
> As we have run into problems with lock contention, Google is very
> interested in these improvements.

Thanks Frank for the data. Yes publication of any profiles would
be interesting. We're also seeing major issues with dcache and
inode locks in local testing.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
