Date: Sat, 13 Sep 2003 18:48:25 +0100
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [RFC] Enabling other oom schemes
Message-ID: <20030913174825.GB7404@mail.jlokier.co.uk>
References: <200309120219.h8C2JANc004514@penguin.co.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200309120219.h8C2JANc004514@penguin.co.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: rusty@linux.co.intel.com
Cc: riel@conectiva.com.br, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rusty Lynch wrote:
> Over the years I have encountered various usage needs where the standard
> oom_kill.c version of memory recovery was not the most ideal approach.
> For example, some times it is better to just restart the system and 
> let a front end load balancer hand off the server load to another system.
> Sometimes it might be worth the effort to write a very solution specific
> oom handler.

I would like to reboot a remote server when it is overloaded, or a
deterministic policy that kills off services starting with those
deemed less essential, but what is the best way to detect overload?

IMHO, the server is overloaded when tasks are no longer responding in
a reasonable time, due to excessive paging.

It isn't feasible to work out in advance how much swap this
corresponds to, because it depends how much swap is used by "idle"
pages, and how much is likely to be filled with working sets.

Too much swap, and it won't OOM even while it becomes totally
unresponsive for days and needs a manual reset.  Too little swap, and
valuable RAM is being wasted.

What I'd really like is some way to observe task response times,
and when they become too slow due to excessive paging, trigger the OOM
policy whatever it is.

Also, when the OOM condition is triggered I'd like the system to
reboot, but first try for a short while to unmount filesystems cleanly.

Any chance of those things?

Thanks in advance :)
-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
