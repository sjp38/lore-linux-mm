Date: Sat, 11 Aug 2001 01:13:29 +0000
From: Pavel Machek <pavel@suse.cz>
Subject: Re: Swapping for diskless nodes
Message-ID: <20010811011329.C55@toy.ucw.cz>
References: <OF452D802E.BE93E657-ON85256AA3.004E8422@pok.ibm.com> <E15UrUl-0007Rn-00@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <E15UrUl-0007Rn-00@the-village.bc.nu>; from alan@lxorguk.ukuu.org.uk on Thu, Aug 09, 2001 at 04:13:11PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Bulent Abali <abali@us.ibm.com>, "Dirk W. Steinberg" <dws@dirksteinberg.de>, Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

> > Last time I checked swapping over nbd required patching the network stack.
> > Because swapping occurs when memory is low and when memory is low TCP
> > doesn't do what you expect it to do...
> 
> Its a case of having sufficient memory in the atomic pools. Its possible to
> do some ugly quick kernel hack to make the pool commit less likely to be a 
> problem.
> 
> Ultimately its an insoluble problem, neither SunOS, Solaris or NetBSD are
> infallible, they just never fail for any normal situation, and thats good
> enough for me as a solution

Oops,  really? And if I can DoS such machine with ping -f (to eat atomic
ram)? And what are you going to tel your users? "It died so reboot"?
								Pavel
-- 
Philips Velo 1: 1"x4"x8", 300gram, 60, 12MB, 40bogomips, linux, mutt,
details at http://atrey.karlin.mff.cuni.cz/~pavel/velo/index.html.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
