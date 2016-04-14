Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7985A6B007E
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 15:56:31 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u190so147507241pfb.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 12:56:31 -0700 (PDT)
Received: from mail-pf0-x234.google.com (mail-pf0-x234.google.com. [2607:f8b0:400e:c00::234])
        by mx.google.com with ESMTPS id 74si8878555pfk.37.2016.04.14.12.56.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Apr 2016 12:56:30 -0700 (PDT)
Received: by mail-pf0-x234.google.com with SMTP id c20so49006940pfc.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 12:56:30 -0700 (PDT)
Date: Thu, 14 Apr 2016 12:56:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 01/19] tree wide: get rid of __GFP_REPEAT for order-0
 allocations part I
In-Reply-To: <1460372892-8157-2-git-send-email-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.10.1604141255020.6593@chino.kir.corp.google.com>
References: <1460372892-8157-1-git-send-email-mhocko@kernel.org> <1460372892-8157-2-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org

On Mon, 11 Apr 2016, Michal Hocko wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> __GFP_REPEAT has a rather weak semantic but since it has been introduced
> around 2.6.12 it has been ignored for low order allocations. Yet we have
> the full kernel tree with its usage for apparently order-0 allocations.
> This is really confusing because __GFP_REPEAT is explicitly documented
> to allow allocation failures which is a weaker semantic than the current
> order-0 has (basically nofail).
> 
> Let's simply drop __GFP_REPEAT from those places. This would allow
> to identify place which really need allocator to retry harder and
> formulate a more specific semantic for what the flag is supposed to do
> actually.
> 
> Cc: linux-arch@vger.kernel.org
> Signed-off-by: Michal Hocko <mhocko@suse.com>

I did exactly this before, and Andrew objected saying that __GFP_REPEAT 
may not be needed for the current page allocator's implementation but 
could with others and that setting __GFP_REPEAT for an allocation 
provided useful information with regards to intent.  At the time, I 
attempted to eliminate __GFP_REPEAT entirely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
