Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3DB256810B5
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 14:07:53 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id c190so39650574ith.3
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 11:07:53 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [69.252.207.41])
        by mx.google.com with ESMTPS id p206si643413iod.10.2017.07.11.11.07.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 11:07:52 -0700 (PDT)
Date: Tue, 11 Jul 2017 13:06:50 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] vmemmap, memory_hotplug: fallback to base pages for
 vmmap
In-Reply-To: <20170711172623.GB961@cmpxchg.org>
Message-ID: <alpine.DEB.2.20.1707111304090.3575@east.gentwo.org>
References: <20170711134204.20545-1-mhocko@kernel.org> <20170711142558.GE11936@dhcp22.suse.cz> <20170711172623.GB961@cmpxchg.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, 11 Jul 2017, Johannes Weiner wrote:

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

If someone gets to work on it then maybe also add giant page support?

We already have systems with terabytes of memory and one 1G vmemmap page
would map 128G of memory leading to a significant reduction in the use of
TLBs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
