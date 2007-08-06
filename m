In-reply-to: <20070803123712.987126000@chello.nl> (message from Peter Zijlstra
	on Fri, 03 Aug 2007 14:37:13 +0200)
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
References: <20070803123712.987126000@chello.nl>
Message-Id: <E1II99f-0005mv-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 06 Aug 2007 22:26:19 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> Per device dirty throttling patches

Andrew, may I inquire about your plans with this?

> These patches aim to improve balance_dirty_pages() and directly address three
> issues:
>   1) inter device starvation
>   2) stacked device deadlocks

This one interests me most, due to various real life, reported
problems with fuse filesystems.  For this reason I'd really like to
get this or a subset of it into mainline as soon as possible.

This patchset (or rather the -v7 version) has been running on my
laptop for a couple of weeks without problems.  I've also verified
that it solves the fuse and loop issues.

I have some qualms about the complexity of various parts though.
Especially the "proportions" library, which I'm having problems
understanding.  I'm not sure that this level of sophistication is
really needed to solve the issues with the old code.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
