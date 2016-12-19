Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6E7B16B02A1
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 09:38:43 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id w13so19969855wmw.0
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 06:38:43 -0800 (PST)
Received: from mail-wj0-f195.google.com (mail-wj0-f195.google.com. [209.85.210.195])
        by mx.google.com with ESMTPS id y9si18699856wjg.132.2016.12.19.06.38.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Dec 2016 06:38:42 -0800 (PST)
Received: by mail-wj0-f195.google.com with SMTP id kp2so23862075wjc.0
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 06:38:42 -0800 (PST)
Date: Mon, 19 Dec 2016 15:38:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/4] oom-reaper: use madvise_dontneed() instead of
 unmap_page_range()
Message-ID: <20161219143840.GK5164@dhcp22.suse.cz>
References: <20161216141556.75130-1-kirill.shutemov@linux.intel.com>
 <20161216141556.75130-4-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161216141556.75130-4-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 16-12-16 17:15:56, Kirill A. Shutemov wrote:
> Logic on whether we can reap pages from the VMA should match what we
> have in madvise_dontneed(). In particular, we should skip, VM_PFNMAP
> VMAs, but we don't now.
> 
> Let's just call madvise_dontneed() from __oom_reap_task_mm(), so we
> won't need to sync the logic in the future.

I would rather extract those check into can_madv_dontneed_vma() and use
it in the oom reaper. I am really woried about notifier API which can
sleep or rely on locks or do whatever else.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
