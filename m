Date: Sun, 18 Aug 2002 01:01:12 +0100 (IST)
From: Mel <mel@csn.ul.ie>
Subject: Re: VM Regress 0.5 - Compile error with CONFIG_HIGHMEM
In-Reply-To: <20020817132153.A11758@infradead.org>
Message-ID: <Pine.LNX.4.44.0208180058530.15099-100000@skynet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 17 Aug 2002, Christoph Hellwig wrote:

> Shouldn't an undonditional #include <linux/highmem.h> do it much cleaner?
>

I imagine so, but I had a bus to catch and didn't have time to verify if
they were files that should be unconditionally included. As it will be
Monday before I'm working again, I choose the safe option

-- 
Mel Gorman
MSc Student, University of Limerick
http://www.csn.ul.ie/~mel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
