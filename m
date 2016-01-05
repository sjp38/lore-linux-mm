Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 96AA96B0007
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 08:33:41 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id f206so29304552wmf.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 05:33:41 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id db10si152189020wjc.200.2016.01.05.05.33.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Jan 2016 05:33:40 -0800 (PST)
Date: Tue, 5 Jan 2016 14:33:38 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] mm, oom: skip mlocked VMAs in __oom_reap_vmas()
Message-ID: <20160105133338.GC15324@dhcp22.suse.cz>
References: <1451421990-32297-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1451421990-32297-2-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1451421990-32297-2-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue 29-12-15 23:46:29, Kirill A. Shutemov wrote:
> As far as I can see we explicitly munlock pages everywhere before unmap
> them. The only case when we don't to that is OOM-reaper.
> 
> I don't think we should bother with munlocking in this case, we can just
> skip the locked VMA.
> 
> I think this patch would fix this crash:
>  http://lkml.kernel.org/r/5661FBB6.6050307@oracle.com

Btw, do you happen to have the full log here. OOM reaper can only
interfere if there was an OOM killer invoked.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
