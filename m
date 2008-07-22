From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH -mm] mm: more likely reclaim MADV_SEQUENTIAL mappings
Date: Tue, 22 Jul 2008 12:02:26 +1000
References: <87y73x4w6y.fsf@saeurebad.de> <200807211549.00770.nickpiggin@yahoo.com.au> <20080721111412.0bfcd09b@bree.surriel.com>
In-Reply-To: <20080721111412.0bfcd09b@bree.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807221202.27169.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@saeurebad.de>, Peter Zijlstra <peterz@infradead.org>, Nossum <vegard.nossum@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tuesday 22 July 2008 01:14, Rik van Riel wrote:
> On Mon, 21 Jul 2008 15:49:00 +1000
>
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> > It is already bad because: if you are doing a big streaming copy
> > which you know is going to blow the cache and not be used again,
> > then you should be unmapping behind you as you go.
>
> MADV_SEQUENTIAL exists for a reason.

AFAIKS it is to open up readahead mainly. Because it is quite reasonable
to otherwise be much more conservative about readahead than with regular
reads (and of course you can't do big chunks per kernel entry)...

I don't actually care what the man page or posix says if it is obviously
silly behaviour. If you want to dispute the technical points of my post,
that would be helpful.


> If you think that doing an automatic unmap-behind will be
> a better way to go, we can certainly whip up a patch for
> that...

I don't. Don't let me stop you trying of course :)

Consider this: if the app already has dedicated knowledge and
syscalls to know about this big sequential copy, then it should
go about doing it the *right* way and really get performance
improvement. Automatic unmap-behind even if it was perfect still
needs to scan LRU lists to reclaim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
