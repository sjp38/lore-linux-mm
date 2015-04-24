Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8C0266B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 11:16:57 -0400 (EDT)
Received: by wgso17 with SMTP id o17so54261888wgs.1
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 08:16:57 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gk6si4750649wib.34.2015.04.24.08.16.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Apr 2015 08:16:56 -0700 (PDT)
Date: Fri, 24 Apr 2015 16:16:52 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/6] TLB flush multiple pages with a single IPI v3
Message-ID: <20150424151652.GC2449@suse.de>
References: <1429612880-21415-1-git-send-email-mgorman@suse.de>
 <553A573E.2000608@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <553A573E.2000608@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Apr 24, 2015 at 04:46:22PM +0200, Vlastimil Babka wrote:
> On 04/21/2015 12:41 PM, Mel Gorman wrote:
> >Changelog since V2
> >o Ensure TLBs are flushed before pages are freed		(mel)
> 
> I admit not reading all the patches thoroughly, but doesn't this
> change of ordering mean that you no longer need the architectural
> guarantee discussed in patch 2?

No. If we unmap a page to write it to disk then we cannot allow a CPU to
write to the physical page being written through a cached entry.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
