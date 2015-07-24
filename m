Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id A5A886B0253
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 16:15:31 -0400 (EDT)
Received: by padck2 with SMTP id ck2so19294729pad.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 13:15:31 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id md1si6305364pdb.200.2015.07.24.13.15.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 13:15:30 -0700 (PDT)
Received: by pachj5 with SMTP id hj5so19208034pac.3
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 13:15:30 -0700 (PDT)
Date: Fri, 24 Jul 2015 13:15:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: vm_flags, vm_flags_t and __nocast
In-Reply-To: <20150724100940.GB22732@node.dhcp.inet.fi>
Message-ID: <alpine.DEB.2.10.1507241314300.5215@chino.kir.corp.google.com>
References: <201507241628.EnDEXbaF%fengguang.wu@intel.com> <20150724100940.GB22732@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, kbuild test robot <fengguang.wu@intel.com>, Oleg Nesterov <oleg@redhat.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linux Memory Management List <linux-mm@kvack.org>

On Fri, 24 Jul 2015, Kirill A. Shutemov wrote:

> sparse complains on each and every vm_flags_t initialization, even with
> proper VM_* constants.
> 
> Do we really want to fix that?
> 
> To me it's too much pain and no gain. __nocast is not beneficial here.
> 
> And I'm not sure that vm_flags_t typedef was a good idea after all.
> Originally, it was intended to become 64-bit one day, but four years later
> it's still unsigned long. Plain unsigned long works fine for other bit
> field.
> 
> What is special about vm_flags?
> 

Maybe remove the __nocast until it's a different type?  Seems like all 
these sites would have to be audited when that happens anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
