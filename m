Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C00796B0276
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 06:59:06 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id i128so7995186wme.2
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 03:59:06 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id z17si7804979wjw.26.2016.10.27.03.59.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 03:59:05 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id b80so2076419wme.2
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 03:59:05 -0700 (PDT)
Date: Thu, 27 Oct 2016 12:59:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: add locked parameter to get_user_pages_remote()
Message-ID: <20161027105903.GI6454@dhcp22.suse.cz>
References: <20161027095141.2569-1-lstoakes@gmail.com>
 <20161027095141.2569-2-lstoakes@gmail.com>
 <20161027105527.GG6454@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161027105527.GG6454@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org, linux-rdma@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-fsdevel@vger.kernel.org

On Thu 27-10-16 12:55:27, Michal Hocko wrote:
> On Thu 27-10-16 10:51:40, Lorenzo Stoakes wrote:
> > This patch adds a int *locked parameter to get_user_pages_remote() to allow
> > VM_FAULT_RETRY faulting behaviour similar to get_user_pages_[un]locked().
> > 
> > Taking into account the previous adjustments to get_user_pages*() functions
> > allowing for the passing of gup_flags, we are now in a position where
> > __get_user_pages_unlocked() need only be exported for his ability to allow
> > VM_FAULT_RETRY behaviour, this adjustment allows us to subsequently unexport
> > __get_user_pages_unlocked() as well as allowing for future flexibility in the
> > use of get_user_pages_remote().
> 
> I would also add that this shouldn't introduce any functional change.

Forgot to mention that this also opens doors to change other g_u_p_r
callers to allow FAULT_RETRY logic.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
