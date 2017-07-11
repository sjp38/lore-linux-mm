Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 17E2B6B0550
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 17:25:49 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 4so1030538wrc.15
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 14:25:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j187si350213wmj.76.2017.07.11.14.25.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Jul 2017 14:25:48 -0700 (PDT)
Date: Tue, 11 Jul 2017 23:25:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] vmemmap, memory_hotplug: fallback to base pages for vmmap
Message-ID: <20170711212544.GA25122@dhcp22.suse.cz>
References: <20170711134204.20545-1-mhocko@kernel.org>
 <20170711142558.GE11936@dhcp22.suse.cz>
 <20170711172623.GB961@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170711172623.GB961@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Cristopher Lameter <cl@linux.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 11-07-17 13:26:23, Johannes Weiner wrote:
> Hi Michael,
> 
> On Tue, Jul 11, 2017 at 04:25:58PM +0200, Michal Hocko wrote:
> > Ohh, scratch that. The patch is bogus. I have completely missed that
> > vmemmap_populate_hugepages already falls back to
> > vmemmap_populate_basepages. I have to revisit the bug report I have
> > received to see what happened apart from the allocation warning. Maybe
> > we just want to silent that warning.
> 
> Yep, this should be fixed in 8e2cdbcb86b0 ("x86-64: fall back to
> regular page vmemmap on allocation failure").
> 
> I figure it's good to keep some sort of warning there, though, as it
> could have performance implications when we fall back to base pages.

Yeah, but I am not really sure the allocation warning is the right thing
here because it is just too verbose. If you consider that we will get
this warning for each memory section (128MB or 2GB)... I guess the
existing
pr_warn_once("vmemmap: falling back to regular page backing\n");

or maybe make it pr_warn should be enough. What do you think?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
