Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6C8D19003C7
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 10:53:11 -0400 (EDT)
Received: by oigd21 with SMTP id d21so83653708oig.1
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 07:53:11 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id xj4si18988667oeb.73.2015.07.21.07.53.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 07:53:10 -0700 (PDT)
Message-ID: <1437490320.3214.206.camel@hp.com>
Subject: Re: [PATCH v2 0/4] x86, mm: Handle large PAT bit in pud/pmd
 interfaces
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 21 Jul 2015 08:52:00 -0600
In-Reply-To: <20150721080544.GA28118@gmail.com>
References: <1436977435-31826-1-git-send-email-toshi.kani@hp.com>
	 <20150721080544.GA28118@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hp.com

On Tue, 2015-07-21 at 10:05 +0200, Ingo Molnar wrote:
> * Toshi Kani <toshi.kani@hp.com> wrote:
> 
> > The PAT bit gets relocated to bit 12 when PUD and PMD mappings are 
> > used.
> > This bit 12, however, is not covered by PTE_FLAGS_MASK, which is 
> > corrently
> > used for masking pfn and flags for all cases.
> > 
> > Patch 1/4-2/4 make changes necessary for patch 3/4 to use 
> > P?D_PAGE_MASK.
> > 
> > Patch 3/4 fixes pud/pmd interfaces to handle the PAT bit when PUD and 
> > PMD
> > mappings are used.
> > 
> > Patch 3/4 fixes /sys/kernel/debug/kernel_page_tables to show the PAT 
> > bit
> > properly.
> > 
> > Note, the PAT bit is first enabled in 4.2-rc1 with WT mappings.
> 
> Are patches 1-3 only needed to fix /sys/kernel/debug/kernel_page_tables 
> output, or 
> are there other things fixed as well? The patches do not tell us any of 
> that information ...

Patch 3 (and patch 1-2 needed for patch 3) fixes multiple pud/pmd
interfaces to work properly with _PAGE_PAT_LARGE bit set.  Because pmem is
the only module that can create a range with this bit set with large page
WT maps in 4.2, this issue has not been exposed other than the case in
kernel_page_tables fixed by patch 4.  Since there can be other cases in
future, all patches should go to 4.2 to prevent them to happen.  There is
no issue in 4.1 & older since they cannot set the bit.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
