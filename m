Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6113F6B0082
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 10:56:06 -0400 (EDT)
Subject: Re: [PATCH 04/23] vfs: Introduce infrastructure for revoking a file
References: <m1oct739xu.fsf@fess.ebiederm.org>
	<1243893048-17031-4-git-send-email-ebiederm@xmission.com>
	<20090602071411.GE31556@wotan.suse.de>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 02 Jun 2009 15:56:02 -0700
In-Reply-To: <20090602071411.GE31556@wotan.suse.de> (Nick Piggin's message of "Tue\, 2 Jun 2009 09\:14\:11 +0200")
Message-ID: <m1tz2ykzy5.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin <npiggin@suse.de> writes:

>> In addition for a complete solution we need:
>> - A reliable way the file structures that we need to revoke.
>> - To wait for but not tamper with ongoing file creation and cleanup.
>> - A guarantee that all with user space controlled duration are removed.
>> 
>> The file_hotplug_lock has a very unique implementation necessitated by
>> the need to have no performance impact on existing code.  Classic locking
>
> Well, it isn't no performance impact. Function calls, branches, icache
> and dcache...

Practically none.

Everything I could measure was in the noise.  It is cheaper than any serializing
locking primitive.  I ran both lmbench and did some microbenchmark testing.
So I know on the fast path the overhead is minimal.  Certainly less than  what
we are doing in sysfs and proc today.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
