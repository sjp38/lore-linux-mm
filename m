In-reply-to: <1173262002.6374.128.camel@twins> (message from Peter Zijlstra on
	Wed, 07 Mar 2007 11:06:42 +0100)
Subject: Re: [patch 4/6] mm: merge populate and nopage into fault (fixes
	nonlinear)
References: <20070306225101.f393632c.akpm@linux-foundation.org>
	 <20070307070853.GB15877@wotan.suse.de>
	 <20070307081948.GA9563@wotan.suse.de> <20070307082755.GA25733@elte.hu>
	 <E1HOrfO-0008AW-00@dorka.pomaz.szeredi.hu>
	 <20070307004709.432ddf97.akpm@linux-foundation.org>
	 <E1HOrsL-0008Dv-00@dorka.pomaz.szeredi.hu>
	 <20070307010756.b31c8190.akpm@linux-foundation.org>
	 <1173259942.6374.125.camel@twins> <20070307094503.GD8609@wotan.suse.de>
	 <20070307100430.GA5080@wotan.suse.de> <1173262002.6374.128.camel@twins>
Message-Id: <E1HOt96-0008V6-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 07 Mar 2007 11:13:20 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: npiggin@suse.de, akpm@linux-foundation.org, miklos@szeredi.hu, mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>

> *sigh* yes was looking at all that code, thats gonna be darn slow
> though, but I'll whip up a patch.

Well, if it's going to be darn slow, maybe it's better to go with
mingo's plan on emulating nonlinear vmas with linear ones.  That'll be
darn slow as well, but at least it will be much less complicated.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
