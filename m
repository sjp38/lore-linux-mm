Received: by rproxy.gmail.com with SMTP id c51so1459514rne
        for <linux-mm@kvack.org>; Tue, 05 Apr 2005 03:50:05 -0700 (PDT)
Message-ID: <ea908f9e050405035024b5bcc3@mail.gmail.com>
Date: Tue, 5 Apr 2005 10:50:05 +0000
From: RichardR <randjunk@gmail.com>
Reply-To: RichardR <randjunk@gmail.com>
Subject: The using of memory buffer/cache and free
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,
I just want to wipe out some doubts in my knowledges about how
processes and kernel use memory buffer/cache and memory free.
My doubt is, when I run the first time my machine and when I run
"free"... it shows me corrret numbers. no memory leaks on view...

Now when I try to run some process, like a  simple rsync transfer
which takes some time to finish...I just can see that my "free" goes
down, which can be explained with the rsync activities...
after some minutes...the rsync ended and what I can still see is this:

root@4[root]# free
             total       used       free     shared    buffers     cached
Mem:       2075428    2051948      23480          0      10872    1965908
-/+ buffers/cache:      75168    2000260
Swap:            0          0          0
--
Memory free is not flushed out even after an "update" or "sync" and
cached is highly stored.

Now when I want to know the total load of memory used by running
processes, I can find only 151320 bytes used! and my total memory is
2Gb, the rest is on cached...

root@4[root]# ps auwwx | sort -n +4 | awk 'BEGIN{a=0}($5 > 0) { a+=$5;
print $5,$11 }END{print a}' | grep -v sort | tail +2
76 init
1564 grep
1628 /usr/sbin/automount
1752 tail
1920 awk
2512 ps
2572 /bin/sh
2572 /bin/sh
3108 /usr/sbin/sshd
3432 /bin/bash
3432 /bin/bash
3432 /bin/bash
3432 /bin/bash
3440 -bash
6076 sshd:
6700 icewm
6700 -bash
6700 -bash
6736 -bash
9944 xterm
9944 xterm
10252 xterm
26248 XFree86
151320

my question is: is it normal that such a process can demande such
memory free and then cached by the kernel without being flushed after
used?
Thanks guys in advance for your lights...
Cheers
-- 
Richard R.
IT Soft/System Engineer
CNRS/IN2P3/LPNHE 
Jussieu - Paris VI
--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
