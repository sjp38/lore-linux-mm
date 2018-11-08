Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id BC4296B0595
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 02:59:38 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id r16-v6so16067384pgv.17
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 23:59:38 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k9-v6si3205626pgc.79.2018.11.07.23.59.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 23:59:37 -0800 (PST)
Date: Thu, 8 Nov 2018 08:59:34 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 4/5] mm, memory_hotplug: print reason for the
 offlining failure
Message-ID: <20181108075934.GL27423@dhcp22.suse.cz>
References: <20181107101830.17405-1-mhocko@kernel.org>
 <20181107101830.17405-5-mhocko@kernel.org>
 <18bd20ff-7b3c-bcf2-042d-5ab59fdd42e1@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <18bd20ff-7b3c-bcf2-042d-5ab59fdd42e1@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Baoquan He <bhe@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 08-11-18 11:53:21, Anshuman Khandual wrote:
> 
> 
> On 11/07/2018 03:48 PM, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > The memory offlining failure reporting is inconsistent and insufficient.
> > Some error paths simply do not report the failure to the log at all.
> > When we do report there are no details about the reason of the failure
> > and there are several of them which makes memory offlining failures
> > hard to debug.
> > 
> > Make sure that the
> > 	memory offlining [mem %#010llx-%#010llx] failed
> > message is printed for all failures and also provide a short textual
> > reason for the failure e.g.
> > 
> > [ 1984.506184] rac1 kernel: memory offlining [mem 0x82600000000-0x8267fffffff] failed due to signal backoff
> > 
> > this tells us that the offlining has failed because of a signal pending
> > aka user intervention.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> It might help to enumerate these failure reason strings and use macros.

Does it really make sense when all of them are on-off things? I would
agree if they were reused somewhere.

-- 
Michal Hocko
SUSE Labs
