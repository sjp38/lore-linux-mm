Date: Tue, 25 Apr 2000 10:35:52 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: pressuring dirty pages (2.3.99-pre6)
Message-ID: <20000425103552.A4627@redhat.com>
References: <20000424222702.C3389@redhat.com> <Pine.LNX.4.21.0004241922270.5572-100000@duckman.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0004241922270.5572-100000@duckman.conectiva>; from riel@conectiva.com.br on Mon, Apr 24, 2000 at 07:42:12PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Apr 24, 2000 at 07:42:12PM -0300, Rik van Riel wrote:
> 
> That will not work. The problem isn't that kswapd eats cpu,
> but the problem is that the dirty pages completely dominate
> physical memory.

That isn't a "problem".  That's a state.  Of _course_ memory usage
is going to be dominated by whichever sort of page is being 
predominantly used.

So we need to identify the real problem.  Is 2.3 much worse than
2.2 at this dirty-write-mmap test?  Are we seeing swap fragmentation
reducing swap throughput?  Is the VM simply keeping insufficient
memory available for tasks other than the highly paging one?

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
