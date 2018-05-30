Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 58C4F6B0008
	for <linux-mm@kvack.org>; Wed, 30 May 2018 16:06:30 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x21-v6so11341058pfn.23
        for <linux-mm@kvack.org>; Wed, 30 May 2018 13:06:30 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u2-v6si27668709pgv.246.2018.05.30.13.06.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 May 2018 13:06:29 -0700 (PDT)
Date: Wed, 30 May 2018 22:06:08 +0200
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v3 0/2] mm: PAGE_KERNEL_* fallbacks
Message-ID: <20180530200608.GA15435@kroah.com>
References: <20180510185507.2439-1-mcgrof@kernel.org>
 <20180516164403.GI27853@wotan.suse.de>
 <20180523213551.GF4511@wotan.suse.de>
 <20180530195500.GU4511@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180530195500.GU4511@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: arnd@arndb.de, willy@infradead.org, geert@linux-m68k.org, linux-m68k@lists.linux-m68k.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, May 30, 2018 at 09:55:00PM +0200, Luis R. Rodriguez wrote:
> On Wed, May 23, 2018 at 11:35:51PM +0200, Luis R. Rodriguez wrote:
> > On Wed, May 16, 2018 at 06:44:03PM +0200, Luis R. Rodriguez wrote:
> > > On Thu, May 10, 2018 at 11:55:05AM -0700, Luis R. Rodriguez wrote:
> > > > This is the 3rd iteration for moving PAGE_KERNEL_* fallback
> > > > definitions into asm-generic headers. Greg asked for a Changelog
> > > > for patch iteration changes, its below.
> > > > 
> > > > All these patches have been tested by 0-day.
> > > > 
> > > > Questions, and specially flames are greatly appreciated.
> > > 
> > > *Poke*
> > 
> > Greg, since this does touch the firmware loader as well, *poke*.
> 
> *Re-re-poke*

Hah, they are not for me to take, sorry, that's up to the mm maintainer.

good luck!

greg k-h
