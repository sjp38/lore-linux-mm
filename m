From: Gene Heskett <gene.heskett@verizon.net>
Reply-To: gene.heskett@verizon.net
Subject: Re: 2.6.0-test9-mm4
Date: Wed, 19 Nov 2003 06:13:22 -0500
References: <20031118225120.1d213db2.akpm@osdl.org>
In-Reply-To: <20031118225120.1d213db2.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200311190613.22515.gene.heskett@verizon.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 19 November 2003 01:51, Andrew Morton wrote:
>ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-
>test9/2.6.0-test9-mm4/
>
>
>. Several fixes against patches which are only in -mm at present.
>
>. Minor fixes which we'll queue for post-2.6.0.
>
>. The interactivity problems which the ACPI PM timer patch showed up
>  should be fixed here - please sing out if not.
>
Here, I've rebooted to various elevators and run each for at least a 
day, and for mm3, I'd have to say that the diffs are tolerable, but 
the smoothest, most responsive is the deadline version. as still 
gives an occasional 20 millisecond stutter, and cfq might be 10 
milliseconds.  Even as is a far cry from the near show stopper 15 to 
20 second hangs of the performance in the later 2.4's.  Great work 
guys!

[...]

-- 
Cheers, Gene
AMD K6-III@500mhz 320M
Athlon1600XP@1400mhz  512M
99.27% setiathome rank, not too shabby for a WV hillbilly
Yahoo.com attornies please note, additions to this message
by Gene Heskett are:
Copyright 2003 by Maurice Eugene Heskett, all rights reserved.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
