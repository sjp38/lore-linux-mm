Received: from editec-lotteries.com [192.168.0.138] by editec-lotteries.com [195.246.135.30]
	with SMTP (MDaemon.v3.1.1.R)
	for <linux-mm@kvack.org>; Tue, 17 Apr 2001 12:51:40 +0200
Message-ID: <3ADC21C4.3000807@editec-lotteries.com>
Date: Tue, 17 Apr 2001 12:58:12 +0200
From: Uman <a.lahun@editec-lotteries.com>
MIME-Version: 1.0
Subject: limit for number of processes
References: <200104121659.f3CGxX714605@tuttle.kansas.net>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

hello.
Yesterday when i wrote program which use fork for every connection, and
made stupid mistake. So i tested my PC(kernel 2.4.3-pre2+xfs) with 
something like
while(1){
fork();
}
i had ulimit 4000 processes  but my box became completely unresponsible 
in X.
As i understood it started to use swap intensively . But amount of 
memory was enough
so no OOM killing. The only thing i could do is to reboot.
After testing  i found that if i create up to 3200 processes i still can 
Ctrl-C  and everything
will be good. If i have more i can kill them but  kernel threads , as i 
understand, continue
to thrash system and the only thing i can do Sys-Rq. 
So my question is , what is amount of processes kernel can support (if  
i have enough memory)
without  thrashing  my system  and requiring reboot for  normal job.
Thank you.
Andrei.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
