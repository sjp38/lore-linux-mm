Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 171B46B0071
	for <linux-mm@kvack.org>; Sun, 10 Oct 2010 02:54:56 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Results of my VFS scaling evaluation.
References: <1286580739.3153.57.camel@bobble.smo.corp.google.com>
	<20101009031609.GK4681@dastard>
Date: Sun, 10 Oct 2010 08:54:51 +0200
In-Reply-To: <20101009031609.GK4681@dastard> (Dave Chinner's message of "Sat,
	9 Oct 2010 14:16:09 +1100")
Message-ID: <87y6a6fsg4.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Frank Mayhar <fmayhar@google.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, mrubin@google.com, torvalds@linux-foundation.org, viro@zeniv.linux.org.uk
List-ID: <linux-mm.kvack.org>

Dave Chinner <david@fromorbit.com> writes:

> On Fri, Oct 08, 2010 at 04:32:19PM -0700, Frank Mayhar wrote:
>> Nick Piggin has been doing work on lock contention in VFS, in particular
>> to remove the dcache and inode locks, and we are very interested in this
>> work.  He has entirely eliminated two of the most contended locks,
>> replacing them with a combination of more granular locking, seqlocks,
>> RCU lists and other mechanisms that reduce locking and contention in
>> general. He has published this work at
>> 
>> git://git.kernel.org/pub/scm/linux/kernel/git/npiggin/linux-npiggin.git

...

>
> While the code in that tree might be stable, it's not really in any
> shape acceptible for mainline inclusion.
>
> I've been reworking the inode_lock breakup code from this patch set,
> and there is significant change in the locking order and structure
> compared to the above tree to avoid the unmaintainable mess of
> trylock operations that Nick's patchset ended up with.

...
>
> FWIW, it would be good if this sort of testing could be run on the tree
> under review here:
>
> git://git.kernel.org/pub/scm/linux/kernel/git/dgc/xfsdev.git inode-scale
>
> This is what I'm trying to get reviewed in time for a .37 merge.  If
> that gets in .37, then I'll probably follow the same process for the
> dcache_lock in .38, and after that we can then consider all the RCU
> changes for both the inode and dentry operations.

That would be over 6 months just to make even a little progress.
 
Sorry, I am not convinced yet that any progress in this area has to be
that glacial. Linus indicated last time he wanted to move faster on the
VFS improvements. And the locking as it stands today is certainly a
major problem.

Maybe it's possible to come up with a way to integrate this faster?


-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
