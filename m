Subject: Re: [PATCH] radix-tree pagecache for 2.4.19-pre2-ac2
From: Robert Love <rml@tech9.net>
In-Reply-To: <20020304051310.GC1459@matchmail.com>
References: <20020303210346.A8329@caldera.de>
	<20020304045557.C1010BA9E@oscar.casa.dyndns.org>
	<20020304051310.GC1459@matchmail.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 04 Mar 2002 15:31:52 -0500
Message-Id: <1015273914.15479.127.camel@phantasy>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Fedyk <mfedyk@matchmail.com>
Cc: Ed Tomlinson <tomlins@cam.org>, Christoph Hellwig <hch@caldera.de>, reiserfs-list@namesys.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2002-03-04 at 00:13, Mike Fedyk wrote:

> On Sun, Mar 03, 2002 at 11:55:57PM -0500, Ed Tomlinson wrote:
>
> > Got this after a couple of hours with pre2-ac2+preempth+radixtree. 
> 
> Can you try again without preempt?

I've had success with the patch on 2.4.18+preempt and 2.5.5, so I
suspect preemption is not a problem.  I also did not see any
preempt_schedules in his backtrace ...

Ah, someone else just posted another oops on 2.4.19-pre2-ac2 ...

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
