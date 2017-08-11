Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A14CA6B025F
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 11:22:44 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x28so6732294wma.7
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 08:22:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n5si919028wmf.128.2017.08.11.08.22.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 11 Aug 2017 08:22:43 -0700 (PDT)
Date: Fri, 11 Aug 2017 17:22:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v6 00/15] complete deferred page initialization
Message-ID: <20170811152240.GQ30811@dhcp22.suse.cz>
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <20170811075826.GB30811@dhcp22.suse.cz>
 <23e22449-89f0-507d-e92a-9ee947a7c363@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <23e22449-89f0-507d-e92a-9ee947a7c363@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org

On Fri 11-08-17 11:13:07, Pasha Tatashin wrote:
> On 08/11/2017 03:58 AM, Michal Hocko wrote:
> >[I am sorry I didn't get to your previous versions]
> 
> Thank you for reviewing this work. I will address your comments, and
> send-out a new patches.
> 
> >>
> >>In this work we do the following:
> >>- Never read access struct page until it was initialized
> >
> >How is this enforced? What about pfn walkers? E.g. page_ext
> >initialization code (page owner in particular)
> 
> This is hard to enforce 100%. But, because we have a patch in this series
> that sets all memory that was allocated by memblock_virt_alloc_try_nid_raw()
> to ones with debug options enabled, and because Linux has a good set of
> asserts in place that check struct pages to be sane, especially the ones
> that are enabled with this config: CONFIG_DEBUG_VM_PGFLAGS. I was able to
> find many places in linux which accessed struct pages before
> __init_single_page() is performed, and fix them. Most of these places happen
> only when deferred struct page initialization code is enabled.

Yes, I am very well aware of how hard is this to guarantee. I was merely
pointing out that the changelog should be more verbose about your
testing and assumptions so that we can revalidate them.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
