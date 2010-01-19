Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E25756000C5
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 04:14:19 -0500 (EST)
From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [linux-pm] [RFC][PATCH] PM: Force GFP_NOIO during suspend/resume (was: Re: Memory allocations in .suspend became very unreliable)
Date: Tue, 19 Jan 2010 10:15:00 +0100
References: <1263745267.2162.42.camel@barrios-desktop> <20100118111703.AE36.A69D9226@jp.fujitsu.com> <201001182206.36365.rjw@sisk.pl>
In-Reply-To: <201001182206.36365.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <201001191015.00470.oliver@neukum.org>
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Am Montag, 18. Januar 2010 22:06:36 schrieb Rafael J. Wysocki:
> I was concerned about another problem, though, which is what happens if the
> suspend process runs in parallel with a memory allocation that started earlier
> and happens to do some I/O.  I that case the suspend process doesn't know
> about the I/O done by the mm subsystem and may disturb it in principle.

How could this happen? Who would allocate that memory?
Tasks won't be frozen while they are allocating memory.

	Regards
		Oliver

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
