Date: Wed, 27 Sep 2000 12:25:44 -0600
From: Erik Andersen <andersen@codepoet.org>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
Message-ID: <20000927122544.B10583@codepoet.org>
Reply-To: andersen@codepoet.org
References: <20000925213242.A30832@athlon.random> <20000925205457.Y2615@redhat.com> <qwwd7hriqxs.fsf@sap.com> <20000926160554.B13832@athlon.random> <qww7l7z86qo.fsf@sap.com> <20000926191027.A16692@athlon.random> <qwwn1gu6yps.fsf@sap.com> <20000927155608.D27898@athlon.random> <qwwsnql6aet.fsf@sap.com> <20000927194200.A15943@athlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000927194200.A15943@athlon.random>; from andrea@suse.de on Wed, Sep 27, 2000 at 07:42:00PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed Sep 27, 2000 at 07:42:00PM +0200, Andrea Arcangeli wrote:
> 
> You should of course poll the /proc/meminfo. (/proc/meminfo works in O(1) in
> 2.4.x so it's just the overhead of a read syscall)

Or sysinfo(2).  Same thing...

 -Erik

--
Erik B. Andersen   email:  andersee@debian.org
--This message was written using 73% post-consumer electrons--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
