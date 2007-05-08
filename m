Date: Tue, 8 May 2007 12:54:11 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [RFC][PATCH] VM: per-user overcommit policy
Message-ID: <20070508125411.07de2340@the-village.bc.nu>
In-Reply-To: <463FACF9.2080301@users.sourceforge.net>
References: <463F764E.5050009@users.sourceforge.net>
	<20070507212322.6d60210b@the-village.bc.nu>
	<463FACF9.2080301@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: righiandr@users.sourceforge.net
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> When $VERY_CRITICAL_DAEMON dies *all* the users blame the sysadmin [me]. If a
> user application dies because a malloc() returns NULL, the sysadmin [I] can
> blame the user saying: "hey! _you_ tried to hog the machine and _your_
> application is not able to handle the NULL result of the malloc()s!"... :-)

If you allow overcommit by the daemons and not user space then some of
the time you will still get out of memory kills which may well hit your
daemon process.

> A solution could be to define the critical processes unkillable via
> /proc/<pid>/oom_adj, but the per-process approach doesn't resolve all the
> possible cases and it's quite difficult to manage in big environments, like HPC
> clusters.

If you are running no overcommit you should never get an out of memory
kill.

> Anyway, it seems that I need to deepen my knowledge about the recent development
> of process containers and openvz...

I think that does what you need - you'd create containers for critical
services and for the users and split resources to protect one from the
other.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
