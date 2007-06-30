Date: Sat, 30 Jun 2007 12:13:40 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC] fsblock
Message-ID: <20070630111340.GA24946@infradead.org>
References: <20070624014528.GA17609@wotan.suse.de> <467DE00A.9080700@garzik.org> <20070630104244.GC24123@infradead.org> <46863A23.2010001@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <46863A23.2010001@garzik.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jeff@garzik.org>
Cc: Christoph Hellwig <hch@infradead.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sat, Jun 30, 2007 at 07:10:27AM -0400, Jeff Garzik wrote:
> >Not really, the current behaviour is a bug.  And it's not actually buffer
> >layer specific - XFS now has a fix for that bug and it's generic enough
> >that everyone could use it.
> 
> I'm not sure I follow.  If you require block allocation at mmap(2) time, 
> rather than when a page is actually dirtied, you are denying userspace 
> the ability to do sparse files with mmap.
> 
> A quick Google readily turns up people who have built upon the 
> mmap-sparse-file assumption, and I don't think we want to break those 
> assumptions as a "bug fix."
> 
> Where is the bug?

It's not mmap time but page dirtying time.  Currently the default behaviour
is not to allocate at page dirtying time but rather at writeout time in
some scenarious.

(and s/allocation/reservation/ applies for delalloc of course)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
