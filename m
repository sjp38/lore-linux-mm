Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id D463738C23
	for <linux-mm@kvack.org>; Sun, 10 Jun 2001 05:43:37 -0300 (EST)
Date: Sun, 10 Jun 2001 05:43:37 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: RE: [PATCH] 2.4.6-pre2 page_launder() improvements
In-Reply-To: <CHEKKPICCNOGICGMDODJMEJLDEAA.george@gator.com>
Message-ID: <Pine.LNX.4.33.0106100541200.1742-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: George Bonser <george@gator.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 10 Jun 2001, George Bonser wrote:

> I took it out of the load balancer and regained control in
> seconds. The 15 minute load average showed somewhere over 150
> with a bazillion apache processes. Even top -q would not update
> when I put it back into the balancer. The load average and
> number of processes started to increase until I got to some
> point where it would just stop providing output. Again, control
> returned within seconds after taking it out of the balancer. As
> far as I could tell, I never at any time got more than 100MB
> into swap.

OK, I guess it's just thrashing.  Having 64MB of RAM with
250 Apache processes will give you about 256kB per Apache
process ... minus page table, TCP, etc... overhead.

That sounds like the machine just gets a working set
larger than the amount of available memory. It should
work better with eg. 96, 128 or more MBs of memory.

regards,

Rik
--
Linux MM bugzilla: http://linux-mm.org/bugzilla.shtml

Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
