Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 21BE86B00C9
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 09:05:31 -0500 (EST)
From: Markus <M4rkusXXL@web.de>
Subject: Re: drop_caches ...
Date: Thu, 5 Mar 2009 15:05:26 +0100
References: <200903041057.34072.M4rkusXXL@web.de> <200903051255.35407.M4rkusXXL@web.de> <20090305132906.GA22524@localhost>
In-Reply-To: <20090305132906.GA22524@localhost>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200903051505.26584.M4rkusXXL@web.de>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: Wu Fengguang <fengguang.wu@intel.com>, Zdenek Kabelac <zkabelac@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Lukas Hejtmanek <xhejtman@ics.muni.cz>
List-ID: <linux-mm.kvack.org>

> Could you please try the attached patch which will also show the
> user and process that opened these files? It adds three more fields
> when CONFIG_PROC_FILECACHE_EXTRAS is selected.
> 
> Thanks,
> Fengguang
>  
> On Thu, Mar 05, 2009 at 01:55:35PM +0200, Markus wrote:
> > 
> > # sort -n -k 3 filecache-2009-03-05 | tail -n 5
> >      15886       7112     7112     100      1    d- 00:08
> > (tmpfs)        /dev/zero\040(deleted)
> >      16209      35708    35708     100      1    d- 00:08
> > (tmpfs)        /dev/zero\040(deleted)
> >      16212      82128    82128     100      1    d- 00:08
> > (tmpfs)        /dev/zero\040(deleted)
> >      15887     340024   340024     100      1    d- 00:08
> > (tmpfs)        /dev/zero\040(deleted)
> >      15884     455008   455008     100      1    d- 00:08
> > (tmpfs)        /dev/zero\040(deleted)
> > 
> > The sum of the third column is 1013 MB.
> > To note the biggest ones (or do you want the whole file?)... and 
thats 
> > after a sync and a drop_caches! (Can be seen in the commands given.)

I could, but I know where these things belong to. Its from sphinx (a 
mysql indexer) searchd. It loads parts of the index into memory.
The sizes looked well-known and killing the searchd will reduce "cached" 
to a normal amount ;)

I just dont know why its in "cached" (can that be swapped out btw?).
But I think thats not a problem of the kernel, but of anonymous 
mmap-ing.

I think its resolved, thanks to everybody and Fengguang in particular!

Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
