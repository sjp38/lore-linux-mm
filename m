Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA31742
	for <linux-mm@kvack.org>; Mon, 20 Apr 1998 18:14:31 -0400
Date: Mon, 20 Apr 1998 23:00:14 +0100
Message-Id: <199804202200.XAA03999@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: new kmod.c - debuggers and testers needed
In-Reply-To: <Pine.LNX.3.91.980414200024.1070J-100000@mirkwood.dummy.home>
References: <199804080001.RAA23780@sun4.apsoft.com>
	<Pine.LNX.3.91.980414200024.1070J-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: H.H.vanRiel@fys.ruu.nl
Cc: Perry Harrington <pedward@sun4.apsoft.com>, linux-kernel@vger.rutgers.edu, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 14 Apr 1998 20:02:09 +0200 (MET DST), Rik van Riel
<H.H.vanRiel@fys.ruu.nl> said:

> On Tue, 7 Apr 1998, Perry Harrington wrote:
>> Threads
>> are useful in their appropriate context, and kswapd, and kmod would benefit
>> from them.

> Hmm, maybe it would be useful for kswapd and bdflush to fork()
> off threads to do the actual disk I/O, so the main thread won't
> be blocked and paused... This could remove some bottlenecks.

bdflush does nothing except IO, so there's no real reason to
twin-thread it.  kswapd does indeed benefit from a separate IO thread,
and I've already got patches which implement a kswiod for IO and a
kswapd for page scanning.  I'll post them once I've got them ready
against the latest kernel: my current patches for this code are pretty
old.

--Stephen
