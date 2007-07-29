From: Al Boldi <a1426z@gawab.com>
Subject: Re: How can we make page replacement smarter
Date: Sun, 29 Jul 2007 17:55:24 +0300
Message-ID: <200707291755.24906.a1426z@gawab.com>
References: <200707272243.02336.a1426z@gawab.com> <200707280717.41250.a1426z@gawab.com> <46ABF184.40803@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763778AbXG2O4S@vger.kernel.org>
In-Reply-To: <46ABF184.40803@redhat.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Rik van Riel <riel@redhat.com>
Cc: Chris Snook <csnook@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Rik van Riel wrote:
> Al Boldi wrote:
> > Good idea, but unless we understand the problems involved, we are bound
> > to repeat it.  So my first question would be:  Why is swap-in so slow?
> >
> > As I have posted in other threads, swap-in of consecutive pages suffers
> > a 2x slowdown wrt swap-out, whereas swap-in of random pages suffers over
> > 6x slowdown.
> >
> > Because it is hard to quantify the expected swap-in speed for random
> > pages, let's first tackle the swap-in of consecutive pages, which should
> > be at least as fast as swap-out.  So again, why is swap-in so slow?
>
> I suspect that this is a locality of reference issue.
>
> Anonymous memory can get jumbled up by repeated free and
> malloc cycles of many smaller objects.  The amount of
> anonymous memory is often smaller than or roughly the same
> size as system memory.

Sounds exactly like the tmpfs problem.

> Locality of refenence to anonymous memory tends to be
> temporal in nature, with the same sets of pages being
> accessed over and over again.
>
> Files are different.  File content tends to be grouped
> in large related chunks, both logically in the file and
> on disk.  Generally there is a lot more file data on a
> system than what fits in memory.
>
> Locality of reference to file data tends to be spatial
> in nature, with one file access leading up to the system
> accessing "nearby" data.  The data is not necessarily
> touched again any time soon.
>
> > Once we understand this problem, we may be able to suggest a smart
> > improvement.
>
> Like the one on http://linux-mm.org/PageoutFailureModes ?

Interesting to see that there are known problems, but it doesn't seem to list 
the resume-from-disk swap-in slowdown.

> I have the LRU lists split and am working on getting SEQ
> replacement implemented for the anonymous pages.
>
> The most recent (untested) patches are attached.

Applied against 2.6.22; the kernel crashes out on boot.


Thanks!

--
Al
