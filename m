Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id DEDDF6B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 07:50:04 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id h126so13691901wmf.10
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 04:50:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z2si3739902wmg.180.2017.08.14.04.50.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 14 Aug 2017 04:50:03 -0700 (PDT)
Date: Mon, 14 Aug 2017 13:50:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v6 15/15] mm: debug for raw alloctor
Message-ID: <20170814115000.GJ19063@dhcp22.suse.cz>
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-16-git-send-email-pasha.tatashin@oracle.com>
 <20170811130831.GN30811@dhcp22.suse.cz>
 <87d84cad-f03a-88f0-7828-6d3bf7ac473c@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87d84cad-f03a-88f0-7828-6d3bf7ac473c@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org

On Fri 11-08-17 12:18:24, Pasha Tatashin wrote:
> >>When CONFIG_DEBUG_VM is enabled, this patch sets all the memory that is
> >>returned by memblock_virt_alloc_try_nid_raw() to ones to ensure that no
> >>places excpect zeroed memory.
> >
> >Please fold this into the patch which introduces
> >memblock_virt_alloc_try_nid_raw.
> 
> OK
> 
>  I am not sure CONFIG_DEBUG_VM is the
> >best config because that tends to be enabled quite often. Maybe
> >CONFIG_MEMBLOCK_DEBUG? Or even make it kernel command line parameter?
> >
> 
> Initially, I did not want to make it CONFIG_MEMBLOCK_DEBUG because we really
> benefit from this debugging code when VM debug is enabled, and especially
> struct page debugging asserts which also depend on CONFIG_DEBUG_VM.
> 
> However, now thinking about it, I will change it to CONFIG_MEMBLOCK_DEBUG,
> and let users decide what other debugging configs need to be enabled, as
> this is also OK.

Actually the more I think about it the more I am convinced that a kernel
boot parameter would be better because it doesn't need the kernel to be
recompiled and it is a single branch in not so hot path.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
