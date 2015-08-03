Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8AB809003CD
	for <linux-mm@kvack.org>; Mon,  3 Aug 2015 11:52:00 -0400 (EDT)
Received: by pawu10 with SMTP id u10so15648947paw.1
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 08:52:00 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id hg5si13597928pbb.236.2015.08.03.08.51.59
        for <linux-mm@kvack.org>;
        Mon, 03 Aug 2015 08:51:59 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <alpine.DEB.2.10.1507241314300.5215@chino.kir.corp.google.com>
References: <201507241628.EnDEXbaF%fengguang.wu@intel.com>
 <20150724100940.GB22732@node.dhcp.inet.fi>
 <alpine.DEB.2.10.1507241314300.5215@chino.kir.corp.google.com>
Subject: Re: vm_flags, vm_flags_t and __nocast
Content-Transfer-Encoding: 7bit
Message-Id: <20150803155155.7F8546E@black.fi.intel.com>
Date: Mon,  3 Aug 2015 18:51:55 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, kbuild test robot <fengguang.wu@intel.com>, Oleg Nesterov <oleg@redhat.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linux Memory Management List <linux-mm@kvack.org>

David Rientjes wrote:
> On Fri, 24 Jul 2015, Kirill A. Shutemov wrote:
> 
> > sparse complains on each and every vm_flags_t initialization, even with
> > proper VM_* constants.
> > 
> > Do we really want to fix that?
> > 
> > To me it's too much pain and no gain. __nocast is not beneficial here.
> > 
> > And I'm not sure that vm_flags_t typedef was a good idea after all.
> > Originally, it was intended to become 64-bit one day, but four years later
> > it's still unsigned long. Plain unsigned long works fine for other bit
> > field.
> > 
> > What is special about vm_flags?
> > 
> 
> Maybe remove the __nocast until it's a different type?  Seems like all 
> these sites would have to be audited when that happens anyway.
