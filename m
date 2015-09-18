Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id F2AD66B0038
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 05:28:30 -0400 (EDT)
Received: by lbpo4 with SMTP id o4so22269739lbp.2
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 02:28:30 -0700 (PDT)
Received: from mail-la0-x232.google.com (mail-la0-x232.google.com. [2a00:1450:4010:c03::232])
        by mx.google.com with ESMTPS id h5si5298839laf.45.2015.09.18.02.28.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Sep 2015 02:28:29 -0700 (PDT)
Received: by lamp12 with SMTP id p12so26450817lam.0
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 02:28:29 -0700 (PDT)
Date: Fri, 18 Sep 2015 12:28:27 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm/swapfile: fix swapoff vs. software dirty bits
Message-ID: <20150918092827.GD2035@uranus>
References: <1442480339-26308-1-git-send-email-schwidefsky@de.ibm.com>
 <1442480339-26308-2-git-send-email-schwidefsky@de.ibm.com>
 <20150917193152.GJ2000@uranus>
 <20150918085835.597fb036@mschwide>
 <20150918071549.GA2035@uranus>
 <20150918102001.0e0389c7@mschwide>
 <20150918085301.GC2035@uranus>
 <20150918111038.58c3a8de@mschwide>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150918111038.58c3a8de@mschwide>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Fri, Sep 18, 2015 at 11:10:38AM +0200, Martin Schwidefsky wrote:
> > 
> > You know, these are only two lines where we use _PAGE_SOFT_DIRTY
> > directly, so I don't see much point in adding 22 lines of code
> > for that. Maybe we can leave it as is?
>  
> Only x86 has pte_clear_flags. And the two lines require that there is exactly
> one bit in the PTE for soft-dirty. An alternative encoding will not be allowed.
> And the current set of primitives is asymmetric, there are functions to query
> and set the bit pte_soft_dirty and pte_mksoft_dirty but no function to clear
> the bit.

OK, Martin, gimme some time please, I don't have code at my hands, so once
I'm back, I'll take a precise look, ok?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
