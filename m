Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 949986B04C6
	for <linux-mm@kvack.org>; Tue,  5 Sep 2017 11:50:03 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 40so5194227wrv.4
        for <linux-mm@kvack.org>; Tue, 05 Sep 2017 08:50:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k19si521905wmi.39.2017.09.05.08.50.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Sep 2017 08:50:02 -0700 (PDT)
Date: Tue, 5 Sep 2017 16:50:00 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC] mm/tlbbatch: Introduce arch_tlbbatch_should_defer()
Message-ID: <20170905155000.gasnjvor4slvgkst@suse.de>
References: <20170905144540.3365-1-khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170905144540.3365-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

On Tue, Sep 05, 2017 at 08:15:40PM +0530, Anshuman Khandual wrote:
> The entire scheme of deferred TLB flush in reclaim path rests on the
> fact that the cost to refill TLB entries is less than flushing out
> individual entries by sending IPI to remote CPUs. But architecture
> can have different ways to evaluate that. Hence apart from checking
> TTU_BATCH_FLUSH in the TTU flags, rest of the decision should be
> architecture specific.
> 
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>

There is only one arch implementation given and if an arch knows that
the flush should not be deferred then why would it implement support in
the first place? I'm struggling to see the point of the patch.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
