Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id E10AE6B0035
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 18:45:42 -0400 (EDT)
Received: by mail-ig0-f170.google.com with SMTP id h3so2511767igd.3
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 15:45:42 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r18si17740807icg.26.2014.07.31.15.45.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jul 2014 15:45:42 -0700 (PDT)
Date: Thu, 31 Jul 2014 15:45:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: BUG when __kmap_atomic_idx equals KM_TYPE_NR
Message-Id: <20140731154540.441ab79ff32ae5c10f64bcbd@linux-foundation.org>
In-Reply-To: <53DA0C5A.3010409@codeaurora.org>
References: <1406787871-2951-1-git-send-email-cpandya@codeaurora.org>
	<alpine.DEB.2.02.1407310001360.18238@chino.kir.corp.google.com>
	<53DA0C5A.3010409@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chintan Pandya <cpandya@codeaurora.org>
Cc: David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 31 Jul 2014 14:58:58 +0530 Chintan Pandya <cpandya@codeaurora.org> wrote:

> >
> > I think Andrew's comment earlier was referring to the changelog only and
> > not the patch, which looked correct.
> 
> I think Andrew asked for a BUG case details also to justify the 
> overhead. But we have never encountered that BUG case. Present patch is 
> only logical fix to the code. However, in the fast path, if such 
> overhead is allowed, I can move BUG_ON out of any debug configs. 
> Otherwise, as per Andrew's suggestion, I will convert DEBUG_HIGHMEM into 
> DEBUG_VM which is used more frequently.

The v1 patch added a small amount of overhead to kmap_atomic() for what
is evidently a very small benefit.

Yes, I suggest we remove CONFIG_DEBUG_HIGHMEM from the kernel entirely
and switch all CONFIG_DEBUG_HIGHMEM sites to use CONFIG_DEBUG_VM.  That way
the BUG_ON which you believe is useful will be tested by more people
more often.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
