Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id LAA06403
	for <linux-mm@kvack.org>; Fri, 7 Feb 2003 11:52:36 -0800 (PST)
Date: Fri, 7 Feb 2003 11:52:37 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.59-mm9
Message-Id: <20030207115237.7f58e69e.akpm@digeo.com>
In-Reply-To: <20030207141114.GA31151@nevyn.them.org>
References: <20030207013921.0594df03.akpm@digeo.com>
	<20030207030350.728b4618.akpm@digeo.com>
	<20030207141114.GA31151@nevyn.them.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Jacobowitz <dan@debian.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

Daniel Jacobowitz <dan@debian.org> wrote:
>
> On Fri, Feb 07, 2003 at 03:03:50AM -0800, Andrew Morton wrote:
> > Andrew Morton <akpm@digeo.com> wrote:
> > >
> > > http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.59/2.5.59-mm9/
> > 
> > I've taken this down.
> > 
> > Ingo, there's something bad in the signal changes in Linus's current tree.
> > 
> > mozilla won't display, and is unkillable:
> 
> Yeah, I'm seeing hangs in rt_sigsuspend under GDB also.  Thanks for
> saying that they show up without ptrace; I hadn't been able to
> reproduce them without it.
> 
> Something is causing realtime signals to drop.

OK.  Looks like Linus is hot on the trail.

BTW, some nice people have been sending in smalldevfs testing results
(successful).  I've put that patch back up at

http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.59/smalldevfs.patch

for other testers.  It applies to 2.5.59 base.

And it is not clear why I copied Ingo on the signal thing, when it is not he
who is working that code.  Sorry about that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
