Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: kernel: __alloc_pages: 1-order allocation failed
Date: Wed, 29 Aug 2001 20:00:35 +0200
References: <Pine.LNX.4.21.0108271928250.7385-100000@freak.distro.conectiva> <20010829150716Z16100-32383+2280@humbolt.nl.linux.org> <3B8D14E5.7070204@syntegra.com>
In-Reply-To: <3B8D14E5.7070204@syntegra.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Message-Id: <20010829175351Z16158-32383+2308@humbolt.nl.linux.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Kay <Andrew.J.Kay@syntegra.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On August 29, 2001 06:14 pm, Andrew Kay wrote:
> > OK, it's not a bounce buffer because the allocation isn't __GFP_WAIT 
(0x10).
> > It's GFP_ATOMIC and there are several hundred of those throughout the 
kernel so
> > I'm not going to try to guess which one.  Could you please pass a few of 
your
> > backtraces through ksymoops make them meaningful?
> > Daniel
> 
> I'm not sure I did this right, but here is my attempt.  I ran a 
> 'ksymoops' and gave it a couple of the errors.  The parts that look 
> somewhat recognizable are the sk98lin, which is a Syskonnect gig over 
> copper card.  It is the only module I have running on the system.

Close, but see the warning where it tells you your System.map doesn't match 
your running kernel.  Try symlinking /boot/System.map to the System.map in
the source tree you built from.

> Warning: You did not tell me where to find symbol information.  I will
> assume that the log matches the kernel and modules that are running
> right now and I'll use the default options above for symbol resolution.
> If the current kernel and/or modules do not match the log, you can get
> more accurate output by telling me the kernel version and where to find
> map, modules, ksyms etc.  ksymoops -h explains the options.

I'm willing to guess at this point that this atomic failure is not a bug, the 
only bug is that we print the warning message, potentially slowing things 
down.  I'd like to see a correct backtrace first.

Do you detect any slowdown in your system when you're getting these messages? 
I wouldn't expect so from what you've described so far.

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
