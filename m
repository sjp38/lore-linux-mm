Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A23BA6B005D
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 15:18:34 -0500 (EST)
Date: Thu, 1 Dec 2011 21:18:27 +0100
From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>
Subject: Re: flatmem broken for nommu? [Was: Re: does non-continuous RAM
 means I need to select the sparse memory model?]
Message-ID: <20111201201827.GN26618@pengutronix.de>
References: <20111129203010.GA26618@pengutronix.de>
 <CAOMZO5DX_ZvCOu+pqZpJ7Ni2B=qmSFCZTHnuzKt==OsBsJZH=Q@mail.gmail.com>
 <20111201105718.GJ26618@pengutronix.de>
 <20111201153933.GL26618@pengutronix.de>
 <4ED7A6EF.1000705@the2masters.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4ED7A6EF.1000705@the2masters.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Hellermann <stefan@the2masters.de>
Cc: linux-mm@kvack.org, Yinghai Lu <yinghai@kernel.org>, akpm@linux-foundation.org, linux-arm-kernel@lists.infradead.org

Hello Stefan,

On Thu, Dec 01, 2011 at 05:10:23PM +0100, Stefan Hellermann wrote:
> Am 01.12.2011 16:39, schrieb Uwe Kleine-Konig:
> > The problem is that the memory for mem_map is allocated using:
> > 
> > 	map = alloc_bootmem_node_nopanic(pgdat, size);
> > 
> > without any error checking. The _nopanic was introduced by commit
> > 
> > 	8f389a99 (mm: use alloc_bootmem_node_nopanic() on really needed path)
> > 
> > I don't understand the commit's log and don't really see why it should
> > be allowed to not panic if the allocation failes here but use a NULL
> > pointer instead.
> > I put the people involved in 8f389a99 on Cc, maybe someone can comment?
> > 
> > Apart from that it seems I cannot use flatmem as is on my machine. It
> > has only 128kiB@0x10000000 + 1MiB@0x80000000 and needs 14MiB to hold the
> > table of "struct page"s. :-(
> > 
> > Best regards
> > Uwe
> > 
> The commit was made after an bug report from me. I have an old x86
> tablet pc with only 8Mb Ram. This machine fails early on bootup without
> this commit. I found an archived message of the bug report here:
> http://comments.gmane.org/gmane.linux.kernel/1135909
I saw that, too, but still I think that at least the last hunk in this
patch is wrong. (I didn't check the others.) For me the allocation for
mem_map failed and instead of handling the error somehow (be it a panic
or not) just using NULL isn't nice.

Best regards
Uwe

-- 
Pengutronix e.K.                           | Uwe Kleine-Konig            |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
