Received: from alogconduit1ah.ccr.net (ccr@alogconduit1av.ccr.net [208.130.159.22])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA31335
	for <linux-mm@kvack.org>; Wed, 7 Apr 1999 16:33:37 -0400
Subject: Re: none
References: <199705271336.VAA00397@ns.senbell.com.cn>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 07 Apr 1999 10:09:12 -0500
In-Reply-To: root's message of "Tue, 27 May 1997 21:36:16 +0800"
Message-ID: <m1r9pwwjqf.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: leiyin_linux@163.net
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "leiyin" == root  <root@ns.senbell.com.cn> writes:

leiyin> I am leiyin, a software engineer in china, beijing. I am interested
leiyin> in Linux memory management these day. Since I find an ordinary user
leiyin> can easily occupy all the memory available. Though I don't think this is 
leiyin> a bug. I wonder whether I can control how much memory a user can occup
leiyin> ,including swap space, or not.

yes.

The kernel interface is setrlimit, the user interface is usually
through the shell ulimit command.
The only per user limit I know of is number of processes.
The rest of the limits, stack size, virtual memory size etc, are per processs.

leiyin> Especially in AS400 OS/400 one can distribute a fixed size physical memory
leiyin> (pool) for a subsystem. If Linux can do this( I mean a fixed size memory for
leiyin> a user not subsystem), I think linux will become more lovely.


leiyin> Address:leiyin_linux@163.net
Your might want to set this in your reply to header.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
