Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id JAA21565
	for <linux-mm@kvack.org>; Wed, 16 Oct 2002 09:10:57 -0700 (PDT)
Message-ID: <3DAD8F91.FA93860E@digeo.com>
Date: Wed, 16 Oct 2002 09:10:57 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [patch] mmap-speedup-2.5.42-C3
References: <Pine.LNX.4.44.0210160751260.2181-100000@home.transmeta.com> <1034783351.4287.2.camel@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjanv@fenrus.demon.nl>
Cc: Linus Torvalds <torvalds@transmeta.com>, Ingo Molnar <mingo@elte.hu>, NPT library mailing list <phil-list@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Arjan van de Ven wrote:
> 
> On Wed, 2002-10-16 at 16:52, Linus Torvalds wrote:
> \
> > > i think it should be unrelated to the mmap patch. In any case, Andrew
> > > added the mmap-speedup patch to 2.5.43-mm1, so we'll hear about this
> > > pretty soon.
> >
> > There's at least one Oops-report on linux-kernel on 2.5.43-mm1, where the
> > oops traceback was somewhere in munmap().
> >
> > Sounds like there are bugs there.
> 
> could be the shared pagetable stuff just as well ;(
> 

Yes, Matt had shared pagetables enabled.  That code is not stable yet.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
