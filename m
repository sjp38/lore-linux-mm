Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8FA0F6B0036
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 07:13:34 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so751686pbb.27
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 04:13:34 -0700 (PDT)
Received: by mail-ea0-f174.google.com with SMTP id z15so322457ead.5
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 04:13:30 -0700 (PDT)
Date: Wed, 9 Oct 2013 13:13:28 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/63] Basic scheduler support for automatic NUMA
 balancing V9
Message-ID: <20131009111328.GB19610@gmail.com>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
 <20131009110353.GA19370@gmail.com>
 <20131009111146.GA19610@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131009111146.GA19610@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Ingo Molnar <mingo@kernel.org> wrote:

>  mmzone.c:
> 
>   #if defined(CONFIG_NUMA_BALANCING) && !defined(LAST_CPUPID_IN_PAGE_FLAGS)
> 
> Note the missing 'NOT_' in the latter line. I've changed it to:
> 
>   #if defined(CONFIG_NUMA_BALANCING) && defined(LAST_CPUPID_NOT_IN_PAGE_FLAGS)

Actually, I think it should be:

   #if defined(CONFIG_NUMA_BALANCING) && !defined(LAST_CPUPID_NOT_IN_PAGE_FLAGS)

I'll fold back this fix to keep it bisectable on 32-bit platforms.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
