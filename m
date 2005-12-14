Subject: Re: [RFC][PATCH 0/6] Critical Page Pool
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <20051214120152.GB5270@opteron.random>
References: <439FCECA.3060909@us.ibm.com>
	 <20051214100841.GA18381@elf.ucw.cz>  <20051214120152.GB5270@opteron.random>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Wed, 14 Dec 2005 13:03:56 +0000
Message-Id: <1134565436.25663.24.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Pavel Machek <pavel@suse.cz>, Matthew Dobson <colpatch@us.ibm.com>, linux-kernel@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mer, 2005-12-14 at 13:01 +0100, Andrea Arcangeli wrote:
> On Wed, Dec 14, 2005 at 11:08:41AM +0100, Pavel Machek wrote:
> > because reserved memory pool would have to be "sum of all network
> > interface bandwidths * ammount of time expected to survive without
> > network" which is way too much.
> 
> Yes, a global pool isn't really useful. A per-subsystem pool would be
> more reasonable...


The whole extra critical level seems dubious in itself. In 2.0/2.2 days
there were a set of patches that just dropped incoming memory on sockets
when the memory was tight unless they were marked as critical (ie NFS
swap). It worked rather well. The rest of the changes beyond that seem
excessive.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
