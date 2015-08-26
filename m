Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id A58016B0253
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 03:20:20 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so6117577wid.0
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 00:20:20 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id q8si3589196wju.0.2015.08.26.00.20.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Aug 2015 00:20:19 -0700 (PDT)
Received: by widdq5 with SMTP id dq5so36929849wid.1
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 00:20:18 -0700 (PDT)
Date: Wed, 26 Aug 2015 09:20:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v7 3/6] mm: Introduce VM_LOCKONFAULT
Message-ID: <20150826072016.GD25196@dhcp22.suse.cz>
References: <20150812115909.GA5182@dhcp22.suse.cz>
 <20150819213345.GB4536@akamai.com>
 <20150820075611.GD4780@dhcp22.suse.cz>
 <20150820170309.GA11557@akamai.com>
 <20150821072552.GF23723@dhcp22.suse.cz>
 <20150821183132.GA12835@akamai.com>
 <20150825134154.GB6285@dhcp22.suse.cz>
 <20150825142902.GF17005@akamai.com>
 <20150825185829.GA10222@dhcp22.suse.cz>
 <20150825190300.GG17005@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150825190300.GG17005@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Tue 25-08-15 15:03:00, Eric B Munson wrote:
[...]
> Would you drop your objections to the VMA flag if I drop the portions of
> the patch that expose it to userspace?
> 
> The rework to not use the VMA flag is pretty sizeable and is much more
> ugly IMO.  I know that you are not wild about using bit 30 of 32 for
> this, but perhaps we can settle on not exporting it to userspace so we
> can reclaim it if we really need it in the future?

Yes, that would be definitely more acceptable for me. I do understand
that you are not wild about changing mremap behavior.

Anyway, I would really prefer if the vma flag was really used only at
few places - when we are clearing it along with VM_LOCKED (which could
be hidden in VM_LOCKED_CLEAR_MASK or something like that) and when we
decide whether the populate or not (this should be __mm_populate). But
maybe I am missing some call paths where gup is called unconditionally,
I haven't checked that.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
