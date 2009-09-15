Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9B8B36B004F
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 11:30:09 -0400 (EDT)
Date: Tue, 15 Sep 2009 08:26:41 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 2/4] virtual block device driver (ramzswap)
Message-ID: <20090915152641.GA22667@kroah.com>
References: <200909100215.36350.ngupta@vflare.org>
 <200909100249.26284.ngupta@vflare.org>
 <84144f020909141310y164b2d1ak44dd6945d35e6ec@mail.gmail.com>
 <d760cf2d0909142339i30d74a9dic7ece86e7227c2e2@mail.gmail.com>
 <84144f020909150030h1f9d8062sc39057b55a7ba6c0@mail.gmail.com>
 <d760cf2d0909150121i7f6f45b9p76f8eb89ab0d5882@mail.gmail.com>
 <84144f020909150130r573df1e1jfe359b88387f94ad@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f020909150130r573df1e1jfe359b88387f94ad@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Ed Tomlinson <edt@aei.ca>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org, Ingo Molnar <mingo@elte.hu>, =?iso-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 15, 2009 at 11:30:16AM +0300, Pekka Enberg wrote:
> Btw, Nitin, why are you targeting drivers/block and not
> drivers/staging at this point? It seems obvious enough that there are
> still some issues that need to be ironed out (like the CONFIG_ARM
> thing) so submitting the driver for inclusion in drivers/staging and
> fixing it up there incrementally would likely save you from a lot of
> trouble. Greg, does ramzswap sound like something that you'd be
> willing to take?

If it is self-contained, actually builds, and there is an active
developer who is working getting it merged into the main kernel tree,
then yes, I will be willing to take it into the drivers/staging/ tree.
Just send me the patches.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
