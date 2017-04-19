Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 951476B0390
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 18:34:32 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id l11so39064718iod.15
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 15:34:32 -0700 (PDT)
Received: from mail-io0-x22c.google.com (mail-io0-x22c.google.com. [2607:f8b0:4001:c06::22c])
        by mx.google.com with ESMTPS id 69si16701930itv.89.2017.04.19.15.34.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 15:34:31 -0700 (PDT)
Received: by mail-io0-x22c.google.com with SMTP id k87so40793997ioi.0
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 15:34:31 -0700 (PDT)
Date: Wed, 19 Apr 2017 15:34:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm,page_alloc: Split stall warning and failure
 warning.
In-Reply-To: <20170419132212.GA3514@redhat.com>
Message-ID: <alpine.DEB.2.10.1704191532460.94753@chino.kir.corp.google.com>
References: <1491825493-8859-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp> <20170410150308.c6e1a0213c32e6d587b33816@linux-foundation.org> <alpine.DEB.2.10.1704171539190.46404@chino.kir.corp.google.com> <201704182049.BIE34837.FJOFOMFOQSLHVt@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.10.1704181435560.112481@chino.kir.corp.google.com> <20170419111342.GF29789@dhcp22.suse.cz> <20170419132212.GA3514@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, hannes@cmpxchg.org

On Wed, 19 Apr 2017, Stanislaw Gruszka wrote:

> mem= shrink upper memory limit, debug_guardpage_minorder= fragments
> available physical memory (deliberately to catch unintended access).
> 

Agreed, and allocation failure warnings don't need to cache the mem= 
kernel parameter and determine the difference between true system RAM and 
configured system RAM to try to determine if a warning is appropriate lol.  
Let's please leave the check as Stanislaw has repeatedly requested.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
