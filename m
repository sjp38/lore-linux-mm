Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 31C6D6B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 13:29:36 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so1349406pad.30
        for <linux-mm@kvack.org>; Thu, 15 May 2014 10:29:35 -0700 (PDT)
Received: from mail-pb0-x22c.google.com (mail-pb0-x22c.google.com [2607:f8b0:400e:c01::22c])
        by mx.google.com with ESMTPS id dh1si3007954pbc.284.2014.05.15.10.29.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 May 2014 10:29:35 -0700 (PDT)
Received: by mail-pb0-f44.google.com with SMTP id rq2so1365156pbb.31
        for <linux-mm@kvack.org>; Thu, 15 May 2014 10:29:35 -0700 (PDT)
Date: Thu, 15 May 2014 10:28:17 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH V4 0/2] mm: FAULT_AROUND_ORDER patchset performance data
 for powerpc
In-Reply-To: <537479E7.90806@linux.vnet.ibm.com>
Message-ID: <alpine.LSU.2.11.1405151026540.4664@eggly.anvils>
References: <1399541296-18810-1-git-send-email-maddy@linux.vnet.ibm.com> <537479E7.90806@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, benh@kernel.crashing.org, paulus@samba.org, kirill.shutemov@linux.intel.com, rusty@rustcorp.com.au, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org, dave.hansen@intel.com

On Thu, 15 May 2014, Madhavan Srinivasan wrote:
> 
> Hi Ingo,
> 
> 	Do you have any comments for the latest version of the patchset. If
> not, kindly can you pick it up as is.
> 
> 
> With regards
> Maddy
> 
> > Kirill A. Shutemov with 8c6e50b029 commit introduced
> > vm_ops->map_pages() for mapping easy accessible pages around
> > fault address in hope to reduce number of minor page faults.
> > 
> > This patch creates infrastructure to modify the FAULT_AROUND_ORDER
> > value using mm/Kconfig. This will enable architecture maintainers
> > to decide on suitable FAULT_AROUND_ORDER value based on
> > performance data for that architecture. First patch also defaults
> > FAULT_AROUND_ORDER Kconfig element to 4. Second patch list
> > out the performance numbers for powerpc (platform pseries) and
> > initialize the fault around order variable for pseries platform of
> > powerpc.

Sorry for not commenting earlier - just reminded by this ping to Ingo.

I didn't study your numbers, but nowhere did I see what PAGE_SIZE you use.

arch/powerpc/Kconfig suggests that Power supports base page size of
4k, 16k, 64k or 256k.

I would expect your optimal fault_around_order to depend very much on
the base page size.

Perhaps fault_around_size would provide a more useful default?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
