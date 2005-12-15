Date: Thu, 15 Dec 2005 17:27:18 +0100
From: Pavel Machek <pavel@suse.cz>
Subject: Re: [RFC][PATCH 0/6] Critical Page Pool
Message-ID: <20051215162717.GK2904@elf.ucw.cz>
References: <439FCECA.3060909@us.ibm.com> <20051214100841.GA18381@elf.ucw.cz> <20051214120152.GB5270@opteron.random> <1134565436.25663.24.camel@localhost.localdomain> <43A04A38.6020403@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <43A04A38.6020403@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrea Arcangeli <andrea@suse.de>, linux-kernel@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi!

> > The whole extra critical level seems dubious in itself. In 2.0/2.2 days
> > there were a set of patches that just dropped incoming memory on sockets
> > when the memory was tight unless they were marked as critical (ie NFS
> > swap). It worked rather well. The rest of the changes beyond that seem
> > excessive.
> 
> Actually, Sridhar's code (mentioned earlier in this thread) *does* drop
> incoming packets that are not 'critical', but unfortunately you need to
> completely copy the packet into kernel memory before you can do any
> processing on it to determine whether or not it's 'critical', and thus
> accept or reject it.  If network traffic is coming in at a good clip and
> the system is already under memory pressure, it's going to be difficult to
> receive all these packets, which was the inspiration for this patchset.

You should be able to do all this with single, MTU-sized buffer.

Receive packet into buffer. If it is nice, pass it up, otherwise drop
it. Yes, it may drop some "important" packets, but that's okay, packet
loss is expected on networks.
								Pavel
-- 
Thanks, Sharp!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
