Date: Sun, 20 May 2007 18:22:47 -0400
From: Jeff Dike <jdike@addtoit.com>
Subject: Re: signals logged / [RFC] log out-of-virtual-memory events
Message-ID: <20070520222247.GA25276@c2.user-mode-linux.org>
References: <464C9D82.60105@redhat.com> <Pine.LNX.4.61.0705202235430.13923@yvahk01.tjqt.qr> <20070520205500.GJ22452@vanheusden.com> <200705202314.57758.ak@suse.de> <20070520212036.GL22452@vanheusden.com> <20070520222422.GT2012@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070520222422.GT2012@bingen.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Folkert van Heusden <folkert@vanheusden.com>, Jan Engelhardt <jengelh@linux01.gwdg.de>, Stephen Hemminger <shemminger@linux-foundation.org>, Eric Dumazet <dada1@cosmosbay.com>, Rik van Riel <riel@redhat.com>, righiandr@users.sourceforge.net, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 21, 2007 at 12:24:22AM +0200, Andi Kleen wrote:
> > > But I think your list is far too long anyways.
> > 
> > So, which ones would you like to have removed then?
> 
> SIGFPE at least and the accounting signals are dubious too. SIGQUIT can
> be also relatively common.

And SIGSEGV and SIGBUS - UML catches these internally and handles them.

				Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
