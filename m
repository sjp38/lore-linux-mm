Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id E5ABA394B9
	for <linux-mm@kvack.org>; Wed, 18 Sep 2002 16:40:05 -0300 (EST)
Date: Wed, 18 Sep 2002 16:39:48 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] recognize MAP_LOCKED in mmap() call
In-Reply-To: <OFC0C42F8D.E1325D58-ON86256C38.00695CD8@hou.us.ray.com>
Message-ID: <Pine.LNX.4.44L.0209181639260.1519-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark_H_Johnson@raytheon.com
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 18 Sep 2002 Mark_H_Johnson@raytheon.com wrote:
> Andrew Morton wrote:
> >(SuS really only anticipates that mmap needs to look at prior mlocks
> >in force against the address range.  It also says
> >
> >     Process memory locking does apply to shared memory regions,
> >
> >and we don't do that either.  I think we should; can't see why SuS
> >requires this.)
>
> Let me make sure I read what you said correctly. Does this mean that
> Linux 2.4 (or 2.5) kernels do not lock shared memory regions if a
> process uses mlockall?

But it does.  Linux won't evict memory that's MLOCKed...

cheers,

Rik
-- 
Spamtrap of the month: september@surriel.com

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
