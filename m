Received: from vampire.xinit.se (root@vampire.xinit.se [194.14.168.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id DAA31671
	for <linux-mm@kvack.org>; Fri, 15 Jan 1999 03:07:25 -0500
Message-ID: <34BD0786.93EEC074@xinit.se>
Date: Wed, 14 Jan 1998 19:44:22 +0100
From: Hans Eric =?iso-8859-1?Q?Sandstr=F6m?= <hes@xinit.se>
MIME-Version: 1.0
Subject: Re: Alpha quality write out daemon
References: <m1g19ep3p9.fsf@flinx.ccr.net> <m1iue96lhl.fsf@flinx.ccr.net>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


"Eric W. Biederman" wrote:

> >>>>> "EB" == Eric W Biederman <ebiederm> writes:
>
> EB> Please take a look.  If it really is my fault shoot me.
> Darn. It was me.

I for one like the concept. So I won't shoot you.

Just hope everyone else thinks the same (especially the ones that took the Gnus' with guns
course in Atlanta) :-)

But I would really like to have some trashing control here. Maybe this could be controlled
at a higher level. This daemon is currently run each 30 seconds. Could this be prolonged if
the system currently is doing heavy IO. Or could the daemon itself skip runs if the IO load
is to high.

Hans Eric


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
