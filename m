Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA26568
	for <linux-mm@kvack.org>; Mon, 17 Aug 1998 11:53:30 -0400
Date: Mon, 17 Aug 1998 14:57:16 +0100
Message-Id: <199808171357.OAA02998@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: More info: 2.1.108 page cache performance on low memory
In-Reply-To: <Pine.LNX.4.02.9808020002110.424-100000@iddi.npwt.net>
References: <199807271102.MAA00713@dax.dcs.ed.ac.uk>
	<Pine.LNX.4.02.9808020002110.424-100000@iddi.npwt.net>
Sender: owner-linux-mm@kvack.org
To: ebiederm+eric@npwt.net
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Sorry, I'm just back from 2 weeks on holiday.

On Sun, 2 Aug 1998 00:19:52 -0500 (CDT), Eric W Biederman
<eric@flinx.npwt.net> said:

>> We *need* a mechanism which is block-aligned, not page-aligned.  The
>> buffer cache is a good way of doing it.  Forcing block device caching
>> into a page-aligned cache is not necessarily going to simplify things.

> The page-aligned property is only a matter of the inode,offset hash
> table, and virtually nothing else really cares.  Shrink_mmap, or
> pgflush, the most universall parts of the page cache do not.

Any mmap()able files *need* to be page aligned in cache.  Internal
filesystem accesses are always block aligned, not page aligned.  That's
the conflict.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
