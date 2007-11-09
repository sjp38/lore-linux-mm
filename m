Date: Thu, 8 Nov 2007 20:27:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: bug #5493
Message-Id: <20071108202707.d7efed57.akpm@linux-foundation.org>
In-Reply-To: <20071108200041.1a739bc5@bree.surriel.com>
References: <32209efe0711071800v4bc0c62er7bc462f1891c9dcd@mail.gmail.com>
	<20071107191247.04d74241.akpm@linux-foundation.org>
	<20071108165320.GA23882@skynet.ie>
	<20071108095704.f98905ec.akpm@linux-foundation.org>
	<20071108131518.5408931d@bree.surriel.com>
	<20071108105659.3ca01b00.akpm@linux-foundation.org>
	<20071108200041.1a739bc5@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: mel@skynet.ie, protasnb@gmail.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Thu, 8 Nov 2007 20:00:41 -0500 Rik van Riel <riel@redhat.com> wrote:
> On Thu, 8 Nov 2007 10:56:59 -0800
> Andrew Morton <akpm@linux-foundation.org> wrote:
> > > On Thu, 8 Nov 2007 13:15:18 -0500 Rik van Riel <riel@redhat.com> wrote:
> > > On Thu, 8 Nov 2007 09:57:04 -0800
> 
> > > > No, it was due to linear traversal of very long reverse-mapping lists
> > > > (thousands of elements, irrc).
> > > 
> > > Traversal at pageout time, or at mprotect time?
> > > 
> > 
> > pageout, iirc.  For each page we were walking a linear list of I think
> > ~10,000 elements.
> 
> Pageout scan complexity in this workload is O(P*M), where
> P is the number of pages scanned and M is the number of
> mappings.
> 
> My code will, in the next iteration, reduce P by a fair
> amount for larger amounts of memory, but M is still very
> large...

That's yet to be proven - for the vast majority of workloads your P is
already very small.

> I might use this test case to play with the SEQ replacement
> of anonymous pages.  Figuring out how to avoid some worst
> case that people really hit in practice is often educational.

I don't think we can anywhere near fix this without basic redesign of VM
data structures and the relationship between them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
