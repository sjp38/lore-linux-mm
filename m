Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 88A0E6B003D
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 09:51:05 -0400 (EDT)
Subject: Re: ftruncate-mmap: pages are lost after writing to mmaped file.
From: Chris Mason <chris.mason@oracle.com>
In-Reply-To: <20090324132637.GA14607@duck.suse.cz>
References: <604427e00903181244w360c5519k9179d5c3e5cd6ab3@mail.gmail.com>
	 <200903200248.22623.nickpiggin@yahoo.com.au>
	 <20090319164638.GB3899@duck.suse.cz>
	 <200903241844.22851.nickpiggin@yahoo.com.au>
	 <20090324123935.GD23439@duck.suse.cz> <20090324125510.GA9434@duck.suse.cz>
	 <20090324132637.GA14607@duck.suse.cz>
Content-Type: text/plain
Date: Tue, 24 Mar 2009 10:01:45 -0400
Message-Id: <1237903305.17910.4.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, "Martin J. Bligh" <mbligh@mbligh.org>, linux-ext4@vger.kernel.org, Ying Han <yinghan@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, guichaz@gmail.com, Alex Khesin <alexk@google.com>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-03-24 at 14:26 +0100, Jan Kara wrote:
> On Tue 24-03-09 13:55:10, Jan Kara wrote:

> >   And one more interesting thing I don't yet fully understand - I see pages
> > having PageError() set when they are removed from page cache (and they have
> > been faulted in before). It's probably some interaction with pagecache
> > readahead...
>   Argh... So the problem seems to be that get_block() occasionally returns
> ENOSPC and we then discard the dirty data (hmm, we could give at least a
> warning for that). I'm not yet sure why getblock behaves like this because
> the filesystem seems to have enough space but anyway this seems to be some
> strange fs trouble as well.
> 

Ouch.  Perhaps the free space is waiting on a journal commit?

-chris


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
