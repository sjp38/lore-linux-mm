Date: Wed, 14 Dec 2005 13:01:52 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC][PATCH 0/6] Critical Page Pool
Message-ID: <20051214120152.GB5270@opteron.random>
References: <439FCECA.3060909@us.ibm.com> <20051214100841.GA18381@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051214100841.GA18381@elf.ucw.cz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@suse.cz>
Cc: Matthew Dobson <colpatch@us.ibm.com>, linux-kernel@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 14, 2005 at 11:08:41AM +0100, Pavel Machek wrote:
> because reserved memory pool would have to be "sum of all network
> interface bandwidths * ammount of time expected to survive without
> network" which is way too much.

Yes, a global pool isn't really useful. A per-subsystem pool would be
more reasonable...

> gigabytes into your machine. But don't go introducing infrastructure
> that _can't_ be used right.

Agreed, the current design of the patch can't be used right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
