Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id CE9686B0253
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 07:32:11 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id p65so16135206wmp.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 04:32:11 -0800 (PST)
Date: Fri, 11 Mar 2016 13:32:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 03/18] mm: make vm_munmap killable
Message-ID: <20160311123209.GJ27701@dhcp22.suse.cz>
References: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
 <1456752417-9626-4-git-send-email-mhocko@kernel.org>
 <56E298B1.6010802@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56E298B1.6010802@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Deucher <alexander.deucher@amd.com>, Alex Thorlton <athorlton@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Benjamin LaHaise <bcrl@kvack.org>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Petr Cermak <petrcermak@chromium.org>, Thomas Gleixner <tglx@linutronix.de>, Alexander Viro <viro@zeniv.linux.org.uk>

On Fri 11-03-16 11:06:41, Vlastimil Babka wrote:
> On 02/29/2016 02:26 PM, Michal Hocko wrote:
> >From: Michal Hocko <mhocko@suse.com>
> >
> >Almost all current users of vm_munmap are ignoring the return value
> >and so they do not handle potential error. This means that some VMAs
> 
>    1   7834  arch/x86/kvm/x86.c <<__x86_set_memory_region>>
> 
>              r = vm_munmap(old.userspace_addr, old.npages * PAGE_SIZE);
>              WARN_ON(r < 0);
> 
> This warning will potentially add noise to OOM output?

Would it be harmfull though? I mean the warning is just goofy. I can
make it not warn on (r < 0 && r != -EINTR) but is it worth bothering?

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
