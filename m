Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B97DC6B0507
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 07:46:59 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id o105so3205829wrc.5
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 04:46:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h205si2008618wmf.32.2017.07.12.04.46.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Jul 2017 04:46:58 -0700 (PDT)
Date: Wed, 12 Jul 2017 13:46:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/1] mm/mremap: add MREMAP_MIRROR flag for existing
 mirroring functionality
Message-ID: <20170712114655.GG28912@dhcp22.suse.cz>
References: <1499357846-7481-1-git-send-email-mike.kravetz@oracle.com>
 <1499357846-7481-2-git-send-email-mike.kravetz@oracle.com>
 <20170711123642.GC11936@dhcp22.suse.cz>
 <7f14334f-81d1-7698-d694-37278f05a78e@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7f14334f-81d1-7698-d694-37278f05a78e@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Aaron Lu <aaron.lu@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

On Tue 11-07-17 11:23:19, Mike Kravetz wrote:
> On 07/11/2017 05:36 AM, Michal Hocko wrote:
[...]
> > Anyway the patch should fail with -EINVAL on private mappings as Kirill
> > already pointed out
> 
> Yes.  I think this should be a separate patch.  As mentioned earlier,
> mremap today creates a new/additional private mapping if called in this
> way with old_size == 0.  To me, this is a bug.

Not only that. It clears existing ptes in the old mapping so the content
is lost. That is quite unexpected behavior. Now it is hard to assume
whether somebody relies on the behavior (I can easily imagine somebody
doing backup&clear in atomic way) so failing with EINVAL might break
userspace so I am not longer sure. Anyway this really needs to be
documented.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
