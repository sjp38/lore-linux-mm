Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 09C7D6B4C9C
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 12:25:35 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id w11-v6so2434225plq.8
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 09:25:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f8-v6si4077242plb.381.2018.08.29.09.25.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Aug 2018 09:25:33 -0700 (PDT)
Date: Wed, 29 Aug 2018 18:25:28 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 2/2] mm: thp: fix transparent_hugepage/defrag = madvise
 || always
Message-ID: <20180829162528.GD10223@dhcp22.suse.cz>
References: <20180822155250.GP13047@redhat.com>
 <20180823105253.GB29735@dhcp22.suse.cz>
 <20180828075321.GD10223@dhcp22.suse.cz>
 <20180828081837.GG10223@dhcp22.suse.cz>
 <D5F4A33C-0A37-495C-9468-D6866A862097@cs.rutgers.edu>
 <20180829142816.GX10223@dhcp22.suse.cz>
 <20180829143545.GY10223@dhcp22.suse.cz>
 <82CA00EB-BF8E-4137-953B-8BC4B74B99AF@cs.rutgers.edu>
 <20180829154744.GC10223@dhcp22.suse.cz>
 <39BE14E6-D0FB-428A-B062-8B5AEDC06E61@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <39BE14E6-D0FB-428A-B062-8B5AEDC06E61@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>

On Wed 29-08-18 12:06:48, Zi Yan wrote:
> The warning goes away with this change. I am OK with this patch (plus the original one you sent out,
> which could be merged with this one).

I will respin the patch, update the changelog and repost. Tomorrow I
hope.



-- 
Michal Hocko
SUSE Labs
