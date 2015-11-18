Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 56E5382F84
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 09:49:02 -0500 (EST)
Received: by wmvv187 with SMTP id v187so282035563wmv.1
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 06:49:01 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j62si5272854wmd.65.2015.11.18.06.48.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 18 Nov 2015 06:48:59 -0800 (PST)
Subject: Re: [PATCH 1/2] mm: get rid of __alloc_pages_high_priority
References: <1447680139-16484-1-git-send-email-mhocko@kernel.org>
 <1447680139-16484-2-git-send-email-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <564C8FD9.3060706@suse.cz>
Date: Wed, 18 Nov 2015 15:48:57 +0100
MIME-Version: 1.0
In-Reply-To: <1447680139-16484-2-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 11/16/2015 02:22 PM, mhocko@kernel.org wrote:
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

Acked-by: Vlastimil Babka <vbabka@suse.cz>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
