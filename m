Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4E60C6B0003
	for <linux-mm@kvack.org>; Wed, 30 May 2018 16:21:29 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w74-v6so12969257wmw.0
        for <linux-mm@kvack.org>; Wed, 30 May 2018 13:21:29 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r19-v6si566290eda.307.2018.05.30.13.21.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 May 2018 13:21:28 -0700 (PDT)
Date: Wed, 30 May 2018 22:21:27 +0200
From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: [PATCH v3 0/2] mm: PAGE_KERNEL_* fallbacks
Message-ID: <20180530202127.GV4511@wotan.suse.de>
References: <20180510185507.2439-1-mcgrof@kernel.org>
 <20180516164403.GI27853@wotan.suse.de>
 <20180523213551.GF4511@wotan.suse.de>
 <20180530195500.GU4511@wotan.suse.de>
 <20180530200608.GA15435@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180530200608.GA15435@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>, willy@infradead.org, geert@linux-m68k.org, linux-m68k@lists.linux-m68k.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, May 30, 2018 at 10:06:08PM +0200, Greg KH wrote:
> On Wed, May 30, 2018 at 09:55:00PM +0200, Luis R. Rodriguez wrote:
> > On Wed, May 23, 2018 at 11:35:51PM +0200, Luis R. Rodriguez wrote:
> > > On Wed, May 16, 2018 at 06:44:03PM +0200, Luis R. Rodriguez wrote:
> > > > On Thu, May 10, 2018 at 11:55:05AM -0700, Luis R. Rodriguez wrote:
> > > > > This is the 3rd iteration for moving PAGE_KERNEL_* fallback
> > > > > definitions into asm-generic headers. Greg asked for a Changelog
> > > > > for patch iteration changes, its below.
> > > > > 
> > > > > All these patches have been tested by 0-day.
> > > > > 
> > > > > Questions, and specially flames are greatly appreciated.
> > > > 
> > > > *Poke*
> > > 
> > > Greg, since this does touch the firmware loader as well, *poke*.
> > 
> > *Re-re-poke*
> 
> Hah, they are not for me to take, sorry, that's up to the mm maintainer.

I'm not sure it is up to mm actually, since this is all
include/asm-generic/pgtable.h it seems this falls onto Arnd.
Its probably *best* mm folks decide though.

Arnd, are you OK if Andrew picks this up if he finds no issues with
the patches?

I'll bouncing copies to Andrew now.

  Luis
