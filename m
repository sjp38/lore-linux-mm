Subject: Re: [RFC] Enabling other oom schemes
From: Robert Love <rml@tech9.net>
In-Reply-To: <20030913174825.GB7404@mail.jlokier.co.uk>
References: <200309120219.h8C2JANc004514@penguin.co.intel.com>
	 <20030913174825.GB7404@mail.jlokier.co.uk>
Content-Type: text/plain
Message-Id: <1063476152.24473.30.camel@localhost>
Mime-Version: 1.0
Date: Sat, 13 Sep 2003 16:52:56 -0400
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie@shareable.org>
Cc: rusty@linux.co.intel.com, riel@conectiva.com.br, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 2003-09-13 at 13:48, Jamie Lokier wrote:

> Also, when the OOM condition is triggered I'd like the system to
> reboot, but first try for a short while to unmount filesystems cleanly.
> 
> Any chance of those things?

I like all of these ideas.

One thing to keep in mind is that during a real OOM condition, we cannot
allocate _any_ memory.  None. Zilch.

And that makes some things very hard.  When we start getting into things
such as complicated policies that kill nonessential services first, et
cetera... there comes a time where a lot of communication is needed
(probably with user-space).  Hard to do that with no memory.

I do like all of this, however, and want to see some different OOM
killers.

	Robert Love


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
