Date: Mon, 4 Mar 2002 21:35:22 +0100
From: Christoph Hellwig <hch@caldera.de>
Subject: Re: [PATCH] radix-tree pagecache for 2.4.19-pre2-ac2
Message-ID: <20020304213522.A318@caldera.de>
References: <20020303210346.A8329@caldera.de> <20020304045557.C1010BA9E@oscar.casa.dyndns.org> <20020304051310.GC1459@matchmail.com> <1015273914.15479.127.camel@phantasy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1015273914.15479.127.camel@phantasy>; from rml@tech9.net on Mon, Mar 04, 2002 at 03:31:52PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: Mike Fedyk <mfedyk@matchmail.com>, Ed Tomlinson <tomlins@cam.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 04, 2002 at 03:31:52PM -0500, Robert Love wrote:
> On Mon, 2002-03-04 at 00:13, Mike Fedyk wrote:
> 
> > On Sun, Mar 03, 2002 at 11:55:57PM -0500, Ed Tomlinson wrote:
> >
> > > Got this after a couple of hours with pre2-ac2+preempth+radixtree. 
> > 
> > Can you try again without preempt?
> 
> I've had success with the patch on 2.4.18+preempt and 2.5.5, so I
> suspect preemption is not a problem.  I also did not see any
> preempt_schedules in his backtrace ...

I can repdoduce it locally here.  IT looks like we leak a pgae with
incorrect flags in an error path.  Still investigating it.

	Christoph

-- 
Of course it doesn't work. We've performed a software upgrade.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
