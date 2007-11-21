Date: Wed, 21 Nov 2007 15:29:42 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Page allocator: Get rid of the list of cold pages
In-Reply-To: <20071121230041.GE31674@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0711211527480.4383@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0711141148200.18811@schroedinger.engr.sgi.com>
 <20071115162706.4b9b9e2a.akpm@linux-foundation.org> <20071121222059.GC31674@csn.ul.ie>
 <Pine.LNX.4.64.0711211434290.3809@schroedinger.engr.sgi.com>
 <20071121230041.GE31674@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, apw@shadowen.org, Martin Bligh <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

On Wed, 21 Nov 2007, Mel Gorman wrote:

> > 2) it may be useful to do these tests with anonymous pages because the 
> > file handling paths are rather slow and you may not hit zone lock 
> > contention because there are other things in the way (radix tree?)
> 
> I suspected this too, but thought if I went with anonymous pages we would
> just get hit with mmap_sem instead and the results would not be significantly
> different. I had also considered creating the files on tmpfs. In the end
> I decided the original investigation was a filesystem and was as good a
> starting point as any.

Well you would get a hot cacheline with the semaphore. Its taken as a read 
lock so its not a holdoff in contrast to the zone lock where we actually 
spin until its available. In my experience it takes longer for the mmap 
sem cacheline to become a problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
