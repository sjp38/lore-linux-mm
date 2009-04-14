Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 50C0E5F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 03:44:59 -0400 (EDT)
Message-ID: <49E43F1D.3070400@kernel.org>
Date: Tue, 14 Apr 2009 16:45:33 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/9] File descriptor hot-unplug support
References: <m1skkf761y.fsf@fess.ebiederm.org> <49E4000E.10308@kernel.org> <m13acbbs5u.fsf@fess.ebiederm.org>
In-Reply-To: <m13acbbs5u.fsf@fess.ebiederm.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>, Hugh Dickins <hugh@veritas.com>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

Eric W. Biederman wrote:
> Do you know of a case where we actually have multiple tasks accessing
> a file simultaneously?

I don't have anything at hand but multithread/process server accepting
on the same socket comes to mind.  I don't think it would be a very
rare thing.  If you confine the scope to character devices or sysfs,
it could be quite rare tho.

> I just instrumented up my patch an so far the only case I have found
> are multiple processes closing the same file.  Some weird part of
> bash forking extra processes.

Hmmm...

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
