Message-ID: <39E4E543.8A4EB3BF@norran.net>
Date: Thu, 12 Oct 2000 00:10:11 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: 2.4.0test9 vm: disappointing streaming i/o under load
References: <Pine.LNX.4.21.0010112154300.23989-100000@ferret.lmh.ox.ac.uk>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Evans <chris@scary.beasts.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

(you do have DMA enabled...)

I have tested throughput - new kernels are rather good.

I have also tested latency stuff in test9 - I have not
seen any thing as bad as your results.
But my audio apps runs with high priority...

To be able to determine the cause
Try to to renice your audio deamon (and audio clients)
 renice -10 <pid>


Did it become better?


/RogerL


Chris Evans wrote:
> 
> On Wed, 11 Oct 2000, Eric Lowe wrote:
> 
> > > Unfortunately, 2.4.0test9 exhibits poor streaming i/o performance when
> > > under a bit of memory pressure.
> 
> [...]
> 
> > Would you try setting /proc/sys/vm/page-cluster to 8 or 16 and let
> > me know the results?  I think one _part_ of the problem is that
> > when the swapper isn't agressive enough, it causes too much disk
> > thrashing which gets in the way of normal I/O... my experience
> > has been that with modern disks with 512K+ cache you have to
> > write in 64K clusters to get optimum throughput.
> 
> Raising the cluster size didn't seem to do much apart from generally slow
> down interactive response. Lowering it, however, seemed to make playback
> less jittery. I guess that's to be expected; faulting in large chunks of
> sequential i/o won't help much when under memory pressure because the
> pages will get thrown out again before they get a chance to be
> used. Especially with drop_behind.
> 
> Rik what do you think.
> 
> Cheers
> Chris
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
