Received: from adore.lightlink.com (kimoto@adore.lightlink.com [205.232.34.20])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA30900
	for <linux-mm@kvack.org>; Sun, 21 Jun 1998 16:19:59 -0400
From: Paul Kimoto <kimoto@lightlink.com>
Message-ID: <19980621161940.A18093@adore.lightlink.com>
Date: Sun, 21 Jun 1998 16:19:40 -0400
Subject: Re: update re: fork() failures in 2.1.103
References: <19980618235448.18503@adore.lightlink.com> <Pine.LNX.3.96.980619093210.6052C-100000@mirkwood.dummy.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.3.96.980619093210.6052C-100000@mirkwood.dummy.home>; from Rik van Riel on Fri, Jun 19, 1998 at 09:33:54AM +0200
Sender: owner-linux-mm@kvack.org
To: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

RECAP: In 2.1.99, 2.1.101, 2.1.103, and 2.1.104-pre1, my system has been
usable for only ~1 day with 32 MB of memory, or ~2.5 days with 48 MB.
Then my system has trouble forking, typically with EAGAIN.  The situation
can be alleviated temporarily by killing off a few processes, but the
errors always reappear soon thereafter.  I have sent in the results of
Shift-ScrollLock, which Rik thinks are not typical of excessive memory
fragmentation.

Now, I have scripts that run "ifconfig ppp0" hourly (to check whether PPP
is "UP").  Recently I joined the modern era by changing from net-tools
1.432 to 1.45.  The forking errors have gone away (at least for uptimes
twice the above).  When I changed these scripts to run "/sbin/ifconfig.old
ppp0" instead, they came back.

Running the old ifconfig (when the problem arises) would put "kmod: fork
failed, errno 11" messages in the logfiles.  The new ifconfig doesn't.
Running strace on "ifconfig ppp0" shows that the old version makes the
following system calls that the new one doesn't:

> socket(PF_??? (0x4), SOCK_DGRAM, , 0)   = -1 ENOSYS (Function not implemented)
> socket(PF_??? (0x4), SOCK_DGRAM, , 0)   = -1 ENOSYS (Function not implemented)
> socket(PF_??? (0x4), SOCK_DGRAM, , 0)   = -1 EINVAL (Invalid argument)
> socket(PF_??? (0x3), SOCK_DGRAM, , 0)   = -1 ENOSYS (Function not implemented)
> socket(PF_??? (0x3), SOCK_DGRAM, , 0)   = -1 ENOSYS (Function not implemented)
> socket(PF_??? (0x3), SOCK_DGRAM, , 0)   = -1 EINVAL (Invalid argument) 
> socket(PF_??? (0x5), SOCK_DGRAM, , 0)   = -1 ENOSYS (Function not implemented)
> socket(PF_??? (0x5), SOCK_DGRAM, , 0)   = -1 ENOSYS (Function not implemented)
> socket(PF_??? (0x5), SOCK_DGRAM, , 0)   = -1 EINVAL (Invalid argument)

(I am not sure whether these system calls have been taken out of the 
new ifconfig, or whether I merely configured net-tools to be ignorant
of appletalk, etc.)

Something about my old ifconfig must be triggering a bug (or hardware
error?) somewhere.  I am willing to take further suggestions for
experiments to try, if anyone is still interested.

	-Paul <kimoto@lightlink.com>
	 (please cc: relevant messages to me)
