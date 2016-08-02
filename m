Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 78E056B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 14:09:23 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id pp5so311433743pac.3
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 11:09:23 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id xd8si4051037pac.276.2016.08.02.11.09.22
        for <linux-mm@kvack.org>;
        Tue, 02 Aug 2016 11:09:22 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm: Allow disabling deferred struct page
 initialisation
References: <1470143947-24443-1-git-send-email-srikar@linux.vnet.ibm.com>
 <1470143947-24443-2-git-send-email-srikar@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <57A0E1D1.8020608@intel.com>
Date: Tue, 2 Aug 2016 11:09:21 -0700
MIME-Version: 1.0
In-Reply-To: <1470143947-24443-2-git-send-email-srikar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux--foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org

On 08/02/2016 06:19 AM, Srikar Dronamraju wrote:
> Kernels compiled with CONFIG_DEFERRED_STRUCT_PAGE_INIT will initialise
> only certain size memory per node. The certain size takes into account
> the dentry and inode cache sizes. However such a kernel when booting a
> secondary kernel will not be able to allocate the required amount of
> memory to suffice for the dentry and inode caches. This results in
> crashes like the below on large systems such as 32 TB systems.

What's a "secondary kernel"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
