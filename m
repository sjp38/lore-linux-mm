Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id CCBBF6B0002
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 22:02:59 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id um15so1839516pbc.0
        for <linux-mm@kvack.org>; Wed, 20 Mar 2013 19:02:59 -0700 (PDT)
Date: Thu, 21 Mar 2013 10:02:47 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [patch 1/4 v3]swap: change block allocation algorithm for SSD
Message-ID: <20130321020247.GA27300@kernel.org>
References: <20130221021710.GA32580@kernel.org>
 <alpine.LNX.2.00.1303191329490.5966@eggly.anvils>
 <20130320135858.179ceef83b43ce434373d55b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130320135858.179ceef83b43ce434373d55b@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Rafael Aquini <aquini@redhat.com>, riel@redhat.com, minchan@kernel.org, kmpark@infradead.org, linux-mm@kvack.org

On Wed, Mar 20, 2013 at 01:58:58PM -0700, Andrew Morton wrote:
> On Tue, 19 Mar 2013 13:50:57 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:
> 
> > I find it a bit confusing that we now have these two different clustering
> > strategies in scan_swap_map(), one for SSD and one for the rest; and it's
> > not immediately obvious what's used for what.
> 
> Yes, having two separation allocation paths is bad and we should work
> to avoid it, please.  Sooner rather than later (which sometimes never
> comes).
> 
> We have a few theories about how the SSD code will worsen things for
> rotating disks.  But have those theories been tested?  Any performance
> results?  If regressions *are* observed, what is the feasibility of
> fixing them up?

The problem is I don't know which workload is proper to measure the cluster
change impact for rotating disks. That would only happen when swap is
fragmented but not too much. I'd assume the impact isn't big, but who knows. If
you have something I can test, I'm happy to do.

Will address other issues soon.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
