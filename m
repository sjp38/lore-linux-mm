Date: Tue, 13 Feb 2007 10:03:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Use ZVC counters to establish exact size of dirtyable pages
Message-Id: <20070213100336.4ba10f3f.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0702130933001.23798@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702121014500.15560@schroedinger.engr.sgi.com>
	<20070213000411.a6d76e0c.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0702130933001.23798@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Tue, 13 Feb 2007 09:43:43 -0800 (PST) Christoph Lameter <clameter@sgi.com> wrote:
> > I believe i386 NUMA is rare as hen's teeth and perhaps we can just forget
> > about optimising for it.
> 
> I was just trying to avoid complaints..... I'd be glad to drop the stuff. 
> Its going to be much simpler that way.

That code used to do a walk across each CPU's global memory counters and
hence was quite expensive.  But it's called infrequently, so things were
OK.  And it is still called infrequently, so I expect we'll still be OK
here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
