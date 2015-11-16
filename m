Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 58AC76B0256
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 13:43:09 -0500 (EST)
Received: by wmdw130 with SMTP id w130so124059557wmd.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 10:43:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 77si27497355wme.95.2015.11.16.10.43.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Nov 2015 10:43:08 -0800 (PST)
Date: Mon, 16 Nov 2015 18:43:04 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/2] mm: get rid of __alloc_pages_high_priority
Message-ID: <20151116173754.GG19677@suse.de>
References: <1447680139-16484-1-git-send-email-mhocko@kernel.org>
 <1447680139-16484-2-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1447680139-16484-2-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Mon, Nov 16, 2015 at 02:22:18PM +0100, mhocko@kernel.org wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> __alloc_pages_high_priority doesn't do anything special other than it
> calls get_page_from_freelist and loops around GFP_NOFAIL allocation
> until it succeeds. It would be better if the first part was done in
> __alloc_pages_slowpath where we modify the zonelist because this would
> be easier to read and understand. Opencoding the function into its only
> caller allows to simplify it a bit as well.
> 
> This patch doesn't introduce any functional changes.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
