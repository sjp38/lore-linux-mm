Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: [PATCH] Prevent OOM from killing init
Date: Thu, 22 Mar 2001 17:12:52 -0500
References: <20010322142831.A929@owns.warpcore.org> <E14gCYn-0003K3-00@the-village.bc.nu> <20010322230041.A5598@win.tue.nl>
In-Reply-To: <20010322230041.A5598@win.tue.nl>
MIME-Version: 1.0
Message-Id: <01032217125201.06908@oscar>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Guest section DW <dwguest@win.tue.nl>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Stephen Clouse <stephenc@theiqgroup.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thursday 22 March 2001 17:00, Guest section DW wrote:
> On Thu, Mar 22, 2001 at 09:23:54PM +0000, Alan Cox wrote:
> > > Really the whole oom_kill process seems bass-ackwards to me.  I can't
> > > in my mind logically justify annihilating large-VM processes that have
> > > been running for days or weeks instead of just returning ENOMEM to a
> > > process that just started up.
> >
> > How do you return an out of memory error to a C program that is out of
> > memory due to a stack growth fault. There is actually not a language
> > construct for it
>
> Alan, this is a fake argument.
> Linux is bad, and you defend it by saying that it is impossible to be
> perfect.
>
> I have used various Unix flavours for approximately thirty years.
> Stack overflow has not been a real problem. Of course they occurred
> every now and then, but roughly speaking only for unchecked recursion,
> that is, in cases of a program bug.
>
> Presently however, a flawless program can be killed.
> That is what makes Linux unreliable.
>
> > Eventually you have to kill something or the machine deadlocks.
>
> Alan, this is a fake argument.
> When I have a computer algebra system, and it computes millions of
> function values for some expensive function, then it keeps a cache
> of already computed values. Maybe a value is needed again and we
> save ten seconds of computation.
> But of course, when we run out of memory, nothing is easier than
> just throwing this cache out.
>
> You see, the bug is that malloc does not fail. This means that the
> decisions about what to do are not taken by the program that knows
> what it is doing, but by the kernel.

By this arguement the OOM kill code is fine...  If malloc is broken fix it.  
Maybe we need to stage things so that ENOMEM gets returned to requests
before we are totally out of memory.  If the apps ignore the errors then the
kills happen.

Thoughts?
Ed Tomlinson
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
