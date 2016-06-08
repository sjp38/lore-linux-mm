Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 92A146B025E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 12:34:56 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id d4so20807419iod.3
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 09:34:56 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id qo11si2066271pab.106.2016.06.08.09.34.49
        for <linux-mm@kvack.org>;
        Wed, 08 Jun 2016 09:34:55 -0700 (PDT)
Subject: Re: [PATCH 1/1] mm/swap.c: flush lru_add pvecs on compound page
 arrival
References: <1465396537-17277-1-git-send-email-lukasz.odzioba@intel.com>
 <57583A49.30809@intel.com> <20160608160653.GB21838@dhcp22.suse.cz>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <575848F9.2060501@intel.com>
Date: Wed, 8 Jun 2016 09:34:01 -0700
MIME-Version: 1.0
In-Reply-To: <20160608160653.GB21838@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Lukasz Odzioba <lukasz.odzioba@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, vdavydov@parallels.com, mingli199x@qq.com, minchan@kernel.org, lukasz.anaczkowski@intel.com, "Shutemov, Kirill" <kirill.shutemov@intel.com>

On 06/08/2016 09:06 AM, Michal Hocko wrote:
>> > Do we have any statistics that tell us how many pages are sitting the
>> > lru pvecs?  Although this helps the problem overall, don't we still have
>> > a problem with memory being held in such an opaque place?
> Is it really worth bothering when we are talking about 56kB per CPU
> (after this patch)?

That was the logic why we didn't have it up until now: we didn't
*expect* it to get large.  A code change blew it up by 512x, and we had
no instrumentation to tell us where all the memory went.

I guess we don't have any other ways to group pages than compound pages,
and _that_ one is covered now... for one of the 5 classes of pvecs.

Is there a good reason we don't have to touch the other 4 pagevecs, btw?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
