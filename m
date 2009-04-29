Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4A26B6B004F
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 07:45:23 -0400 (EDT)
Date: Wed, 29 Apr 2009 19:45:26 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: btrfs BUG on creating huge sparse file
Message-ID: <20090429114526.GA24418@localhost>
References: <20090407151010.E72A91D0471@basil.firstfloor.org> <1239210239.28688.15.camel@think.oraclecorp.com> <20090409072949.GF14687@one.firstfloor.org> <20090409075805.GG14687@one.firstfloor.org> <1239283829.23150.34.camel@think.oraclecorp.com> <20090409140257.GI14687@one.firstfloor.org> <1239287859.23150.57.camel@think.oraclecorp.com> <20090429081616.GA8339@localhost> <20090429082151.GA15170@localhost> <1241005222.19174.1.camel@think.oraclecorp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1241005222.19174.1.camel@think.oraclecorp.com>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: Andi Kleen <andi@firstfloor.org>, "hugh@veritas.com" <hugh@veritas.com>, "npiggin@suse.de" <npiggin@suse.de>, "riel@redhat.com" <riel@redhat.com>, "lee.schermerhorn@hp.com" <lee.schermerhorn@hp.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "linux-btrfs@vger.kernel.org" <linux-btrfs@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 29, 2009 at 07:40:22PM +0800, Chris Mason wrote:
> On Wed, 2009-04-29 at 16:21 +0800, Wu Fengguang wrote:
> > On Wed, Apr 29, 2009 at 04:16:16PM +0800, Wu Fengguang wrote:
> > > On Thu, Apr 09, 2009 at 10:37:39AM -0400, Chris Mason wrote:
> > [snip]
> > > > PagePrivate is very common.  try_to_releasepage failing on a clean page
> > > > without the writeback bit set and without dirty/locked buffers will be
> > > > pretty rare.
> > > 
> > > Yup. btrfs seems to tag most(if not all) dirty pages with PG_private.
> > > While ext4 won't.
> > 
> > Chris, I run into a btrfs BUG() when doing
> > 
> >         dd if=/dev/zero of=/b/sparse bs=1k count=1 seek=104857512345
> > 
> > The half created sparse file is
> > 
> >         -rw-r--r-- 1 root root 98T 2009-04-29 14:54 /b/sparse
> >         Or
> >         -rw-r--r-- 1 root root 107374092641280 2009-04-29 14:54 /b/sparse
> > 
> > Below is the kernel messages. I can test patches you throw at me :-)
> > 
> 
> How big was the FS you were testing this on?  It works for me...

df says:

/dev/sda3             4.3G   28K  4.3G   1% /b

Oh bad, I cannot reproduce it now..

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
