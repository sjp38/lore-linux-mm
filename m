Date: Mon, 2 Oct 2000 21:25:21 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] fix for VM test9-pre,
Message-ID: <20001002212521.A21473@athlon.random>
References: <OF28EE4EE0.DBB104BA-ON8825696C.005977FC@LocalDomain> <Pine.LNX.4.21.0010021400420.22539-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0010021400420.22539-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Mon, Oct 02, 2000 at 02:07:51PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Ying Chen/Almaden/IBM <ying@almaden.ibm.com>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 02, 2000 at 02:07:51PM -0300, Rik van Riel wrote:
> However, I have no idea why your buffers and pagecache pages
> aren't bounced into the HIGHMEM zone ... They /should/ just

buffers/dcache/icache can't be allocated in HIGHMEM zone. Only page cache can
live in HIGHMEM by using bounce buffers for doing the I/O.

> be moved to the HIGHMEM zone where they don't bother the rest
> of the system, but for some reason it looks like that doesn't
> work right on your system ...

That shouldn't be the problem, the bounce buffer logic isn't changed since
test6 that is reported not to show the bad behaviour.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
