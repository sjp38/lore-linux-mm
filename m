Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 41D376B0038
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 10:50:25 -0400 (EDT)
Received: by obfe9 with SMTP id e9so84937597obf.1
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 07:50:25 -0700 (PDT)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id o62si14013393oig.107.2015.04.27.07.50.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 07:50:23 -0700 (PDT)
Message-ID: <1430145076.23761.52.camel@misato.fc.hp.com>
Subject: Re: [PATCH v4 0/7] mtrr, mm, x86: Enhance MTRR checks for huge I/O
 mapping
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 27 Apr 2015 08:31:16 -0600
In-Reply-To: <1428074540.31093.110.camel@misato.fc.hp.com>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
	 <20150324154324.f9ca557127f7bc7aed45a86b@linux-foundation.org>
	 <20150403063302.GA29212@gmail.com>
	 <1428074540.31093.110.camel@misato.fc.hp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Fri, 2015-04-03 at 09:22 -0600, Toshi Kani wrote:
> On Fri, 2015-04-03 at 08:33 +0200, Ingo Molnar wrote:
> > * Andrew Morton <akpm@linux-foundation.org> wrote:
> > 
> > > On Tue, 24 Mar 2015 16:08:34 -0600 Toshi Kani <toshi.kani@hp.com> wrote:
> > > 
> > > > This patchset enhances MTRR checks for the kernel huge I/O mapping,
> > > > which was enabled by the patchset below:
> > > >   https://lkml.org/lkml/2015/3/3/589
> > > > 
> > > > The following functional changes are made in patch 7/7.
> > > >  - Allow pud_set_huge() and pmd_set_huge() to create a huge page
> > > >    mapping to a range covered by a single MTRR entry of any memory
> > > >    type.
> > > >  - Log a pr_warn() message when a specified PMD map range spans more
> > > >    than a single MTRR entry.  Drivers should make a mapping request
> > > >    aligned to a single MTRR entry when the range is covered by MTRRs.
> > > > 
> > > 
> > > OK, I grabbed these after barely looking at them, to get them a bit of
> > > runtime testing.
> > > 
> > > I'll await guidance from the x86 maintainers regarding next steps?
> > 
> > Could you please send the current version of them over to us if your 
> > testing didn't find any problems?
> > 
> > I'd like to take a final look and have them cook in the x86 tree as 
> > well for a while and want to preserve your testing effort.
> 
> This patchset is on top of the following patches in the -mm tree.
> (Patches apply from the bottom to the top.)

Ingo,

The following patches (2 got squashed to 1) went to 4.1-rc1, but this
patch-set is still sitting in the -mm tree.  I confirmed that the
patch-set applies cleanly to 4.1-rc1.  Please take a final look and let
me know if you have any comment.

Thanks,
-Toshi


> 2. Build error fixes and cleanups
> http://ozlabs.org/~akpm/mmotm/broken-out/x86-mm-support-huge-kva-mappings-on-x86-fix.patch
> http://ozlabs.org/~akpm/mmotm/broken-out/mm-change-vunmap-to-tear-down-huge-kva-mappings-fix.patch
> http://ozlabs.org/~akpm/mmotm/broken-out/mm-change-ioremap-to-set-up-huge-i-o-mappings-fix.patch
> http://ozlabs.org/~akpm/mmotm/broken-out/lib-add-huge-i-o-map-capability-interfaces-fix.patch
> 
> 1. Kernel huge I/O mapping support
> http://ozlabs.org/~akpm/mmotm/broken-out/x86-mm-support-huge-kva-mappings-on-x86.patch
> http://ozlabs.org/~akpm/mmotm/broken-out/x86-mm-support-huge-i-o-mapping-capability-i-f.patch
> http://ozlabs.org/~akpm/mmotm/broken-out/mm-change-vunmap-to-tear-down-huge-kva-mappings.patch
> http://ozlabs.org/~akpm/mmotm/broken-out/mm-change-ioremap-to-set-up-huge-i-o-mappings.patch
> http://ozlabs.org/~akpm/mmotm/broken-out/lib-add-huge-i-o-map-capability-interfaces.patch
> http://ozlabs.org/~akpm/mmotm/broken-out/mm-change-__get_vm_area_node-to-use-fls_long.patch
> 
> Thanks,
> -Toshi
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
