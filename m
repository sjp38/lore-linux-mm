Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id A1EF76B0038
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 16:59:41 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id f187so2811388itb.6
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 13:59:41 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w64sor4793324itg.140.2017.10.17.13.59.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Oct 2017 13:59:40 -0700 (PDT)
Date: Tue, 17 Oct 2017 13:59:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/3] mm: oom: show unreclaimable slab info when unreclaimable
 slabs > user memory
In-Reply-To: <20171017074448.qupoajpjbcfdpz5z@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1710171357260.100885@chino.kir.corp.google.com>
References: <1507656303-103845-1-git-send-email-yang.s@alibaba-inc.com> <1507656303-103845-4-git-send-email-yang.s@alibaba-inc.com> <alpine.DEB.2.10.1710161709460.140151@chino.kir.corp.google.com> <20171017074448.qupoajpjbcfdpz5z@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Yang Shi <yang.s@alibaba-inc.com>, cl@linux.com, penberg@kernel.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 17 Oct 2017, Michal Hocko wrote:

> On Mon 16-10-17 17:15:31, David Rientjes wrote:
> > Please simply dump statistics for all slab caches where the memory 
> > footprint is greater than 5% of system memory.
> 
> Unconditionally? User controlable?

Unconditionally, it's a single line of output per slab cache and there 
can't be that many of them if each is using >5% of memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
