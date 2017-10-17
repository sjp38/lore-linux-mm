Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 798CB6B0038
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 18:39:11 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id z69so3072885ita.0
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 15:39:11 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f203sor5571574iof.329.2017.10.17.15.39.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Oct 2017 15:39:10 -0700 (PDT)
Date: Tue, 17 Oct 2017 15:39:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/3] mm: oom: show unreclaimable slab info when unreclaimable
 slabs > user memory
In-Reply-To: <a324af3f-f5c4-8c26-400e-ca3a590db37d@alibaba-inc.com>
Message-ID: <alpine.DEB.2.10.1710171537170.141832@chino.kir.corp.google.com>
References: <1507656303-103845-1-git-send-email-yang.s@alibaba-inc.com> <1507656303-103845-4-git-send-email-yang.s@alibaba-inc.com> <alpine.DEB.2.10.1710161709460.140151@chino.kir.corp.google.com> <20171017074448.qupoajpjbcfdpz5z@dhcp22.suse.cz>
 <alpine.DEB.2.10.1710171357260.100885@chino.kir.corp.google.com> <7ac4f9f6-3c3d-c1df-e60f-a519650cd330@alibaba-inc.com> <alpine.DEB.2.10.1710171449000.100885@chino.kir.corp.google.com> <a324af3f-f5c4-8c26-400e-ca3a590db37d@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: Michal Hocko <mhocko@kernel.org>, cl@linux.com, penberg@kernel.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 18 Oct 2017, Yang Shi wrote:

> > Yes, this should catch occurrences of "huge unreclaimable slabs", right?
> 
> Yes, it sounds so. Although single "huge" unreclaimable slab might not result
> in excessive slabs use in a whole, but this would help to filter out "small"
> unreclaimable slab.
> 

Keep in mind this is regardless of SLAB_RECLAIM_ACCOUNT: your patch has 
value beyond only unreclaimable slab, it can also be used to show 
instances where the oom killer was invoked without properly reclaiming 
slab.  If the total footprint of a slab cache exceeds 5%, I think a line 
should be emitted unconditionally to the kernel log.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
