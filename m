Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id F21CE6B00CF
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 09:24:30 -0500 (EST)
Date: Thu, 5 Mar 2009 22:22:30 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: drop_caches ...
Message-ID: <20090305142230.GA23465@localhost>
References: <200903041057.34072.M4rkusXXL@web.de> <200903051255.35407.M4rkusXXL@web.de> <20090305132906.GA22524@localhost> <200903051505.26584.M4rkusXXL@web.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200903051505.26584.M4rkusXXL@web.de>
Sender: owner-linux-mm@kvack.org
To: Markus <M4rkusXXL@web.de>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Zdenek Kabelac <zkabelac@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Lukas Hejtmanek <xhejtman@ics.muni.cz>
List-ID: <linux-mm.kvack.org>

Hi Markus,

On Thu, Mar 05, 2009 at 04:05:26PM +0200, Markus wrote:
> > Could you please try the attached patch which will also show the
> > user and process that opened these files? It adds three more fields
> > when CONFIG_PROC_FILECACHE_EXTRAS is selected.
> > 
> > Thanks,
> > Fengguang
> >  
> > On Thu, Mar 05, 2009 at 01:55:35PM +0200, Markus wrote:
> > > 
> > > # sort -n -k 3 filecache-2009-03-05 | tail -n 5
> > >      15886       7112     7112     100      1    d- 00:08
> > > (tmpfs)        /dev/zero\040(deleted)
> > >      16209      35708    35708     100      1    d- 00:08
> > > (tmpfs)        /dev/zero\040(deleted)
> > >      16212      82128    82128     100      1    d- 00:08
> > > (tmpfs)        /dev/zero\040(deleted)
> > >      15887     340024   340024     100      1    d- 00:08
> > > (tmpfs)        /dev/zero\040(deleted)
> > >      15884     455008   455008     100      1    d- 00:08
> > > (tmpfs)        /dev/zero\040(deleted)
> > > 
> > > The sum of the third column is 1013 MB.
> > > To note the biggest ones (or do you want the whole file?)... and 
> thats 
> > > after a sync and a drop_caches! (Can be seen in the commands given.)
> 
> I could, but I know where these things belong to. Its from sphinx (a 
> mysql indexer) searchd. It loads parts of the index into memory.
> The sizes looked well-known and killing the searchd will reduce "cached" 
> to a normal amount ;)

And it's weird about the file name: /dev/zero.  I wonder how it
managed to create that file, and then delete it, inside a tmpfs!

Just out of curiosity, are they shm objects? Can you show us the
output of 'df'? In your convenient time.

> I just dont know why its in "cached" (can that be swapped out btw?).
> But I think thats not a problem of the kernel, but of anonymous 
> mmap-ing.

You know, because the file is created in tmpfs, which is swap-backed.
By definition the pages here cannot be dropped by third-party.

> I think its resolved, thanks to everybody and Fengguang in particular!

You are welcome :-)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
