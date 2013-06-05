Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 362236B0032
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 15:23:52 -0400 (EDT)
Message-ID: <51AF903C.4060801@redhat.com>
Date: Wed, 05 Jun 2013 15:23:40 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/7] mm: remove ZONE_RECLAIM_LOCKED
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com> <1370445037-24144-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <1370445037-24144-2-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>

On 06/05/2013 11:10 AM, Andrea Arcangeli wrote:
> Zone reclaim locked breaks zone_reclaim_mode=1. If more than one
> thread allocates memory at the same time, it forces a premature
> allocation into remote NUMA nodes even when there's plenty of clean
> cache to reclaim in the local nodes.

Since we can get into concurrent reclaim from the direct reclaim
path anyway, and seem to handle that correctly, removing this
special case from zone reclaim looks fine.

> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
