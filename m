Date: Sat, 19 May 2001 01:35:44 +0200
From: =?iso-8859-1?Q?Thomas_Lang=E5s?= <tlan@stud.ntnu.no>
Subject: Re: SMP/highmem problem
Message-ID: <20010519013544.A21549@flodhest.stud.ntnu.no>
Reply-To: tlan@stud.ntnu.no
References: <20010517203933.F6360@vestdata.no> <Pine.LNX.4.21.0105171612030.5531-100000@imladris.rielhome.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0105171612030.5531-100000@imladris.rielhome.conectiva>; from riel@conectiva.com.br on Thu, May 17, 2001 at 04:19:35PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: =?iso-8859-1?Q?Ragnar_Kj=F8rstad?= <kernel@ragnark.vestdata.no>, linux-mm@kvack.org, tlan@stud.ntnu.no
List-ID: <linux-mm.kvack.org>

Rik van Riel:
> A few fixes for this situation have gone into 2.4.5-pre2 and
> 2.4.5-pre3. If you have the time, could you test if this problem
> has gotten less or has gone away in the latest kernels ?

Ok, now we've tested 2.4.5-pre3, and it's still like described before.
However, it's a bit better. 

We started bonnie++, and waited a few secs, then tested with ls'ing uncached
catalogs on /-filesystem. This was a command that took about 1m real time,
to do every time earlier (2.4.4). Now it only takes 1m real time when ls
isn't cached or hashed. This goes for every other command. However, after we
waited a few mins. the box started to become unsuable again (sshd-sessions
lagged, for instance). Killing bonnie++ fixes the situation after a little
while (1-3mins).

So, any other ideas are very welcome :)

-- 
-Thomas
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
