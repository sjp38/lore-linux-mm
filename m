Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 724E86B0032
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 15:34:37 -0400 (EDT)
Message-ID: <51AF92C1.7040404@redhat.com>
Date: Wed, 05 Jun 2013 15:34:25 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/7] mm: compaction: scan all memory with /proc/sys/vm/compact_memory
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com> <1370445037-24144-3-git-send-email-aarcange@redhat.com>
In-Reply-To: <1370445037-24144-3-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>

On 06/05/2013 11:10 AM, Andrea Arcangeli wrote:
> Reset the stats so /proc/sys/vm/compact_memory will scan all memory.
>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
