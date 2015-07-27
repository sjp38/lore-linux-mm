Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id C7A156B0038
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 03:07:14 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so101855135wib.0
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 00:07:14 -0700 (PDT)
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com. [209.85.212.180])
        by mx.google.com with ESMTPS id gz6si29193183wjc.171.2015.07.27.00.07.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jul 2015 00:07:13 -0700 (PDT)
Received: by wibxm9 with SMTP id xm9so98445311wib.0
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 00:07:12 -0700 (PDT)
Date: Mon, 27 Jul 2015 09:07:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v5 PATCH 8/9] hugetlbfs: add hugetlbfs_fallocate()
Message-ID: <20150727070709.GA11317@dhcp22.suse.cz>
References: <1435019919-29225-1-git-send-email-mike.kravetz@oracle.com>
 <1435019919-29225-9-git-send-email-mike.kravetz@oracle.com>
 <20150724062533.GA4622@dhcp22.suse.cz>
 <55B2655B.4040001@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55B2655B.4040001@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>

On Fri 24-07-15 09:18:35, Mike Kravetz wrote:
> On 07/23/2015 11:25 PM, Michal Hocko wrote:
> >I hope this is the current version of the pathc - I somehow got lost in
> >last submissions where the discussion happens in v4 thread. This version
> >seems to have the same issue:
> 
> Yes, Michal this issue exists in the version put into mmotm and was
> noticed by kbuild test robot and Stephen in linux-next build.
> 
> Your patch below is the most obvious.  Thanks!  However, is this
> the preferred method of handling this type of issue?  Is it
> preferred to create wrappers for the code which handles numa
> policy?

Yes that would be preferable. My "work around" was just to make my git
mirror of mmotm compilable. I am not sure whether Andrew picked my patch
but it will certainly get replaced by a cleaner version.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
