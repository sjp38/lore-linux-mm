Message-ID: <418DEA55.2080202@gmx.net>
Date: Sun, 07 Nov 2004 10:26:45 +0100
From: Marko Macek <marko.macek@gmx.net>
MIME-Version: 1.0
Subject: Re: [PATCH] Remove OOM killer ...
References: <20041105200118.GA20321@logos.cnet> <20041106125317.GB9144@pclin040.win.tue.nl>
In-Reply-To: <20041106125317.GB9144@pclin040.win.tue.nl>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andries Brouwer <aebr@win.tue.nl>
Cc: Andrew Morton <akpm@osdl.org>, Nick Piggin <piggin@cyberone.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andries Brouwer wrote:

> I have always been surprised that so few people investigated
> doing things right, that is, entirely without OOM killer.

Agreed.

> This is not in a state such that I would like to submit it,
> but I think it would be good to focus some energy into
> offering a Linux that is guaranteed free of OOM surprises.

A good thing would be to make the OOM killer only kill
processes that actually overcommit (independant of overcommit mode).

The first step would be adding a value in /proc/$pid/...
somewhere that shows how much a process is overcommitted when
overcommit is enabled. This would allow important processes to be
fixed for all overcommit modes.


	MArk
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
