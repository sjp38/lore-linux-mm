Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 99FB16B45A9
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 06:26:27 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id w185-v6so844815oig.19
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 03:26:27 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s65-v6si434849oif.166.2018.08.28.03.26.26
        for <linux-mm@kvack.org>;
        Tue, 28 Aug 2018 03:26:26 -0700 (PDT)
Date: Tue, 28 Aug 2018 11:26:22 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCHv2] kmemleak: Add option to print warnings to dmesg
Message-ID: <20180828102621.yawpcrkikhh4kagv@armageddon.cambridge.arm.com>
References: <20180827083821.7706-1-vincent.whitchurch@axis.com>
 <20180827151641.59bdca4e1ea2e532b10cd9fd@linux-foundation.org>
 <20180828101412.mb7t562roqbhsbjw@axis.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180828101412.mb7t562roqbhsbjw@axis.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vincent Whitchurch <vincent.whitchurch@axis.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Aug 28, 2018 at 12:14:12PM +0200, Vincent Whitchurch wrote:
> On Mon, Aug 27, 2018 at 03:16:41PM -0700, Andrew Morton wrote:
> > On Mon, 27 Aug 2018 10:38:21 +0200 Vincent Whitchurch <vincent.whitchurch@axis.com> wrote:
> > > --- a/lib/Kconfig.debug
> > > +++ b/lib/Kconfig.debug
> > > @@ -593,6 +593,15 @@ config DEBUG_KMEMLEAK_DEFAULT_OFF
> > >  	  Say Y here to disable kmemleak by default. It can then be enabled
> > >  	  on the command line via kmemleak=on.
> > >  
> > > +config DEBUG_KMEMLEAK_WARN
> > > +	bool "Print kmemleak object warnings to log buffer"
> > > +	depends on DEBUG_KMEMLEAK
> > > +	help
> > > +	  Say Y here to make kmemleak print information about unreferenced
> > > +	  objects (including stacktraces) as warnings to the kernel log buffer.
> > > +	  Otherwise this information is only available by reading the kmemleak
> > > +	  debugfs file.
> > 
> > Why add the config option?  Why not simply make the change for all
> > configs?
> 
> No particular reason other than preserving the current behaviour for
> existing users.  I can remove the config option if Catalin is fine with
> it.

IIRC, in the early kmemleak days, people complained about it being to
noisy (the false positives rate was also much higher), so the default
behaviour was changed to monitor (almost) quietly with the details
available via debugfs. I'd like to keep this default behaviour but we
could have a "verbose" command via both debugfs and kernel parameter (as
we do with "off" and "on"). Would this work for you?

-- 
Catalin
