Date: Mon, 12 Jun 2000 13:50:58 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: [Fwd] VMM swap interactive performance
Message-ID: <Pine.LNX.3.96.1000612135011.9612B-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>From sct@redhat.com Mon Jun 12 13:47:45 2000

Message-ID: <39450E67.7CC8DA89@baldauf.org>
Date: 	Mon, 12 Jun 2000 18:23:03 +0200
From:   Xuan Baldauf <xuan--reiserfs@baldauf.org>
Organization: Medium.net
X-Mailer: Mozilla 4.73 [en] (Win98; I)
X-Accept-Language: en,de-DE
MIME-Version: 1.0
To:     linux-kernel@vger.rutgers.edu
Subject: VMM swap interactive performance
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-kernel@vger.rutgers.edu
Precedence: bulk
X-Loop: 	majordomo@vger.rutgers.edu
Resent-From: sct@redhat.com
Resent-Date: Mon, 12 Jun 2000 18:45:23 +0100
Resent-To: linux-mm@kvack.org
Return-Path: <sct@redhat.com>
X-Orcpt: rfc822;linux-mm@kvack.org

Hello,

since I switched from 2.2.15 to 2.4.0-test-acX (X is currently 12), I
noticed a significant but subjective slow down in interactive
performance. Under Linux2.2, when I hit some key (I telneted to the
box), the reaction (printing the appropriate character) always came
promptly, even if the box was busy (seti@home, kernel compile, etc).
Normally, you did not "feel" that you use telnet due to latency.

But since using 2.4, there are sometimes seconds between hitting the
key and printing the result. Now I ran a md5sum (besides a kernel
compile and seti) and encountered the same problem, and top showed me
this:

  6:07pm  up 1 day, 23:05,  5 users,  load average: 4.84, 3.08, 2.23
77 processes: 73 sleeping, 4 running, 0 zombie, 0 stopped
CPU states: 24.1% user, 13.9% system,  0.3% nice, 63.2% idle
Mem:   38368K av,  37596K used,    772K free,      0K shrd,    984K
buff
Swap: 120956K av,  33524K used,  87432K free                 18332K
cached

  PID USER     PRI  NI  SIZE  RSS SHARE STAT  LIB %CPU %MEM   TIME
COMMAND
12183 root      19   0   180  136   108 R       0 29.1  0.3   1:28
md5sum
    2 root       1   0     0    0     0 DW      0  1.8  0.0   3:26
kswapd
12283 root       2   0   848  848   656 R       0  1.7  2.2   0:00 top

 1231 root       1   0  1400  624   476 D       0  1.3  1.6   0:35
named
12308 root       0   0  1168 1156   900 S       0  0.5  3.0   0:00
sendmail
12309 root       0   0  1168 1156   900 S       0  0.4  3.0   0:00
sendmail
  735 squid      0   0  8596  676   352 S       0  0.3  1.7   9:56
squid
  799 seti      12  12 13796 7312  2036 R N     0  0.3 19.0  2574m
setiathome

I was somewhat... puzzled, because normally linux would use the
available resources appropriately, but because the CPU was 63.2% idle,
this obviously was wrong. I was used to "overload" the memory with
seti and the like, now I have to kill seti in order to have good
kernel compile speed.

I think the virtual memory management is not optimal for the "memory
overload" case. I assume that the kernel swaps out pages too
aggressively, making them unavailable in the next second.

Does anybody has a ready to run swap-benchmark program? I'd like to
run it and prove the difference.

Xuan. :o)



-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.rutgers.edu
Please read the FAQ at http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
