Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0A1456B4FF8
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 02:47:37 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k16-v6so3245719ede.6
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 23:47:36 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f16-v6si3207603edc.98.2018.08.29.23.47.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Aug 2018 23:47:35 -0700 (PDT)
Date: Thu, 30 Aug 2018 08:47:32 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
Message-ID: <20180830064732.GA2656@dhcp22.suse.cz>
References: <20180828075321.GD10223@dhcp22.suse.cz>
 <20180828081837.GG10223@dhcp22.suse.cz>
 <D5F4A33C-0A37-495C-9468-D6866A862097@cs.rutgers.edu>
 <20180829142816.GX10223@dhcp22.suse.cz>
 <20180829143545.GY10223@dhcp22.suse.cz>
 <82CA00EB-BF8E-4137-953B-8BC4B74B99AF@cs.rutgers.edu>
 <20180829154744.GC10223@dhcp22.suse.cz>
 <39BE14E6-D0FB-428A-B062-8B5AEDC06E61@cs.rutgers.edu>
 <20180829162528.GD10223@dhcp22.suse.cz>
 <20180829192451.GG10223@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180829192451.GG10223@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>

I forgot mpol_cond_put...
