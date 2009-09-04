Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9ADD06B004F
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 03:34:06 -0400 (EDT)
Date: Fri, 4 Sep 2009 09:33:55 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] x86: reuse the boot-time mappings of fixed_addresses
Message-ID: <20090904073355.GA20598@elte.hu>
References: <4A90AADE.20307@gmail.com> <20090829110046.GA6812@elte.hu> <4A997088.60908@zytor.com> <20090831082632.GB15619@elte.hu> <4A9C6ADF.2020707@goop.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A9C6ADF.2020707@goop.org>
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Xiao Guangrong <ericxiao.gr@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rusty Russell <rusty@rustcorp.com.au>, Jens Axboe <jens.axboe@oracle.com>, Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>


* Jeremy Fitzhardinge <jeremy@goop.org> wrote:

> On 08/31/09 01:26, Ingo Molnar wrote:
> >>> I'm wondering, how much space do we save this way, on a typical bootup 
> >>> on a typical PC?
> >>>
> >>>       
> >> Not a huge lot... a few dozen pages.
> >>     
> > I guess it's still worth doing - what do you think?
> >   
> 
> It hardly seems worth it, but I guess it isn't much code. [...]

Ok, i understood this as an Acked-by from you - lemme know if that's 
wrong ;-)

> [...]  Will having an apparent overlap of vmalloc and fixmap 
> spaces confuse anything?

At most perhaps some debug tools - kcrash & co.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
