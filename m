Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA31144
	for <linux-mm@kvack.org>; Fri, 19 Mar 1999 09:48:43 -0500
Date: Fri, 19 Mar 1999 14:48:21 GMT
Message-Id: <199903191448.OAA01416@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Possible optimization in ext2_file_write()
In-Reply-To: <199903181816.XAA12650@vxindia.vxindia.veritas.com>
References: <199903181816.XAA12650@vxindia.vxindia.veritas.com>
Sender: owner-linux-mm@kvack.org
To: V Ganesh <ganesh@vxindia.veritas.com>
Cc: linux-kernel@vger.rutgers.edu, Stephen Tweedie <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 18 Mar 1999 23:46:57 +0530 (IST), V Ganesh
<ganesh@vxindia.veritas.com> said:

> 	it looks like whenever we write a partial block which 
> doesn't exist in the buffer cache, ext2_file_write() (and
> possibly the write functions of other filesystems) directly
> reads that block from the block device without checking if
> it is present in the page cache. 

Correct...

> Of course, typical UNIX programs/shell jobs don't indulge in
> this kind of behaviour. General workstation usage (X,
> kernel compiles etc.) for a day caused only 32 unnecessary
> reads. 

... and also correct.

> So unless there are any specific application categories which
> require this I guess it's not worth the trouble to patch.

I'd agree (strongly).  It ties in with your next question:

> Anyone working on a VM revamp or buffer/page cache unification ?

Yes.  We still need the buffer cache (or something very like it) for
filesystem metadata caching and for block IO.  However, 2.3 _will_ see
us using the page cache for data writeback (and we already have
prototype patches to support that sort of behaviour).  The linux-mm
list has been discussing it for some time.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
