From: jbradford@dial.pipex.com
Message-Id: <200210221604.g9MG4Ew7002137@darkstar.example.net>
Subject: Re: running 2.4.2 kernel under 4MB Ram
Date: Tue, 22 Oct 2002 17:04:14 +0100 (BST)
In-Reply-To: <1035333109.2200.2.camel@amol.in.ishoni.com> from "Amol Kumar Lad" at Oct 22, 2002 08:31:43 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Amol Kumar Lad <amolk@ishoni.com>
Cc: alan@lxorguk.ukuu.org.uk, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Tue, 2002-10-22 at 06:06, Alan Cox wrote:
> > On Tue, 2002-10-22 at 19:54, Amol Kumar Lad wrote:
> > > Hi,
> > >  I want to run 2.4.2 kernel on my embedded system that has only 4 Mb
> > > SDRAM . Is it possible ?? Is there any constraint for the minimum
> > SDRAM
> > > requirement for linux 2.4.2
> > 
> > You want to run something a lot newer than 2.4.2. 2.4.19 will run on a
> > 4Mb box, and with Rik's rmap vm seems to be run better than 2.2. That
> > will depend on the workload.
> 
> It means that I _cannot_ run 2.4.2 on a 4MB box. 
> Actually my embedded system already has 2.4.2 running on a 16Mb. I was
> looking for a way to run it in 4Mb. 
> So Is upgrade to 2.4.19 the only option ??

You _should_ be able to run 2.4.2 in 4Mb, but as Alan pointed out,
there is no reason to stick with that old version just because of lack
of memory.  Exactly what problems are you having running 2.4.2 in 4Mb
anyway?  By the way, I am assuming that your embedded system is X86
based.  I have run all of the kernels I mentioned in my previous post
in swapless_ 4Mb on X86.

John.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
