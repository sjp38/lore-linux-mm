Message-ID: <20010816234639.E755@bug.ucw.cz>
Date: Thu, 16 Aug 2001 23:46:39 +0200
From: Pavel Machek <pavel@suse.cz>
Subject: Re: Swapping for diskless nodes
References: <20010811011329.C55@toy.ucw.cz> <E15Wdla-00018V-00@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <E15Wdla-00018V-00@the-village.bc.nu>; from Alan Cox on Tue, Aug 14, 2001 at 01:57:54PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Bulent Abali <abali@us.ibm.com>, "Dirk W. Steinberg" <dws@dirksteinberg.de>, Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

> The good example of the insoluble end of it is a box with no default route
> doing BGP4 routing with NFS swap. Now thats an extremely daft practical 
> proposition but it illustrates the fact the priority ordering is not known
> to the kernel

I'd call that configuration error. If swap-over-nbd works in all but
such cases, its okay with me.
								Pavel
-- 
I'm pavel@ucw.cz. "In my country we have almost anarchy and I don't care."
Panos Katsaloulis describing me w.r.t. patents at discuss@linmodems.org
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
