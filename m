Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2CB216B5785
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 10:56:19 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id t3-v6so11275091oif.20
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 07:56:19 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o84-v6si6907851oia.458.2018.08.31.07.56.17
        for <linux-mm@kvack.org>;
        Fri, 31 Aug 2018 07:56:17 -0700 (PDT)
Date: Fri, 31 Aug 2018 15:56:13 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCHv2] kmemleak: Add option to print warnings to dmesg
Message-ID: <20180831145613.6cxtk3j5m4amxtoh@armageddon.cambridge.arm.com>
References: <20180827083821.7706-1-vincent.whitchurch@axis.com>
 <20180827151641.59bdca4e1ea2e532b10cd9fd@linux-foundation.org>
 <20180828101412.mb7t562roqbhsbjw@axis.com>
 <20180828102621.yawpcrkikhh4kagv@armageddon.cambridge.arm.com>
 <20180830074327.ivjq6g25lw7kpz2l@axis.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180830074327.ivjq6g25lw7kpz2l@axis.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vincent Whitchurch <vincent.whitchurch@axis.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Aug 30, 2018 at 09:43:27AM +0200, Vincent Whitchurch wrote:
> On Tue, Aug 28, 2018 at 11:26:22AM +0100, Catalin Marinas wrote:
> > On Tue, Aug 28, 2018 at 12:14:12PM +0200, Vincent Whitchurch wrote:
> > > On Mon, Aug 27, 2018 at 03:16:41PM -0700, Andrew Morton wrote:
> > > > On Mon, 27 Aug 2018 10:38:21 +0200 Vincent Whitchurch <vincent.whitchurch@axis.com> wrote:
> > > > > +config DEBUG_KMEMLEAK_WARN
> > > > > +	bool "Print kmemleak object warnings to log buffer"
> > > > > +	depends on DEBUG_KMEMLEAK
> > > > > +	help
> > > > > +	  Say Y here to make kmemleak print information about unreferenced
> > > > > +	  objects (including stacktraces) as warnings to the kernel log buffer.
> > > > > +	  Otherwise this information is only available by reading the kmemleak
> > > > > +	  debugfs file.
> > > > 
> > > > Why add the config option?  Why not simply make the change for all
> > > > configs?
> > > 
> > > No particular reason other than preserving the current behaviour for
> > > existing users.  I can remove the config option if Catalin is fine with
> > > it.
> > 
> > IIRC, in the early kmemleak days, people complained about it being to
> > noisy (the false positives rate was also much higher), so the default
> > behaviour was changed to monitor (almost) quietly with the details
> > available via debugfs. I'd like to keep this default behaviour but we
> > could have a "verbose" command via both debugfs and kernel parameter (as
> > we do with "off" and "on"). Would this work for you?
> 
> Either a config option or a parameter are usable for me.  How about
> something like this?  It can be enabled with kmemleak.verbose=1 or "echo
> 1 > /sys/module/kmemleak/parameters/verbose":

Works for me (slightly inconsistent with "echo ... >
/sys/kernel/debug/kmemleak" but a module_param seems to work better here
as it's a configuration rather than an action).

-- 
Catalin
