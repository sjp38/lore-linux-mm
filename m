Subject: Re: PROBLEM: System Freeze on Particular workload with kernel 2.6.22.6
In-Reply-To: <46F0E19D.8000400@andrew.cmu.edu>
References: <46F0E19D.8000400@andrew.cmu.edu>
Date: Wed, 19 Sep 2007 17:47:56 +0200
Message-Id: <E1IY1mO-00067S-7v@flower>
From: Oleg Verych <olecom@flower.upol.cz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Low Yucheng <ylow@andrew.cmu.edu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* Wed, 19 Sep 2007 04:45:17 -0400
>
> [1.] Summary
> System Freeze on Particular workload with kernel 2.6.22.6
>
> [2.] Description
> System freezes on repeated application of the following command
> for f in *png ; do convert -quality 100 $f `basename $f png`jpg; done
>
> Problem is consistent and repeatable.
> Problem persists when running on a different drive, and also in pure console (no X).
>
> One time, the following error logged in syslog:
> Sep 19 04:22:11 mossnew kernel: [  301.883919] VM: killing process convert
> Sep 19 04:22:11 mossnew kernel: [  301.884382] swap_free: Unused swap offset entry 0000ff00
> Sep 19 04:22:11 mossnew kernel: [  301.884421] swap_free: Unused swap offset entry 00000300
> Sep 19 04:22:11 mossnew kernel: [  301.884456] swap_free: Unused swap offset entry 00000200
> Sep 19 04:22:11 mossnew kernel: [  301.884491] swap_free: Unused swap offset entry 0000ff00
> Sep 19 04:22:11 mossnew kernel: [  301.884527] swap_free: Unused swap offset entry 0000ff00
> Sep 19 04:22:11 mossnew kernel: [  301.884562] swap_free: Unused swap offset entry 00000100
>
> Should not be a RAM problem. RAM has survived 12 hrs of Memtest with no errors.
> Should not be a CPU problem either. I have been running CPU intensive tasks for days.
>
> [3.] Keywords
> freeze, swap_free,VM

Nice bug report, seems like from linux-source/REPORTING-BUGS.
But still:

* no relevant Cc (memory management added)
+ no output of `mount` (because if swap is on some file system, that
  *can* be another problem)
+ no information about amount of memory and its BIOS configuration

FYI, latter two (and much more) is one `dmesg` output. This output,
together with any other kernel information can be gathered by serial or
net consoles:

linux-source/Documentation/serial-console.txt
linux-source/Documentation/networking/netconsole.txt 

If console messages after freeze can be seen in text mode VGA/CRT
also, photos of it somewhere on ftp will be OK.

> [4.] /proc/version
> Linux version 2.6.22.6intelcore2 (root@mossnew) (gcc version 4.1.2 (Ubuntu 4.1.2-0ubuntu4)) #1 SMP Sat Sep 15 00:29:00 EDT 2007
>
> [5.] No Oops
>
> [6.] Trigger
> - Create a large number of png images. (a few hundred)
>
> - repeatedly run
> for f in *png ; do convert -quality 100 $f `basename $f png`jpg; done
>
> - This might be subjective, but the freeze seems to show up sooner if there is a CPU heavy
> process running in the background.
>
> [7] Environment
> [7.1] Software /script/ver_linux
>
> Linux mossnew 2.6.22.6intelcore2 #1 SMP Sat Sep 15 00:29:00 EDT 2007 x86_64 GNU/Linux
>
[]
____

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
