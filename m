Message-Id: <200107272347.f6RNlTs15460@maild.telia.com>
Content-Type: text/plain;
  charset="iso-8859-1"
From: Roger Larsson <roger.larsson@skelleftea.mail.telia.com>
Subject: Re: 2.4.8-pre1 and dbench -20% throughput
Date: Sat, 28 Jul 2001 01:43:31 +0200
References: <200107272112.f6RLC3d28206@maila.telia.com> <0107280034050V.00285@starship>
In-Reply-To: <0107280034050V.00285@starship>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi again,

It might be variations in dbench - but I am not sure since I run
the same script each time.

(When I made a testrun in a terminal window - with X running, but not doing 
anything activly, I got
[some '.' deleted] 
.............++++++++++++++++++++++++++++++++********************************
Throughput 15.8859 MB/sec (NB=19.8573 MB/sec  158.859 MBit/sec)
14.74user 22.92system 4:26.91elapsed 14%CPU (0avgtext+0avgdata 0maxresident)k
0inputs+0outputs (912major+1430minor)pagefaults 0swaps

I have never seen anyting like this - all '+' together! 

I logged off and tried again - got more normal values 32 MB/s
and '+' were spread out.

More testing needed...

/RogerL

On Saturdayen den 28 July 2001 00:34, Daniel Phillips wrote:
> On Friday 27 July 2001 23:08, Roger Larsson wrote:
> > Hi all,
> >
> > I have done some throughput testing again.
> > Streaming write, copy, read, diff are almost identical to earlier 2.4
> > kernels. (Note: 2.4.0 was clearly better when reading from two files
> > - i.e. diff - 15.4 MB/s v. around 11 MB/s with later kenels - can be
> > a result of disk layout too...)
> >
> > But "dbench 32" (on my 256 MB box) results has are the most
> > interesting:
> >
> > 2.4.0 gave 33 MB/s
> > 2.4.8-pre1 gives 26.1 MB/s (-21%)
> >
> > Do we now throw away pages that would be reused?
> >
> > [I have also verified that mmap002 still works as expected]
>
> Could you run that test again with /usr/bin/time (the GNU time
> function) so we can see what kind of swapping it's doing?
>
> The use-once approach depends on having a fairly stable inactive_dirty
> + inactive_clean queue size, to give use-often pages a fair chance to
> be rescued.  To see how the sizes of the queues are changing, use
> Shift-ScrollLock on your text console.
>
> To tell the truth, I don't have a deep understanding of how dbench
> works.  I should read the code now and see if I can learn more about it
>
> :-/  I have noticed that it tends to be highly variable in performance,
>
> sometimes showing variation of a few 10's of percents from run to run.
> This variation seems to depend a lot on scheduling.  Do you see "*"'s
> evenly spaced throughout the tracing output, or do you see most of them
> bunched up near the end?
>
> --
> Daniel

-- 
Roger Larsson
Skelleftea
Sweden
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
