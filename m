Date: Sat, 26 Apr 2003 06:34:07 -0400 (EDT)
From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: 2.5.68-mm2
In-Reply-To: <1051295252.9767.143.camel@localhost>
Message-ID: <Pine.LNX.3.96.1030426062917.20200A-100000@gatekeeper.tmr.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: "Randy.Dunlap" <rddunlap@osdl.org>, bcrl@redhat.com, akpm@digeo.com, mbligh@aracnet.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 25 Apr 2003, Robert Love wrote:

> On Fri, 2003-04-25 at 14:20, Randy.Dunlap wrote:
> >  
> > | The point is that even if bash is fixed it's desirable to address the
> > | issue in the kernel, other applications may well misbehave as well.
> > 
> > So when would this ever end?
> 
> Exactly what I was thinking.
> 
> The kernel cannot be expected to cater to applications or make
> concessions (read: hacks) for certain behavior.  If we offer a cleaner,
> improved interface which offers the performance improvement, we are
> done.  Applications need to start using it.
> 
> Of course, I am not arguing against optimizing the old interfaces or
> anything of that nature.  I just believe we should not introduce hacks
> for application behavior.  It is their job to do the right thing.

I don't care much if the kernel does something to make an application run
better, that's an application problem. But if an application can do
something which hurts the performance of the system as a whole, then the
kernel should protect itself and the rest of the system.

So I'm not advocating that the kernel cater to bash, just that doing
legitimate things with bash not have a disproportionate impact on the rest
of the system.

-- 
bill davidsen <davidsen@tmr.com>
  CTO, TMR Associates, Inc
Doing interesting things with little computers since 1979.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
