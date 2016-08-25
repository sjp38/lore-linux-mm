Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id B46C86B0279
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 15:50:57 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id j124so1879476ith.3
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 12:50:57 -0700 (PDT)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [69.252.207.38])
        by mx.google.com with ESMTPS id m3si19936031iof.58.2016.08.25.12.50.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Aug 2016 12:50:56 -0700 (PDT)
Date: Thu, 25 Aug 2016 14:49:53 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: what is the purpose of SLAB and SLUB
In-Reply-To: <20160825073207.GE4230@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1608251444440.10766@east.gentwo.org>
References: <1471458050-29622-1-git-send-email-aruna.ramakrishna@oracle.com> <20160818115218.GJ30162@dhcp22.suse.cz> <20160823021303.GB17039@js1304-P5Q-DELUXE> <20160823153807.GN23577@dhcp22.suse.cz> <8760qr8orh.fsf@tassilo.jf.intel.com>
 <alpine.DEB.2.20.1608242302290.1837@east.gentwo.org> <20160825073207.GE4230@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andi Kleen <andi@firstfloor.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Aruna Ramakrishna <aruna.ramakrishna@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Jiri Slaby <jslaby@suse.cz>

On Thu, 25 Aug 2016, Michal Hocko wrote:
> I can completely see how having multiple allocators (schedulers etc...)
> Because as of now, most users are using whatever is the default (SLUB
> for some and never documented reason) or what their distributions come
> up with. This means that we have quite a lot of code which only few
> people understand deeply. Some features which are added on top need much
> more testing to cover both allocators or we are risking subtle
> regressions.

I think the default is clear and advisable to use. The debugging features
in SLAB f.e. are problematic and I have had to ask at times to retry with
SLUB in order to find a subtle issue.

I think the main activity nowadays is to make SLAB competitive by adopting
methods from SLUB. Maybe that will work. But then concepts from SLAB can
also be used in SLUB and enhance speed there.

> Flexibility is always good but there comes a maintenance burden. Both
> should be weighed properly.

Well I thought we had that under control. SLAB is a legacy issue in many
ways and people are used to the problems with debuggability if they still
use that. There is always the simple way to just switch to SLUB
temporarily in order to find issues.


> Sure, but even after attempts to make some code common we are still at
> $ wc -l mm/slab.c mm/slub.c
> 	4479 mm/slab.c
> 	5727 mm/slub.c
> 	10206 total
>
> quite a lot, don't you think?

Well the code is always growing since features are being added like
cgroups support and the batch allocation/freeing that is used to improve
the network performance. I think this is actually quite reasonable
compared with other parts of our kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
