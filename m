Date: Thu, 30 Jan 2003 09:15:55 -0800 (PST)
From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: Linus rollup
In-Reply-To: <1043946568.10155.583.camel@dell_ss3.pdx.osdl.net>
Message-ID: <Pine.LNX.4.33L2.0301300914500.4084-100000@dragon.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephen Hemminger <shemminger@osdl.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@digeo.com>, David Miller <davem@redhat.com>, rmk@arm.linux.org.uk, ak@muc.de, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org, rth@twiddle.net
List-ID: <linux-mm.kvack.org>

On 30 Jan 2003, Stephen Hemminger wrote:

| > > not tied to performance at this specific point in time, on today's ia32
| > > flavor-of-the-month.
| > >
| > > If we discover even-yet-faster read-write spinlocks tomorrow, this name
| > > is going to become a joke :)
| >
| > it would become historical, like so many other things. Actually when
| > they say frlock I don't even think at fast read lock, I think at frlock
| > as a specific new name, so personally I'm fine either ways. I don't
| > dislike it, it's not worse than the big reader lock name that should be
| > replaced by RCU at large btw.
|
| Don't read too much into the name.  It was just a 30 second effort.
| Just didn't want a name like:
|  ThingToDoReadConsitentDataUsingSequenceNumbers
|
| So if there is a standard or better name in a reasonable length,
| then let's change it.  Marketing always changes the name of everything
| prior to release anyway ;-)

You can follow Andrea's suggestion and call it a kaos_lock
(for Keith Owens).

-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
