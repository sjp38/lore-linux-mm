Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0184F6B4D4B
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 15:24:57 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c25-v6so2574430edb.12
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 12:24:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k5-v6si3815273edd.380.2018.08.29.12.24.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Aug 2018 12:24:54 -0700 (PDT)
Date: Wed, 29 Aug 2018 21:24:51 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
Message-ID: <20180829192451.GG10223@dhcp22.suse.cz>
References: <20180823105253.GB29735@dhcp22.suse.cz>
 <20180828075321.GD10223@dhcp22.suse.cz>
 <20180828081837.GG10223@dhcp22.suse.cz>
 <D5F4A33C-0A37-495C-9468-D6866A862097@cs.rutgers.edu>
 <20180829142816.GX10223@dhcp22.suse.cz>
 <20180829143545.GY10223@dhcp22.suse.cz>
 <82CA00EB-BF8E-4137-953B-8BC4B74B99AF@cs.rutgers.edu>
 <20180829154744.GC10223@dhcp22.suse.cz>
 <39BE14E6-D0FB-428A-B062-8B5AEDC06E61@cs.rutgers.edu>
 <20180829162528.GD10223@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180829162528.GD10223@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>

On Wed 29-08-18 18:25:28, Michal Hocko wrote:
> On Wed 29-08-18 12:06:48, Zi Yan wrote:
> > The warning goes away with this change. I am OK with this patch (plus the original one you sent out,
> > which could be merged with this one).
> 
> I will respin the patch, update the changelog and repost. Tomorrow I
> hope.

Here is the v2
