Message-Id: <200308222224.h7MMOCs15182@mail.osdl.org>
Subject: Re: 2.6.0-test3-mm3 
In-Reply-To: Message from Andrew Morton <akpm@osdl.org>
   of "Tue, 19 Aug 2003 01:38:34 PDT." <20030819013834.1fa487dc.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Date: Fri, 22 Aug 2003 15:24:12 -0700
From: Cliff White <cliffw@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cliffw@osdl.org
List-ID: <linux-mm.kvack.org>

> 
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test3/2.6.0-test3-mm3/
> 
> 
> . More CPU scheduler changes
> 
> . The regression with reaim which was due to the CPU scheduler changes
>   seems to have largely gone away, but it was never a large effect in my
>   testing.  Needs retesting please.
> 

Have some tests completed. 
Results are ..interesting.
All results:
 http://developer.osdl.org/cliffw/reaim/index.html

On a gross level, the delta has indeed shrunk:
STP 4-CPU
STP id PLM# KernelName        Workfile  MaxJPM  MaxUser Host     Change
277851 2063 2.6.0-test3-mm3   new_dbase 5327.15  88     stp4-000  0.00
277455 2049 linux-2.6.0-test3 new_dbase 5324.95  92     stp4-000 -0.04

However, if we look at the detail within the runs, the two kernels do run
differently. It's not really good/bad, just different.
 
Basically, -mm3 runs a little slower, but steadier.
-test3 has bigger peaks and valleys, the average between the two over the run comes 
out about the same. Example:

Num children  JPM/-mm3    JPM/-test3
44            5079.77     5183.81
48            5130.43     4853.96
52            5102.86     5161.39

Numbers taken from:
-test3 -> http://khack.osdl.org/stp/277455/results/allruns.html
-mm3 ->   http://khack.osdl.org/stp/277851/results/allruns.html

Sorry to be so vague..more tests are underway.

Code location:
bk://developer.osdl.org/osdl-aim-7
tarball:
http://sourceforge.net/projects/re-aim-7

Run parameters:

./reaim -s$CPU_COUNT -x -t -i$CPU_COUNT -f workfile.new_dbase -r3 -b -l./stp.config
./reaim -s$CPU_COUNT -q -t -i$CPU_COUNT -f workfile.new_dbase -r3 -b -l./stp.config
(3 runs each, average of all 6 reported)

cliffw


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
