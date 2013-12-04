Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f45.google.com (mail-qe0-f45.google.com [209.85.128.45])
	by kanga.kvack.org (Postfix) with ESMTP id 379AE6B003D
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 11:07:35 -0500 (EST)
Received: by mail-qe0-f45.google.com with SMTP id 6so16386701qea.18
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 08:07:35 -0800 (PST)
Received: from mail-qa0-x232.google.com (mail-qa0-x232.google.com [2607:f8b0:400d:c00::232])
        by mx.google.com with ESMTPS id d5si28419382qcj.107.2013.12.04.08.07.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Dec 2013 08:07:33 -0800 (PST)
Received: by mail-qa0-f50.google.com with SMTP id i13so6848521qae.9
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 08:07:33 -0800 (PST)
Date: Wed, 4 Dec 2013 11:07:30 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 08/23] mm/memblock: Add memblock memory allocation apis
Message-ID: <20131204160730.GQ3158@htj.dyndns.org>
References: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com>
 <1386037658-3161-9-git-send-email-santosh.shilimkar@ti.com>
 <20131203232445.GX8277@htj.dyndns.org>
 <529F5047.50309@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <529F5047.50309@ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Grygorii Strashko <grygorii.strashko@ti.com>

Hello,

On Wed, Dec 04, 2013 at 10:54:47AM -0500, Santosh Shilimkar wrote:
> Well as you know there are architectures still using bootmem even after
> this series. Changing MAX_NUMNODES to NUMA_NO_NODE is too invasive and
> actually should be done in a separate series. As commented, the best
> time to do that would be when all remaining architectures moves to
> memblock.
> 
> Just to give you perspective, look at the patch end of the email which
> Grygorrii cooked up. It doesn't cover all the users of MAX_NUMNODES
> and we are bot even sure whether the change is correct and its
> impact on the code which we can't even tests. I would really want to
> avoid touching all the architectures and keep the scope of the series
> to core code as we aligned initially.
> 
> May be you have better idea to handle this change so do
> let us know how to proceed with it. With such a invasive change the
> $subject series can easily get into circles again :-(

But we don't have to use MAX_NUMNODES for the new interface, no?  Or
do you think that it'd be more confusing because it ends up mixing the
two?  It kinda really bothers me this patchset is expanding the usage
of the wrong constant with only very far-out plan to fix that.  All
archs converting to nobootmem will take a *long* time, that is, if
that happens at all.  I don't really care about the order of things
happening but "this is gonna be fixed when everyone moves off
MAX_NUMNODES" really isn't good enough.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
