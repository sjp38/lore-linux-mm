Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id EAA11352
	for <linux-mm@kvack.org>; Sat, 9 Jan 1999 04:55:41 -0500
Date: Sat, 9 Jan 1999 09:55:25 GMT
Message-Id: <199901090955.JAA05820@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] MM fix & improvement
In-Reply-To: <87k8yw295p.fsf@atlas.CARNet.hr>
References: <87k8yw295p.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Zlatko.Calusic@CARNet.hr
Cc: Linus Torvalds <torvalds@transmeta.com>, Linux-MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi,

On 09 Jan 1999 08:32:50 +0100, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
said:

> 1) Til' now, writing to swap files & partitions was clustered 
> in 128kb chunks which is too small, especially now when we have swapin 
> readahead (default 64kb). 

Right --- it's not actually the write clustering, but the allocation
clustering which was the problem.  Well spotted.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
