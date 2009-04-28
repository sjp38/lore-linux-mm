Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 51EE66B0047
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 14:56:52 -0400 (EDT)
Date: Tue, 28 Apr 2009 11:57:39 -0700
From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: Re: [patch] mm: close page_mkwrite races (try 3)
Message-ID: <20090428185739.GE6377@localdomain>
References: <20090414071152.GC23528@wotan.suse.de> <20090415082507.GA23674@wotan.suse.de> <20090415183847.d4fa1efb.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090415183847.d4fa1efb.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Sage Weil <sage@newdream.net>, Trond Myklebust <trond.myklebust@fys.uio.no>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 15, 2009 at 06:38:47PM -0700, Andrew Morton wrote:
>On Wed, 15 Apr 2009 10:25:07 +0200 Nick Piggin <npiggin@suse.de> wrote:
>
>> - Trond for NFS (http://bugzilla.kernel.org/show_bug.cgi?id=12913).
>
>I wonder which kernel version(s) we should put this in.
>
>Going BUG isn't nice, but that report is against 2.6.27.  Is the BUG
>super-rare, or did we avoid it via other means, or what?
>

Jumping in late in  after being bit by this bug many times
over with  2.6.27.  The bug (http://bugzilla.kernel.org/show_bug.cgi?id=12913)
is not rare with the right workload at all.
I can easily make it happen on smp machines, when multiple
processes are writing to the same NFS mounted file system.  AFAICT this
needs to be back ported to 27 stable and 29 stable as well.

Nick, are there 27 based patches already available someplace?
Obviously, I have verified these patches + Trond's patch --
http://lkml.org/lkml/2009/4/25/64 fixes the issue with 2.6.30-rc3

Thanks,
Kiran

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
