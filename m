Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7074B6B0038
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 16:14:52 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so189590517pab.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 13:14:52 -0800 (PST)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id ot9si52892692pbb.222.2015.11.16.13.14.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 13:14:51 -0800 (PST)
Received: by pacej9 with SMTP id ej9so79885065pac.2
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 13:14:51 -0800 (PST)
Date: Mon, 16 Nov 2015 13:14:49 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm: get rid of __alloc_pages_high_priority
In-Reply-To: <1447680139-16484-2-git-send-email-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.10.1511161314330.11456@chino.kir.corp.google.com>
References: <1447680139-16484-1-git-send-email-mhocko@kernel.org> <1447680139-16484-2-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Mon, 16 Nov 2015, mhocko@kernel.org wrote:

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

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
