Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id B35496B0069
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 16:16:36 -0400 (EDT)
Received: by mail-ie0-f173.google.com with SMTP id tp5so1156558ieb.32
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 13:16:36 -0700 (PDT)
Received: from mail-ie0-x232.google.com (mail-ie0-x232.google.com [2607:f8b0:4001:c03::232])
        by mx.google.com with ESMTPS id e9si25385738igi.24.2014.10.01.13.16.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 01 Oct 2014 13:16:35 -0700 (PDT)
Received: by mail-ie0-f178.google.com with SMTP id rl12so1117724iec.23
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 13:16:35 -0700 (PDT)
Date: Wed, 1 Oct 2014 13:16:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm, compaction: using uninitialized_var insteads setting
 'flags' to 0 directly.
In-Reply-To: <542A5B5B.7060207@suse.cz>
Message-ID: <alpine.DEB.2.02.1410011314180.21593@chino.kir.corp.google.com>
References: <1411961425-8045-1-git-send-email-Li.Xiubo@freescale.com> <542A5B5B.7060207@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Xiubo Li <Li.Xiubo@freescale.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, minchan@kernel.org

On Tue, 30 Sep 2014, Vlastimil Babka wrote:

> On 09/29/2014 05:30 AM, Xiubo Li wrote:
> > Setting 'flags' to zero will be certainly a misleading way to avoid
> > warning of 'flags' may be used uninitialized. uninitialized_var is
> > a correct way because the warning is a false possitive.
> 
> Agree.
> 
> > Signed-off-by: Xiubo Li <Li.Xiubo@freescale.com>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 

I thought we just discussed this when 
mm-compaction-fix-warning-of-flags-may-be-used-uninitialized.patch was 
merged and, although I liked it, it was stated that we shouldn't add any 
new users of uninitialized_var().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
