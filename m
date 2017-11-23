Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 836346B0038
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 04:21:51 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id p65so2302219wma.1
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 01:21:51 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k12si843581edd.18.2017.11.23.01.21.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Nov 2017 01:21:50 -0800 (PST)
Date: Thu, 23 Nov 2017 10:21:49 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: hugetlb page migration vs. overcommit
Message-ID: <20171123092149.tnfl2dcswg2iv3s3@dhcp22.suse.cz>
References: <20171122152832.iayefrlxbugphorp@dhcp22.suse.cz>
 <91969714-5256-e96f-a48b-43af756a2686@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <91969714-5256-e96f-a48b-43af756a2686@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 22-11-17 11:11:38, Mike Kravetz wrote:
> On 11/22/2017 07:28 AM, Michal Hocko wrote:
[...]
> > Why don't we simply migrate as long as we are able to allocate the
> > target hugetlb page? I have a half baked patch to remove this
> > restriction, would there be an opposition to do something like that?
> 
> I would not be opposed and would help with this effort.  My concern would
> be any subtle hugetlb accounting issues once you start messing with
> additional overcommit pages.

Well my current (crude) patch checks for overcommit in the destructor
and releases the page if we are over. That should deal with accounting
AFAICS.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
