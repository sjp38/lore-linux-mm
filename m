Date: Thu, 19 Apr 2001 17:39:23 +0200 (MEST)
From: Simon Derr <Simon.Derr@imag.fr>
Subject: Want to allocate almost all the memory with no swap
Message-ID: <Pine.LNX.4.21.0104191721370.9949-100000@guarani.imag.fr>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Simon Derr <Simon.Derr@imag.fr>
List-ID: <linux-mm.kvack.org>

Hi,

I'm currently trying to run a high-performance bench on a cluster of PCs
under Linux. This bench is the Linpack test, and needs a lot of memory to
store a matrix of numbers. Linpack needs to allocate as much as 240 Megs
on a machine that has 256 Megs of RAM, but I have to be sure that the
memory used by linpack will never be swapped on the disk.

The bests results I have obtained so far are the following:

* Under Linux 2.4.2: 
 -With swap on, part of the memory used by my process
  is swapped out, which is what I do not want
 
 -With swap off:The memory allocation is OK, my process has all the memory
it needs and can use it. BUT : here is what I get when running top:


CPU states: 49.6% user, 50.3% system,  0.0% nice,  0.0% idle
Mem:   254692K av,  252596K used,    2096K free,       0K shrd    68Kbuff
Swap:       0K av,       0K used,       0K free                  880Kcached

  PID USER     PRI  NI  SIZE  RSS SHARE STAT  LIB %CPU %MEM   TIME COMMAND
    3 root      16   0     0    0     0 DW      0 49.6  0.0  11:10 kswapd
 1142 admin     18   0  240M 240M     4 R       0 49.6 96.5   9:14 loop
    5 root       9   0     0    0     0 SW      0  0.5  0.0   0:12 bdflush
 1149 root      11   0   408  408   240 R       0  0.3  0.1   0:03 top



(loop is the name of my process)
kswapd uses half of my CPU, and even bdflush seems to eat some cpu.
I find a bit weird to see kswapd eat my CPU when I have no swap at all...

* Under Linux 2.2.17:
 -With swap on, same pb as under 2.4.2
 -With swap off, the memory allocation fails.

I tried to tune the values under /proc/sys/vm, with no success.

Any ideas ?

(Please CC me in the reply)

	Thanks,

		Simon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
