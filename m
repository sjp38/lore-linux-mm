Date: Thu, 30 Jan 2003 03:06:58 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Linus rollup
Message-ID: <20030130020658.GW1237@dualathlon.random>
References: <20030129022617.62800a6e.akpm@digeo.com> <1043879752.10150.387.camel@dell_ss3.pdx.osdl.net> <20030129151206.269290ff.akpm@digeo.com> <20030129.163034.130834202.davem@redhat.com> <20030129172743.1e11d566.akpm@digeo.com> <20030130013522.GP1237@dualathlon.random> <20030129180054.03ac0d48.akpm@digeo.com> <20030129175232.A19969@twiddle.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030129175232.A19969@twiddle.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard Henderson <rth@twiddle.net>
Cc: Andrew Morton <akpm@digeo.com>, davem@redhat.com, shemminger@osdl.org, rmk@arm.linux.org.uk, ak@muc.de, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 29, 2003 at 05:52:32PM -0800, Richard Henderson wrote:
> On Wed, Jan 29, 2003 at 06:00:54PM -0800, Andrew Morton wrote:
> > Andrea Arcangeli <andrea@suse.de> wrote:
> > > if we hold the spinlock, the serialized memory can't be change under us,
> > > so there's no need to put a read barrier, we only care that pre_sequence
> > > is visible before the chagnes are visible and before post_sequence is
> > > visible, hence only wmb() (after spin_lock and pre_sequence++) is
> > > needed there and only rmb() is needed in the read-side.
> 
> Hmm.  Perhaps I was confused about how these things are intended
> to be used.  If indeed the writer doesn't care about the order
> in which pre/post_sequence are accessed, then wmb is sufficient
> to keep their updates ordered.

yep, IMHO it should be enough.

btw, I'm speaking only about the fr_write_lock/unlock, not sure what the
write_begin/end are meant for, there are no fr_write_begin/end in the
patch I was reading (in 2.4). If fr_write_begin/end have to be retained
because they can do something useful, and they don't take the spinlock,
it could be needed there to use mb(), I just have no idea of where
write_begin/end could be useful so it's hard to say.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
