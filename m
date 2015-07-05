Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id B97C9280291
	for <linux-mm@kvack.org>; Sat,  4 Jul 2015 21:22:40 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so75916151pac.2
        for <linux-mm@kvack.org>; Sat, 04 Jul 2015 18:22:40 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id of16si21791932pdb.108.2015.07.04.18.22.39
        for <linux-mm@kvack.org>;
        Sat, 04 Jul 2015 18:22:39 -0700 (PDT)
Date: Sun, 5 Jul 2015 09:21:47 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: include/linux/bug.h:93:12: error: dereferencing pointer to
 incomplete type
Message-ID: <20150705012147.GB8476@wfg-t540p.sh.intel.com>
References: <201507042000.Xg8x65h2%fengguang.wu@intel.com>
 <20150704204836.GA2565@x>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150704204836.GA2565@x>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Triplett <josh@joshtriplett.org>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, David Howells <dhowells@redhat.com>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, moderated for non-subscribers <linux-am33-list@redhat.com>

Thank you Josh!  CC mn10300 maintainers for possible fix in
arch/mn10300/ code.                     -fengguang

On Sat, Jul 04, 2015 at 01:48:38PM -0700, Josh Triplett wrote:
> On Sat, Jul 04, 2015 at 08:36:05PM +0800, kbuild test robot wrote:
> > Hi Josh,
> > 
> > FYI, the error/warning still remains. You may either fix it or ask me to silently ignore in future.
> 
> As mentioned before, it's a bug in mn10300, not a bug in the commit in
> question.  It needs fixing by the mn10300 architecture folks.  Please
> send it to them in the future.
> 
> My description of the bug from the previous time this came up:
> > This looks like a bug in mn10300.  This code is within an ifdef on
> > CONFIG_GENERIC_BUG, and the declaration of the structure is within
> > ifdefs on both CONFIG_GENERIC_BUG and CONFIG_BUG, but:
> >
> > > CONFIG_MN10300=y
> > [...]
> > > CONFIG_GENERIC_BUG=y
> > [...]
> > > # CONFIG_BUG is not set
> >
> > Other architectures, including x86 (arch/x86/Kconfig) and powerpc
> > (arch/powerpc/Kconfig) have GENERIC_BUG depend on BUG.  Looks like
> > mn10300 doesn't.
> 
> - Josh Triplett

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
