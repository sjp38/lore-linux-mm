Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 00F0C6B005D
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 20:46:27 -0500 (EST)
Date: Fri, 11 Jan 2013 12:46:15 +1100
From: paul.szabo@sydney.edu.au
Message-Id: <201301110146.r0B1kF4T032208@como.maths.usyd.edu.au>
Subject: Re: [RFC] Reproducible OOM with partial workaround
In-Reply-To: <50EF6A2C.7070606@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@linux.vnet.ibm.com
Cc: 695182@bugs.debian.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Dear Dave,

> ... I don't believe 64GB of RAM has _ever_ been booted on a 32-bit
> kernel without either violating the ABI (3GB/1GB split) or doing
> something that never got merged upstream ...

Sorry to be so contradictory:

psz@como:~$ uname -a
Linux como.maths.usyd.edu.au 3.2.32-pk06.10-t01-i386 #1 SMP Sat Jan 5 18:34:25 EST 2013 i686 GNU/Linux
psz@como:~$ free -l
             total       used       free     shared    buffers     cached
Mem:      64446900    4729292   59717608          0      15972     480520
Low:        375836     304400      71436
High:     64071064    4424892   59646172
-/+ buffers/cache:    4232800   60214100
Swap:    134217724          0  134217724
psz@como:~$ 

(though I would not know about violations).

But OK, I take your point that I should move with the times.

Cheers, Paul

Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
School of Mathematics and Statistics   University of Sydney    Australia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
