Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA06972
	for <linux-mm@kvack.org>; Thu, 23 Jul 1998 15:15:25 -0400
Date: Thu, 23 Jul 1998 18:18:49 +0100
Message-Id: <199807231718.SAA13683@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: More info: 2.1.108 page cache performance on low memory
In-Reply-To: <87zpe0u0dg.fsf@atlas.CARNet.hr>
References: <199807131653.RAA06838@dax.dcs.ed.ac.uk>
	<m190lxmxmv.fsf@flinx.npwt.net>
	<199807141730.SAA07239@dax.dcs.ed.ac.uk>
	<m14swgm0am.fsf@flinx.npwt.net>
	<87d8b370ge.fsf@atlas.CARNet.hr>
	<m1pvf3jeob.fsf@flinx.npwt.net>
	<87hg0c6fz3.fsf@atlas.CARNet.hr>
	<199807221040.LAA00832@dax.dcs.ed.ac.uk>
	<87iukovq42.fsf@atlas.CARNet.hr>
	<199807231222.NAA04748@dax.dcs.ed.ac.uk>
	<87zpe0u0dg.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Zlatko.Calusic@CARNet.hr
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@npwt.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 23 Jul 1998 16:07:23 +0200, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
said:

> Strangely enough, I think I never explained why do *I* think
> integrating buffer cache functionality into page cache would (in my
> thought) be a good thing. Since both caches are very different, I'm
> not sure memory management can be fair enough in some cases.

> Take a simple example: two applications, I/O bound, where one is
> accessing raw partition (e.g. fsck) and other uses filesystem (web,
> ftp...). Question is, how do I know that MM is fair. Maybe page cache
> grows too large on behalf of buffer cache, so fsck runs much slower
> than it could. Or if buffer cache grows faster (which is not the case,
> IMO) then web would be fast, but fsck (or some database accessing raw
> partition) could take a penalty.

There's a single loop in shrink_mmap() which treats both buffer-cache
pages and page-cache pages identically.  It just propogates the buffer
referenced bits into the page's PG_referenced bit before doing any
ageing on the page.  It should be fair enough.  There are other issues
concerning things like locked and dirty buffers which complicate the
issue, but they are not sufficient reason to throw away the buffer
cache!

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
