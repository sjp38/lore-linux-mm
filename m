In-reply-to: <1201626379.28547.142.camel@lappy> (message from Peter Zijlstra
	on Tue, 29 Jan 2008 18:06:19 +0100)
Subject: Re: [patch 0/6] mm: bdi: updates
References: <20080129154900.145303789@szeredi.hu> <1201626379.28547.142.camel@lappy>
Message-Id: <E1JJvGA-00060l-Ja@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 29 Jan 2008 19:32:38 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Tue, 2008-01-29 at 16:49 +0100, Miklos Szeredi wrote:
> > This is a series from Peter Zijlstra, with various updates by me.  The
> > patchset mostly deals with exporting BDI attributes in sysfs.
> > 
> > Should be in a mergeable state, at least into -mm.
> 
> Thanks for picking these up Miklos!
> 
> While they do not strictly depend upon the /proc/<pid>/mountinfo patch I
> think its good to mention they go hand in hand. The mountinfo file gives
> the information needed to associate a mount with a given bdi for non
> block devices.

More precisely /proc/<pid>/mountinfo is only needed to find mounts for
a given BDI (which might not be a very common scenario), and not the
other way round.

But both patches are useful, and they are even more useful together ;)

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
