Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 0E0716B0002
	for <linux-mm@kvack.org>; Sat, 23 Mar 2013 11:55:39 -0400 (EDT)
Message-ID: <514DD065.3000106@redhat.com>
Date: Sat, 23 Mar 2013 11:55:17 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/10] migrate: add migrate_entry_wait_huge()
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1363983835-20184-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1363983835-20184-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org

On 03/22/2013 04:23 PM, Naoya Horiguchi wrote:
> When we have a page fault for the address which is backed by a hugepage
> under migration, the kernel can't wait correctly until the migration
> finishes. This is because pte_offset_map_lock() can't get a correct
> migration entry for hugepage. This patch adds migration_entry_wait_huge()
> to separate code path between normal pages and hugepages.
>
> ChangeLog v2:
>   - remove dup in migrate_entry_wait_huge()
>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
