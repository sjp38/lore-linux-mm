Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1ECD16B026D
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 03:47:53 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id t15so701878wmh.3
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 00:47:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k28si638162wmh.245.2018.01.19.00.47.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Jan 2018 00:47:51 -0800 (PST)
Date: Fri, 19 Jan 2018 09:47:48 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [bug report] hugetlb, mempolicy: fix the mbind hugetlb migration
Message-ID: <20180119084748.GQ6584@dhcp22.suse.cz>
References: <20180109200539.g7chrnzftxyn3nom@mwanda>
 <20180110104712.GR1732@dhcp22.suse.cz>
 <20180117121801.GE2900@dhcp22.suse.cz>
 <396fb669-3466-3c31-51a1-6c483351e0ce@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <396fb669-3466-3c31-51a1-6c483351e0ce@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mike Kravetz <mike.kravetz@oracle.com>

On Wed 17-01-18 23:15:03, Naoya Horiguchi wrote:
> On 01/17/2018 09:18 PM, Michal Hocko wrote:
> > On Wed 10-01-18 11:47:12, Michal Hocko wrote:
> >> [CC Mike and Naoya]
> > 
> > ping
> > 
> >> From 7227218bd526cceb954a688727d78af0b5874e18 Mon Sep 17 00:00:00 2001
> >> From: Michal Hocko <mhocko@suse.com>
> >> Date: Wed, 10 Jan 2018 11:40:20 +0100
> >> Subject: [PATCH] hugetlb, mbind: fall back to default policy if vma is NULL
> >>
> >> Dan Carpenter has noticed that mbind migration callback (new_page)
> >> can get a NULL vma pointer and choke on it inside alloc_huge_page_vma
> >> which relies on the VMA to get the hstate. We used to BUG_ON this
> >> case but the BUG_+ON has been removed recently by "hugetlb, mempolicy:
> >> fix the mbind hugetlb migration".
> >>
> >> The proper way to handle this is to get the hstate from the migrated
> >> page and rely on huge_node (resp. get_vma_policy) do the right thing
> >> with null VMA. We are currently falling back to the default mempolicy in
> >> that case which is in line what THP path is doing here.
> 
> vma is used only for getting mempolicy in alloc_huge_page_vma(), so
> falling back to default mempolicy looks better to me than BUG_ON.
> 
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks for the review Naoya!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
