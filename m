Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2FE7D6B0313
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 12:06:50 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id e204so6933353wma.2
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 09:06:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i135si980009wmd.125.2017.08.11.09.06.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 11 Aug 2017 09:06:49 -0700 (PDT)
Date: Fri, 11 Aug 2017 18:06:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v6 07/15] mm: defining memblock_virt_alloc_try_nid_raw
Message-ID: <20170811160646.GT30811@dhcp22.suse.cz>
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-8-git-send-email-pasha.tatashin@oracle.com>
 <20170811123953.GI30811@dhcp22.suse.cz>
 <545b7230-2c09-d2f9-f26a-05ef395c36d4@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <545b7230-2c09-d2f9-f26a-05ef395c36d4@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org

On Fri 11-08-17 11:58:46, Pasha Tatashin wrote:
> On 08/11/2017 08:39 AM, Michal Hocko wrote:
> >On Mon 07-08-17 16:38:41, Pavel Tatashin wrote:
> >>A new variant of memblock_virt_alloc_* allocations:
> >>memblock_virt_alloc_try_nid_raw()
> >>     - Does not zero the allocated memory
> >>     - Does not panic if request cannot be satisfied
> >
> >OK, this looks good but I would not introduce memblock_virt_alloc_raw
> >here because we do not have any users. Please move that to "mm: optimize
> >early system hash allocations" which actually uses the API. It would be
> >easier to review it that way.
> >
> >>Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> >>Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
> >>Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
> >>Reviewed-by: Bob Picco <bob.picco@oracle.com>
> >
> >other than that
> >Acked-by: Michal Hocko <mhocko@suse.com>
> 
> Sure, I could do this, but as I understood from earlier Dave Miller's
> comments, we should do one logical change at a time. Hence, introduce API in
> one patch use it in another. So, this is how I tried to organize this patch
> set. Is this assumption incorrect?

Well, it really depends. If the patch is really small then adding a new
API along with users is easier to review and backport because you have a
clear view of the usage. I believe this is the case here. But if others
feel otherwise I will not object.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
