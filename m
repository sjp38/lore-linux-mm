Subject: Re: xmm2 - monitor Linux MM active/inactive lists graphically
References: <Pine.LNX.4.33.0110261018270.1001-100000@penguin.transmeta.com>
Reply-To: zlatko.calusic@iskon.hr
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
Date: 28 Oct 2001 18:30:14 +0100
In-Reply-To: <Pine.LNX.4.33.0110261018270.1001-100000@penguin.transmeta.com> (Linus Torvalds's message of "Fri, 26 Oct 2001 10:19:03 -0700 (PDT)")
Message-ID: <87k7xfk6zd.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Jens Axboe <axboe@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Linus Torvalds <torvalds@transmeta.com> writes:

> On Fri, 26 Oct 2001, Linus Torvalds wrote:
> >
> > Attached is a very untested patch (but hey, it compiles, so it must work,
> > right?)
> 
> And it actually does seem to.
> 
> Zlatko, does this make a difference for your disk?
> 

First, sorry for such a delay in answering, I was busy.

I compiled 2.4.14-pre3 as it seems to be identical to your p2p3 patch,
with regard to queue processing.

Unfortunately, things didn't change on my first disk (IBM 7200rpm
@home). I'm still getting low numbers, check the vmstat output at the
end of the email.

But, now I found something interesting, other two disk which are on
the standard IDE controller work correctly (writing is at 17-22
MB/sec). The disk which doesn't work well is on the HPT366 interface,
so that may be our culprit. Now I got the idea to check patches
retrogradely to see where it started behaving poorely.

Also, one more thing, I'm pretty sure that under strange circumstances
(specific alignment of stars) it behaves well (with appropriate
writing speed). I just haven't yet pinpointed what needs to be done to
get to that point.

I know I haven't supplied you with a lot of information, but I'll keep
investigating until I have some more solid data on the problem.

BTW, thank you and Jens for nice explanation of the numbers, very good
reading.

 0  2  0  13208   2924    516 450716   0   0     0 11808  179   113   0   6  93
 0  1  0  13208   2656    524 450964   0   0     0  8432  174    86   1   6  93
 0  1  0  13208   3676    532 449924   0   0     0  8432  174    91   1   4  95
 0  1  0  13208   3400    540 450172   0   0     0  8432  231   343   1   4  94
 0  2  0  13208   3520    548 450036   0   0     0  8440  180   179   2   5  93
 0  1  0  20216   3544    728 456976  32   0    32  8432  175    94   0   4  95
 0  2  0  20212   3280    728 457232   0   0     0  8440  174    88   0   5  95
 0  2  0  20208   3032    728 457480   0   0     0  8364  174    84   1   4  95
   procs                      memory    swap          io     system         cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
 0  2  0  20208   3412    732 457092   0   0     0  6964  175   111   0   4  96
 0  2  0  20208   3272    728 457224   0   0     0  1216  207    89   0   1  99
 0  2  0  20208   3164    728 457352   0   0     0  1300  256    77   1   2  97
 0  2  1  20208   2928    732 457604   0   0     0  1444  283    77   1   0  99
 0  2  1  20208   2764    732 457732   0   0     0  1316  278    73   1   1  98
 0  2  1  20208   3420    728 457096   0   0     0  1652  273   117   0   1  99
 0  2  1  20208   3180    732 457348   0   0     0  1404  240    90   0   0  99
 0  2  1  20208   3696    728 456840   0   0     0  1784  247    80   0   1  98
 0  2  1  20204   3432    728 457096   0   0     0  1404  237    77   1   0  99
 0  2  1  20204   2896    732 457604   0   0     0  1672  255    77   1   1  98
 0  1  0  20204   3284    728 457224   0   0     0  1976  257   112   0   2  98
 0  1  0  20204   2772    728 457736   0   0     0  7628  260   100   0   4  96
 0  1  0  20204   3540    728 456968   0   0     0  8492  178    83   1   4  95
 0  2  0  20204   3584    736 456916   0   0     4  4848  175    88   0   2  97

Regards,
-- 
Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
