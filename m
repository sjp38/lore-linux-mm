Date: Sun, 29 Aug 2004 10:45:43 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: Kernel 2.6.8.1: swap storm of death - nr_requests > 1024 on swap
 partition
In-Reply-To: <20040829141718.GD10955@suse.de>
Message-ID: <Pine.LNX.4.44.0408291045030.20421-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <axboe@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, William Lee Irwin III <wli@holomorphy.com>, karl.vogel@pandora.be, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 29 Aug 2004, Jens Axboe wrote:

> Oh, and I think the main issue is the vm. It should cope correctly no
> matter how much pending memory can be in progress on the queue, else it
> should not write out so much. CFQ is just exposing this bug because it
> defaults to bigger nr_requests.

Agreed.  If the VM is short 10MB of free memory, it really
shouldn't start 200MB worth of writes.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
