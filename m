Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 96AD26B025E
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 18:23:46 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id y71so141726512pgd.0
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 15:23:46 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id z3si4474442pfd.61.2016.12.15.15.23.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Dec 2016 15:23:45 -0800 (PST)
Date: Thu, 15 Dec 2016 16:23:44 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v3 3/3] mm, dax: move pmd_fault() to take only vmf
 parameter
Message-ID: <20161215232344.GB10460@linux.intel.com>
References: <148183505925.96369.9987658623875784437.stgit@djiang5-desk3.ch.intel.com>
 <148183507090.96369.1341372300913394127.stgit@djiang5-desk3.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <148183507090.96369.1341372300913394127.stgit@djiang5-desk3.ch.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jiang <dave.jiang@intel.com>
Cc: akpm@linux-foundation.org, jack@suse.cz, linux-nvdimm@lists.01.org, david@fromorbit.com, hch@lst.de, linux-mm@kvack.org, tytso@mit.edu, ross.zwisler@linux.intel.com, dan.j.williams@intel.com

On Thu, Dec 15, 2016 at 01:51:11PM -0700, Dave Jiang wrote:
> pmd_fault() and related functions really only need the vmf parameter since
> the additional parameters are all included in the vmf struct. Removing
> additional parameter and simplify pmd_fault() and friends.
> 
> Signed-off-by: Dave Jiang <dave.jiang@intel.com>
 
This seems correct to me.

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
