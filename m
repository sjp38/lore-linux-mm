Subject: Re: Linus rollup
From: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030130020359.GV1237@dualathlon.random>
References: <20030129022617.62800a6e.akpm@digeo.com>
	 <1043879752.10150.387.camel@dell_ss3.pdx.osdl.net>
	 <20030129151206.269290ff.akpm@digeo.com>
	 <20030129.163034.130834202.davem@redhat.com>
	 <20030129172743.1e11d566.akpm@digeo.com>
	 <20030130013522.GP1237@dualathlon.random>
	 <20030129180054.03ac0d48.akpm@digeo.com> <3E3884DA.9060600@pobox.com>
	 <20030130020359.GV1237@dualathlon.random>
Content-Type: text/plain
Message-Id: <1043946568.10155.583.camel@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Date: 30 Jan 2003 09:09:28 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@digeo.com>, David Miller <davem@redhat.com>, rmk@arm.linux.org.uk, ak@muc.de, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org, rth@twiddle.net
List-ID: <linux-mm.kvack.org>

> > not tied to performance at this specific point in time, on today's ia32 
> > flavor-of-the-month.
> > 
> > If we discover even-yet-faster read-write spinlocks tomorrow, this name 
> > is going to become a joke :)
> 
> it would become historical, like so many other things. Actually when
> they say frlock I don't even think at fast read lock, I think at frlock
> as a specific new name, so personally I'm fine either ways. I don't
> dislike it, it's not worse than the big reader lock name that should be
> replaced by RCU at large btw.

Don't read too much into the name.  It was just a 30 second effort.
Just didn't want a name like:
 ThingToDoReadConsitentDataUsingSequenceNumbers

So if there is a standard or better name in a reasonable length,
then let's change it.  Marketing always changes the name of everything
prior to release anyway ;-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
