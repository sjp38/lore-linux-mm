Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id A53596B0035
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 11:12:10 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d17so4758756eek.15
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 08:12:09 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r9si60149227eew.288.2014.04.22.08.12.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 08:12:09 -0700 (PDT)
Date: Tue, 22 Apr 2014 16:12:03 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/3] Use an alternative to _PAGE_PROTNONE for _PAGE_NUMA
 v4
Message-ID: <20140422151203.GF23991@suse.de>
References: <1397572876-1610-1-git-send-email-mgorman@suse.de>
 <20140417025912.GA7797@localhost>
 <20140417090655.GZ7292@suse.de>
 <20140419074600.GA26343@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140419074600.GA26343@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, Apr 19, 2014 at 03:46:00PM +0800, Fengguang Wu wrote:
> On Thu, Apr 17, 2014 at 10:06:55AM +0100, Mel Gorman wrote:
> > On Thu, Apr 17, 2014 at 10:59:12AM +0800, Fengguang Wu wrote:
> > > On Tue, Apr 15, 2014 at 03:41:13PM +0100, Mel Gorman wrote:
> > > > Fengguang Wu found that an earlier version crashed on his
> > > > tests. This version passed tests running with DEBUG_VM and
> > > > DEBUG_PAGEALLOC. Fengguang, another test would be appreciated and
> > > > if it helps this series is the mm-numa-use-high-bit-v4r3 branch in
> > > > git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux-balancenuma.git
> > > 
> > > Hi Mel,
> > > 
> > > We noticed the below changes. The last_state.is_incomplete_run 0=>1 change
> > > means the test box failed to boot up. Unfortunately we don't have
> > > serial console output of this testbox, it may be hard to check the
> > > root cause. Anyway, I'll try to bisect it to make the debug easier.
> > > 
> > 
> > The bisection will be pretty small and probably point to the last patch.
> 
> Sorry I find it is lkp-a04 that is not reliable: by increasing test
> count of v3.14, it boot hangs, too..
> 

Is there any chance this is a regression introduced for 3.14 then?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
