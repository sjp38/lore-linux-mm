Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id E7AEC3948B
	for <linux-mm@kvack.org>; Thu,  9 May 2002 16:08:51 -0300 (EST)
Date: Thu, 9 May 2002 16:08:16 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC][PATCH] IO wait accounting
In-Reply-To: <Pine.LNX.3.96.1020509095715.7914B-100000@gatekeeper.tmr.com>
Message-ID: <Pine.LNX.4.44L.0205091607400.7447-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Davidsen <davidsen@tmr.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 9 May 2002, Bill Davidsen wrote:

> I have been simply counting WaitIO ticks when there is (a) no runable
> process in the system, and (b) at least one process blocked for disk i/o,
> either page or program. And instead of presenting it properly I just
> stuffed it in a variable and read it from kmem.

OK, how did you measure this ?

And should we measure read() waits as well as page faults or
just page faults ?

regards,

Rik
-- 
	http://www.linuxsymposium.org/2002/
"You're one of those condescending OLS attendants"
"Here's a nickle kid.  Go buy yourself a real t-shirt"

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
