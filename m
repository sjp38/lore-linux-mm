Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0D19B6B0259
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 03:34:12 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id l68so23636870wml.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 00:34:12 -0800 (PST)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id ur8si14704329wjc.174.2016.03.03.00.34.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Mar 2016 00:34:10 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 6A3D02F8174
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 08:34:10 +0000 (UTC)
Date: Thu, 3 Mar 2016 08:34:08 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH RFC 1/2] mm: meminit: initialise more memory for
 inode/dentry hash tables in early boot
Message-ID: <20160303083408.GI2854@techsingularity.net>
References: <1456988501-29046-1-git-send-email-zhlcindy@gmail.com>
 <1456988501-29046-2-git-send-email-zhlcindy@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1456988501-29046-2-git-send-email-zhlcindy@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zhang <zhlcindy@gmail.com>
Cc: mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Li Zhang <zhlcindy@linux.vnet.ibm.com>

On Thu, Mar 03, 2016 at 03:01:40PM +0800, Li Zhang wrote:
> From: Li Zhang <zhlcindy@linux.vnet.ibm.com>
> 
> This patch is based on Mel Gorman's old patch in the mailing list,
> https://lkml.org/lkml/2015/5/5/280 which is dicussed but it is
> fixed with a completion to wait for all memory initialised in
> page_alloc_init_late(). It is to fix the oom problem on X86
> with 24TB memory which allocates memory in late initialisation.
> But for Power platform with 32TB memory, it causes a call trace
> in vfs_caches_init->inode_init() and inode hash table needs more
> memory.
> So this patch allocates 1GB for 0.25TB/node for large system
> as it is mentioned in https://lkml.org/lkml/2015/5/1/627
> 

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
