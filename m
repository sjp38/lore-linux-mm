Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id B7B5F6B0038
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 17:50:05 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id 97so3028605iok.19
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 14:50:05 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y2sor2391389ita.19.2017.10.17.14.50.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Oct 2017 14:50:04 -0700 (PDT)
Date: Tue, 17 Oct 2017 14:50:02 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/3] mm: oom: show unreclaimable slab info when unreclaimable
 slabs > user memory
In-Reply-To: <7ac4f9f6-3c3d-c1df-e60f-a519650cd330@alibaba-inc.com>
Message-ID: <alpine.DEB.2.10.1710171449000.100885@chino.kir.corp.google.com>
References: <1507656303-103845-1-git-send-email-yang.s@alibaba-inc.com> <1507656303-103845-4-git-send-email-yang.s@alibaba-inc.com> <alpine.DEB.2.10.1710161709460.140151@chino.kir.corp.google.com> <20171017074448.qupoajpjbcfdpz5z@dhcp22.suse.cz>
 <alpine.DEB.2.10.1710171357260.100885@chino.kir.corp.google.com> <7ac4f9f6-3c3d-c1df-e60f-a519650cd330@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="1113868975-1429983982-1508276951=:100885"
Content-ID: <alpine.DEB.2.10.1710171449290.100885@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: Michal Hocko <mhocko@kernel.org>, cl@linux.com, penberg@kernel.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--1113868975-1429983982-1508276951=:100885
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.10.1710171449291.100885@chino.kir.corp.google.com>

On Wed, 18 Oct 2017, Yang Shi wrote:

> > > > Please simply dump statistics for all slab caches where the memory
> > > > footprint is greater than 5% of system memory.
> > > 
> > > Unconditionally? User controlable?
> > 
> > Unconditionally, it's a single line of output per slab cache and there
> > can't be that many of them if each is using >5% of memory.
> 
> Soi 1/4 ?you mean just dump the single slab cache if its size > 5% of system memory
> instead of all slab caches?
> 

Yes, this should catch occurrences of "huge unreclaimable slabs", right?
--1113868975-1429983982-1508276951=:100885--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
