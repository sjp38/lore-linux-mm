In-reply-to: <20070307012638.793d9a9f.akpm@linux-foundation.org> (message from
	Andrew Morton on Wed, 7 Mar 2007 01:26:38 -0800)
Subject: Re: [patch 4/6] mm: merge populate and nopage into fault (fixes
 nonlinear)
References: <20070221023656.6306.246.sendpatchset@linux.site>
	<20070221023735.6306.83373.sendpatchset@linux.site>
	<20070306225101.f393632c.akpm@linux-foundation.org>
	<20070307070853.GB15877@wotan.suse.de>
	<20070307081948.GA9563@wotan.suse.de>
	<20070307082755.GA25733@elte.hu>
	<E1HOrfO-0008AW-00@dorka.pomaz.szeredi.hu>
	<20070307004709.432ddf97.akpm@linux-foundation.org>
	<E1HOrsL-0008Dv-00@dorka.pomaz.szeredi.hu>
	<20070307010756.b31c8190.akpm@linux-foundation.org>
	<20070307091823.GA8609@wotan.suse.de> <20070307012638.793d9a9f.akpm@linux-foundation.org>
Message-Id: <E1HOsS7-0008Ky-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 07 Mar 2007 10:28:55 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: npiggin@suse.de, miklos@szeredi.hu, mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

> > But I think we discovered that those msync changes are bogus anyway
> > becuase there is a small race window where pte could be dirtied without
> > page being set dirty?
> 
> Dunno, I don't recall that.  We dirty the page before the pte...

That's the one I just submitted a fix for ;)

  http://lkml.org/lkml/2007/3/6/308

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
