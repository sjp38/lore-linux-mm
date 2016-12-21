Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6FBB76B0399
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 07:36:07 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id i131so30445693wmf.3
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 04:36:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id to13si27356064wjb.192.2016.12.21.04.36.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Dec 2016 04:36:06 -0800 (PST)
Date: Wed, 21 Dec 2016 13:36:03 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v4 1/3] dax: masking off __GFP_FS in fs DAX handlers
Message-ID: <20161221123603.GA10320@quack2.suse.cz>
References: <148184524161.184728.14005697153880489871.stgit@djiang5-desk3.ch.intel.com>
 <20161216010730.GY4219@dastard>
 <20161216161916.GA2410@linux.intel.com>
 <20161216220450.GZ4219@dastard>
 <20161219195302.GI17598@quack2.suse.cz>
 <20161219211711.GD4219@dastard>
 <20161220101352.GE3769@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161220101352.GE3769@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dave Jiang <dave.jiang@intel.com>, akpm@linux-foundation.org, linux-nvdimm@lists.01.org, hch@lst.de, linux-mm@kvack.org, tytso@mit.edu, dan.j.williams@intel.com

On Tue 20-12-16 11:13:52, Michal Hocko wrote:
> I am not fully familiar with the DAX changes which started this
> discussion but if there is a reclaim recursion problem from within the
> fault path then the scope api sounds like a good fit here.
> 
> [1] http://lkml.kernel.org/r/20161215140715.12732-1-mhocko@kernel.org

Yes, once your scope API and associated ext4 changes are in, we can stop
playing tricks with gfp_mask in DAX code at least for ext4.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
