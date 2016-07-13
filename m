Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4550F6B0260
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 03:50:27 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id o80so29083022wme.1
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 00:50:27 -0700 (PDT)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id c194si1832717wme.107.2016.07.13.00.50.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 00:50:26 -0700 (PDT)
Received: by mail-wm0-f52.google.com with SMTP id o80so55286487wme.1
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 00:50:25 -0700 (PDT)
Date: Wed, 13 Jul 2016 09:50:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: gup: Re-define follow_page_mask output parameter
 page_mask usage
Message-ID: <20160713075024.GB28723@dhcp22.suse.cz>
References: <1468084625-26999-1-git-send-email-chengang@emindsoft.com.cn>
 <20160711141702.fb1879707aa2bcb290133a43@linux-foundation.org>
 <578522CE.9060905@emindsoft.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <578522CE.9060905@emindsoft.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <chengang@emindsoft.com.cn>
Cc: Andrew Morton <akpm@linux-foundation.org>, vbabka@suse.cz, kirill.shutemov@linux.intel.com, mingo@kernel.org, dave.hansen@linux.intel.com, dan.j.williams@intel.com, hannes@cmpxchg.org, jack@suse.cz, iamjoonsoo.kim@lge.com, jmarchan@redhat.com, dingel@linux.vnet.ibm.com, oleg@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Gang <gang.chen.5i5j@gmail.com>

On Wed 13-07-16 01:03:10, Chen Gang wrote:
> On 7/12/16 05:17, Andrew Morton wrote:
> > On Sun, 10 Jul 2016 01:17:05 +0800 chengang@emindsoft.com.cn wrote:
> > 
> >> For a pure output parameter:
> >>
> >>  - When callee fails, the caller should not assume the output parameter
> >>    is still valid.
> >>
> >>  - And callee should not assume the pure output parameter must be
> >>    provided by caller -- caller has right to pass NULL when caller does
> >>    not care about it.
> > 
> > Sorry, I don't think this one is worth merging really.
> > 
> 
> OK, thanks, I can understand.
> 
> It will be better if provide more details: e.g.
> 
>  - This patch is incorrect, or the comments is not correct.
> 
>  - The patch is worthless, at present.

I would say the patch is not really needed. The code you are touching
works just fine and there is no reason to touch it unless this is a part
of a larger change where future changes would be easier to
review/implement.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
