Date: Thu, 8 Nov 2007 16:53:20 +0000
Subject: Re: bug #5493
Message-ID: <20071108165320.GA23882@skynet.ie>
References: <32209efe0711071800v4bc0c62er7bc462f1891c9dcd@mail.gmail.com> <20071107191247.04d74241.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20071107191247.04d74241.akpm@linux-foundation.org>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Natalie Protasevich <protasnb@gmail.com>, linux-mm@kvack.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On (07/11/07 19:12), Andrew Morton didst pronounce:
> (added linux-mm)
> 
> > On Wed, 7 Nov 2007 18:00:20 -0800 "Natalie Protasevich" <protasnb@gmail.com> wrote:
> > Andrew, this one http://bugzilla.kernel.org/show_bug.cgi?id=5493 looks
> > serious, and I'm not sure who to ping now that the reporter can't test
> > it anymore.
> > This is about mprotect ...
> 
> No, I don't think anyone knows how to fix that.
> 
> Fortunately I'm only aware of the one person hitting this problem.
> 

I tried out the test program with 1GiB of memory. First, the program could
not even run unless mprotect was called again to make pages read-only a
second time - otherwise mprotect would report ENOMEM because VMAs were not
getting merged. That in itself was a little unexpected.

After fixing that, I ran with varying number of pages and got the
following timings

300000: 68.36 seconds
295000: 55.07 seconds
290000: 41.79 seconds
285000: 31.71 seconds
280000: 22.92 seconds
275000: 11.27 seconds
270000: 5.60 seconds
265000: 5.94 seconds
260000: 5.77 seconds
255000: 5.65 seconds
250000: 5.53 seconds
245000: 5.42 seconds
240000: 5.31 seconds

The system has about 250000 pages and around that mark it seemed fine in
terms of time-to-completion. Above that vmstat was showing high figures
for si/so which is not a major suprise as such.

If this only occurs on systems with large amounts of memory, could it be
a variation of the excessive page-scanning problem that Rik has been on
about?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
