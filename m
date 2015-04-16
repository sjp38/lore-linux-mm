Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id B30BE6B006C
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 13:39:53 -0400 (EDT)
Received: by wgsk9 with SMTP id k9so88638343wgs.3
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 10:39:53 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id xs6si15137441wjb.6.2015.04.16.10.39.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 16 Apr 2015 10:39:52 -0700 (PDT)
Date: Thu, 16 Apr 2015 18:39:48 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/4] x86, mm: Trace when an IPI is about to be sent
Message-ID: <20150416173948.GR14842@suse.de>
References: <1429179766-26711-1-git-send-email-mgorman@suse.de>
 <1429179766-26711-2-git-send-email-mgorman@suse.de>
 <552FE98F.2080705@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <552FE98F.2080705@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Apr 16, 2015 at 09:55:43AM -0700, Dave Hansen wrote:
> On 04/16/2015 03:22 AM, Mel Gorman wrote:
> > It is easy to trace when an IPI is received to flush a TLB but harder to
> > detect what event sent it. This patch makes it easy to identify the source
> > of IPIs being transmitted for TLB flushes on x86.
> 
> Looks fine to me.  I think I even thought about adding this but didn't
> see an immediate need for it.  I guess this does let you see how many
> IPIs are sent vs. received.
> 

It would but that's not why I wanted it. I wanted a stack track of who
was sending the IPI and I can't get that on the receive side. I could
have used perf probe and some hackery but this seemed useful in itself.

> Reviewed-by: Dave Hansen <dave.hansen@intel.com>

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
