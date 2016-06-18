Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 688506B007E
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 21:48:48 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id b13so156804308pat.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 18:48:48 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id mv18si26348945pab.17.2016.06.17.18.48.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 18:48:47 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id fg1so6710909pad.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 18:48:47 -0700 (PDT)
Date: Sat, 18 Jun 2016 09:48:41 +0800
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: Re: [PATCH] mm/compaction: remove local variable is_lru
Message-ID: <20160618014841.GA7422@leo-test>
References: <1466155971-6280-1-git-send-email-opensource.ganesh@gmail.com>
 <20160617095030.GB21670@dhcp22.suse.cz>
 <fbcd77c3-b192-3415-8417-6c8b07ce2146@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fbcd77c3-b192-3415-8417-6c8b07ce2146@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, iamjoonsoo.kim@lge.com, hillf.zj@alibaba-inc.com, minchan@kernel.org

On Fri, Jun 17, 2016 at 02:50:12PM +0200, Vlastimil Babka wrote:
> On 06/17/2016 11:50 AM, Michal Hocko wrote:
> >On Fri 17-06-16 17:32:51, Ganesh Mahendran wrote:
> >>local varialbe is_lru was used for tracking non-lru pages(such as
> >>balloon pages).
> >>
> >>But commit
> >>112ea7b668d3 ("mm: migrate: support non-lru movable page migration")
> >
> >this commit sha is not stable because it is from the linux-next tree.
> >
> >>introduced a common framework for non-lru page migration and moved
> >>the compound pages check before non-lru movable pages check.
> >>
> >>So there is no need to use local variable is_lru.
> >>
> >>Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> >
> >Other than that the patch looks ok and maybe it would be worth folding
> >into the mm-migrate-support-non-lru-movable-page-migration.patch
> 
> Agreed.

Thanks.

Hi, Andrew:

Please help to fold this patch into:
mm-migrate-support-non-lru-movable-page-migration.patch

---
