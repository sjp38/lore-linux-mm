Received: from list by main.gmane.org with local (Exim 3.35 #1 (Debian))
	id 19Y8Xt-0000CS-00
	for <linux-mm@kvack.org>; Thu, 03 Jul 2003 20:11:01 +0200
From: Pasi Savolainen <psavo@iki.fi>
Subject: Re: 2.5.74-mm1
Date: Thu, 3 Jul 2003 18:11:00 +0000 (UTC)
Message-ID: <be1rjk$nj$1@main.gmane.org>
References: <20030703023714.55d13934.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Andrew Morton <akpm@osdl.org>:
> 
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.74/2.5.74-mm1/
> 

Has -mm had some monotonic clock patches at around 2.5.72-mm3?
2.5.74-mm1 seems to produce non-monotonic gettimeofday.
(tested with http://www.swcp.com/~hudson/gettimeofday.c)
'lag' is sporadic and may take several iterations to come up.


Machine is 2xK7 with a ACPI C2 sleep driver (TSC's get unsynched).
2.5.72-mm3 didn't show these.

-- 
   Psi -- <http://www.iki.fi/pasi.savolainen>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
