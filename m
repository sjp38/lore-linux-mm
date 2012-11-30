Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 8E1566B00DE
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 14:39:44 -0500 (EST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: O_DIRECT on tmpfs (again)
References: <x49ip8rf2yw.fsf@segfault.boston.devel.redhat.com>
	<alpine.LNX.2.00.1211281248270.14968@eggly.anvils>
	<50B6830A.20308@oracle.com>
	<x498v9kwhzy.fsf@segfault.boston.devel.redhat.com>
	<alpine.LNX.2.00.1211291659260.3510@eggly.anvils>
Date: Fri, 30 Nov 2012 14:39:40 -0500
In-Reply-To: <alpine.LNX.2.00.1211291659260.3510@eggly.anvils> (Hugh Dickins's
	message of "Thu, 29 Nov 2012 17:32:14 -0800 (PST)")
Message-ID: <x49ip8mq3r7.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Kleikamp <dave.kleikamp@oracle.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Richard W.M. Jones" <rjones@redhat.com>

Hugh Dickins <hughd@google.com> writes:

> I've not been entirely convinced that tmpfs needs direct_IO either;
> but your links from back then show a number of people who feel that
> direct_IO had become mainstream enough to deserve the appearance of
> support by tmpfs.

One other thing that occurs to me is that, if we fake O_DIRECT, then
io_submit will block until the I/O is complete.  It shouldn't block for
long, sure, but it will still block.  I can't say I'm happy about that,
given that many applications mix aio+dio, and will now run into some odd
behaviour when run against tmpfs.

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
