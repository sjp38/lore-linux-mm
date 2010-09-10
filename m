Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 90B026B0098
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 04:39:52 -0400 (EDT)
Subject: Re: [PATCH 08/43] memblock/microblaze: Use new accessors
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20100909115445.GB16157@elte.hu>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
	 <1281071724-28740-9-git-send-email-benh@kernel.crashing.org>
	 <4C5BCD41.3040501@monstr.eu> <1281135046.2168.40.camel@pasglop>
	 <4C88BD8F.5080208@monstr.eu>  <20100909115445.GB16157@elte.hu>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 10 Sep 2010 18:18:31 +1000
Message-ID: <1284106711.6515.46.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Michal Simek <monstr@monstr.eu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, "H. Peter Anvin" <hpa@zytor.com>, Yinghai Lu <yinghai@kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-09-09 at 13:54 +0200, Ingo Molnar wrote:
> * Michal Simek <monstr@monstr.eu> wrote:
> 
> > Benjamin Herrenschmidt wrote:
> > >On Fri, 2010-08-06 at 10:52 +0200, Michal Simek wrote:
> > >>Benjamin Herrenschmidt wrote:
> > >>>CC: Michal Simek <monstr@monstr.eu>
> > >>>Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> > >>This patch remove bug which I reported but there is another
> > >>place which needs to be changed.
> > >>
> > >>I am not sure if my patch is correct but at least point you on
> > >>places which is causing compilation errors.
> > >>
> > >>I tested your memblock branch with this fix and microblaze can boot.
> > >
> > >Ok, that's missing in my initial rename patch. I'll fix it up. Thanks.
> > >
> > >Cheers,
> > >Ben.
> > 
> > I don't know why but this unfixed old patch is in linux-next today.
> 
> Yep, i asked benh to have a look (see the mail below) but got no 
> response, as i assumed it had all been taken care of.

Sorry, I must have been confused... I had pushed out a git branch a
while back with those updates and the ARM bits, at least I think I
did :-) I might have FAILed there. I'll check next week, I'm about to
board on a plane right now.

Cheers,
Ben.

> Ben, Peter?
> 
> 	Ingo
> 
> ----- Forwarded message from Ingo Molnar <mingo@elte.hu> -----
> 
> Date: Tue, 31 Aug 2010 09:29:47 +0200
> From: Ingo Molnar <mingo@elte.hu>
> To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: linux-kernel@vger.kernel.org, mingo@redhat.com, hpa@zytor.com,
> 	tglx@linutronix.de, linux-tip-commits@vger.kernel.org
> Subject: Re: [tip:core/memblock] memblock: Rename memblock_region to
> 	memblock_type and memblock_property to memblock_region
> 
> 
> * Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
> 
> > On Sat, 2010-08-28 at 00:37 +0000, tip-bot for Benjamin Herrenschmidt
> > wrote:
> > > Commit-ID:  e3239ff92a17976ac5d26fa0fe40ef3a9daf2523
> > > Gitweb:     http://git.kernel.org/tip/e3239ff92a17976ac5d26fa0fe40ef3a9daf2523
> > > Author:     Benjamin Herrenschmidt <benh@kernel.crashing.org>
> > > AuthorDate: Wed, 4 Aug 2010 14:06:41 +1000
> > > Committer:  Benjamin Herrenschmidt <benh@kernel.crashing.org>
> > > CommitDate: Wed, 4 Aug 2010 14:21:49 +1000
> > > 
> > > memblock: Rename memblock_region to memblock_type and memblock_property to memblock_region
> > 
> > He, I was just about to rebase them :-)
> > 
> > Do you still need me to do that ?
> 
> Btw., because this is an older base, before we can push this to 
> linux-next i suspect we'll need fixes for those architectures that did a 
> memblock conversion in this cycle?
> 
> Thanks,
> 
> 	Ingo
> 	
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
