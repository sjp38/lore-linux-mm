Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA26562
	for <linux-mm@kvack.org>; Mon, 17 Aug 1998 11:53:18 -0400
Date: Mon, 17 Aug 1998 16:35:48 +0100
Message-Id: <199808171535.QAA03051@dax.dcs.ed.ac.uk>
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

On Sun, 2 Aug 1998 00:19:52 -0500 (CDT), Eric W Biederman
<eric@flinx.npwt.net> said:

> What I was envisioning is using a single write-out daemon 
> instead of 2 (one for buffer cache, one for page cache).  Using the same
> tests in shrink_mmap.  Reducing the size of a buffer_head by a lot because
> consolidating the two would reduce the number of lists needed.  
> To sit the buffer cache upon a single pseudo inode, and keep it's current
> hashing scheme.

The only reason we currently have two daemons is that we need one for
writing dirty memory and another for reclaiming clean memory.  That way,
even when we stall for disk writes, we are still able to reclaim free
memory via shrink_mmap().  The kswapd daemon and the shrink_mmap() code
already treat the page cache and buffer cache both the same.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
