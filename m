Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id C3160280002
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 09:05:17 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id d1so1588283wiv.3
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 06:05:16 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cj10si9463251wjb.141.2014.11.06.06.05.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 06:05:16 -0800 (PST)
Date: Thu, 6 Nov 2014 15:05:15 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [mmotm:master 143/283] mm/slab.c:3260:4: error: implicit
 declaration of function 'slab_free'
Message-ID: <20141106140514.GG7202@dhcp22.suse.cz>
References: <201411060959.OFpcU713%fengguang.wu@intel.com>
 <20141106090845.GA17744@dhcp22.suse.cz>
 <20141106092849.GC4839@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141106092849.GC4839@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

[Dropping kbuild-test from CC]

On Thu 06-11-14 12:28:49, Vladimir Davydov wrote:
> Hi Michal,
> 
> On Thu, Nov 06, 2014 at 10:08:45AM +0100, Michal Hocko wrote:
> > I have encountered the same error as well. We need to move the forward
> > declaration up outside of CONFIG_NUMA:
> 
> Yes, that's my fault, I'm sorry. Thank you for fixing this.

NP.
 
> BTW what do you think about the whole patch set that introduced it -
> https://lkml.org/lkml/2014/11/3/781 - w/o diving deeply into details,
> just by looking at the general idea described in the cover letter?

The series is still stuck in my inbox and I plan to review your shrinker
code first. I hope to get to it ASAP but not sooner than Monday as I
will be off until Sunday.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
