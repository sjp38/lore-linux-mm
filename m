Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA04705
	for <linux-mm@kvack.org>; Thu, 3 Dec 1998 06:58:29 -0500
Date: Thu, 3 Dec 1998 11:56:38 GMT
Message-Id: <199812031156.LAA03268@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Update shared mappings
In-Reply-To: <Pine.LNX.3.96.981202191811.4720A-100000@dragon.bogus>
References: <199812021621.QAA04235@dax.scot.redhat.com>
	<Pine.LNX.3.96.981202191811.4720A-100000@dragon.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Zlatko.Calusic@CARNet.hr, Linux-MM List <linux-mm@kvack.org>, Andi Kleen <andi@zero.aec.at>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 2 Dec 1998 19:32:56 +0100 (CET), Andrea Arcangeli
<andrea@e-mind.com> said:

> I have a question. Please consider only the UP case (as if linux would not
> support SMP at all). Is it possible that while we are running inside
> sys_msync() and another process has the mmap semaphore held?

No, because sys_msync() takes the mm semaphore first thing.  Another
process _can_ hold the mm semaphore of a different vma on the same
region of the file, however.

> Stephen I read some emails about a PG_dirty flag. Could you tell me some
> more about that flag? 

When it gets implemented it will have whatever semantics we choose to
give it. :)  

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
