Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 23C216B0033
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 22:51:23 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id k15so6747445qtg.5
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 19:51:23 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id w62si15951573qkb.124.2017.02.01.19.51.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 19:51:22 -0800 (PST)
Date: Thu, 2 Feb 2017 14:51:17 +1100
From: Tobin Harding <me@tobin.cc>
Subject: Re: [PATCH 2/4] mm: Fix checkpatch warnings, whitespace
Message-ID: <20170202035117.GA15650@eros>
References: <1485992240-10986-1-git-send-email-me@tobin.cc>
 <1485992240-10986-3-git-send-email-me@tobin.cc>
 <alpine.DEB.2.10.1702011648160.58909@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1702011648160.58909@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, Michal Hocko <mhocko@suse.com>

On Wed, Feb 01, 2017 at 04:48:28PM -0800, David Rientjes wrote:
> On Thu, 2 Feb 2017, Tobin C. Harding wrote:
> 
> > @@ -3696,8 +3695,8 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
> >                   * VM_FAULT_OOM), there is no need to kill anything.
> >                   * Just clean up the OOM state peacefully.
> >                   */
> > -                if (task_in_memcg_oom(current) && !(ret & VM_FAULT_OOM))
> > -                        mem_cgroup_oom_synchronize(false);
> > +		if (task_in_memcg_oom(current) && !(ret & VM_FAULT_OOM))
> > +			mem_cgroup_oom_synchronize(false);
> >  	}
> >  
> >  	/*
> 
> The comment suffers from the same problem.

The comment is fixed in the next patch of the set. The fixes are in
separate patches because one was a checkpatch warning and one was an
error.

Any comments on the structure of the patchset most appreciated.


thanks,
Tobin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
