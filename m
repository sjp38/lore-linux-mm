Date: Thu, 30 Jan 2003 03:03:59 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Linus rollup
Message-ID: <20030130020359.GV1237@dualathlon.random>
References: <20030129022617.62800a6e.akpm@digeo.com> <1043879752.10150.387.camel@dell_ss3.pdx.osdl.net> <20030129151206.269290ff.akpm@digeo.com> <20030129.163034.130834202.davem@redhat.com> <20030129172743.1e11d566.akpm@digeo.com> <20030130013522.GP1237@dualathlon.random> <20030129180054.03ac0d48.akpm@digeo.com> <3E3884DA.9060600@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3E3884DA.9060600@pobox.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jgarzik@pobox.com>
Cc: Andrew Morton <akpm@digeo.com>, davem@redhat.com, shemminger@osdl.org, rmk@arm.linux.org.uk, ak@muc.de, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org, rth@twiddle.net
List-ID: <linux-mm.kvack.org>

On Wed, Jan 29, 2003 at 08:50:18PM -0500, Jeff Garzik wrote:
> Andrew Morton wrote:
> >#ifndef __LINUX_FRLOCK_H
> >#define __LINUX_FRLOCK_H
> >
> >/*
> > * Fast read-write spinlocks.
> 
> 
> Can we please pick a unique name whose meaning will not change over 
> time?  Even "andre[wa]_rw_lock" would be better, because its meaning is 

I was the first to use it in practice in linux for gettimeofday in the
x86-64 port, but it should be called "keith_owens_lock" if really you
like to use the inventor name. I was trying to find this kind of
readonly read-side lock while designing the vgettimeofday the first time
it was discussed ever on l-k a few years back (way before it seen the
light of the day), and during such discussion Keith shown me the light,
so it wouldn't be fair to take credit for it ;). If you search l-k
probably in y2k or near you should find that email from Keith in answer
to me.

> not tied to performance at this specific point in time, on today's ia32 
> flavor-of-the-month.
> 
> If we discover even-yet-faster read-write spinlocks tomorrow, this name 
> is going to become a joke :)

it would become historical, like so many other things. Actually when
they say frlock I don't even think at fast read lock, I think at frlock
as a specific new name, so personally I'm fine either ways. I don't
dislike it, it's not worse than the big reader lock name that should be
replaced by RCU at large btw.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
