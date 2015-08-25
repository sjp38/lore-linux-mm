Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 29F489003C7
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 10:18:02 -0400 (EDT)
Received: by oiev193 with SMTP id v193so101359124oie.3
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 07:18:01 -0700 (PDT)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id mn3si13745577oeb.66.2015.08.25.07.17.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 07:18:01 -0700 (PDT)
Message-ID: <1440512146.14237.15.camel@hp.com>
Subject: Re: [PATCH v3 3/10] x86/asm: Fix pud/pmd interfaces to handle large
 PAT bit
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 25 Aug 2015 08:15:46 -0600
In-Reply-To: <alpine.DEB.2.11.1508251015180.15006@nanos>
References: <1438811013-30983-1-git-send-email-toshi.kani@hp.com>
	 <1438811013-30983-4-git-send-email-toshi.kani@hp.com>
	 <alpine.DEB.2.11.1508251015180.15006@nanos>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: hpa@zytor.com, mingo@redhat.com, akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hp.com

On Tue, 2015-08-25 at 10:16 +0200, Thomas Gleixner wrote:
> On Wed, 5 Aug 2015, Toshi Kani wrote:
> 
> > The PAT bit gets relocated to bit 12 when PUD and PMD mappings are
> > used.  This bit 12, however, is not covered by PTE_FLAGS_MASK, which
> > is corrently used for masking pfn and flags for all cases.
> > 
> > Fix pud/pmd interfaces to handle pfn and flags properly by using
> > P?D_PAGE_MASK when PUD/PMD mappings are used, i.e. PSE bit is set.
> 
> Can you please split that into a patch introducing and describing the
> new mask helper functions and a second one making use of it?

Will do.  I will send out v4 patchset today with this update (and the patch
01 update). 

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
