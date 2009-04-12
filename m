Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id EDC4C5F0001
	for <linux-mm@kvack.org>; Sun, 12 Apr 2009 16:21:22 -0400 (EDT)
References: <m1skkf761y.fsf@fess.ebiederm.org>
	<20090411155852.GV26366@ZenIV.linux.org.uk>
	<m1k55ryw2n.fsf@fess.ebiederm.org>
	<20090411165651.GW26366@ZenIV.linux.org.uk>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sun, 12 Apr 2009 13:21:35 -0700
In-Reply-To: <20090411165651.GW26366@ZenIV.linux.org.uk> (Al Viro's message of "Sat\, 11 Apr 2009 17\:56\:51 +0100")
Message-ID: <m1tz4tmxm8.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: Re: [RFC][PATCH 0/9] File descriptor hot-unplug support
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

Al Viro <viro@ZenIV.linux.org.uk> writes:

> On Sat, Apr 11, 2009 at 09:49:36AM -0700, Eric W. Biederman wrote:
>
>> The fact that in the common case only one task ever accesses a struct
>> file leaves a lot of room for optimization.
>
> I'm not at all sure that it's a good assumption; even leaving aside e.g.
> several tasks sharing stdout/stderr, a bunch of datagrams coming out of
> several threads over the same socket is quite possible.

I have thought about this a little more and a solution to ensure this is
not a problem for code that has not opted in to this new functionality is
simple.  Require uses that need it to set FMODE_REVOKE.

It is no extra code and it keeps the absolute worst case behavior for
existing code down an additional branch mispredict.

It is worth doing anyway because it cleans up the abstraction and makes
it clear where revoke is supported.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
