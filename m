Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D3FA86B0292
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 07:40:14 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x28so13689726wma.7
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 04:40:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o67si3697699wmo.223.2017.08.14.04.40.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 14 Aug 2017 04:40:13 -0700 (PDT)
Date: Mon, 14 Aug 2017 13:40:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v6 01/15] x86/mm: reserve only exiting low pages
Message-ID: <20170814114011.GG19063@dhcp22.suse.cz>
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-2-git-send-email-pasha.tatashin@oracle.com>
 <20170811080706.GC30811@dhcp22.suse.cz>
 <47ebf53b-ea8b-1822-a63a-3682ed2f4753@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <47ebf53b-ea8b-1822-a63a-3682ed2f4753@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org

On Fri 11-08-17 11:24:55, Pasha Tatashin wrote:
[...]
> >>In this patchset we will stop zeroing struct page memory during allocation.
> >>Therefore, this bug must be fixed in order to avoid random assert failures
> >>caused by CONFIG_DEBUG_VM_PGFLAGS triggers.
> >>
> >>The fix is to reserve memory from the first existing PFN.
> >
> >Hmm, I assume this is a result of some assert triggering, right? Which
> >one? Why don't we need the same treatment for other than x86 arch?
> 
> Correct, the pgflags asserts were triggered when we were setting reserved
> flags to struct page for PFN 0 in which was never initialized through
> __init_single_page(). The reason they were triggered is because we set all
> uninitialized memory to ones in one of the debug patches.

And why don't we need the same treatment for other architectures?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
