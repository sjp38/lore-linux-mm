Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 8F01A6B0002
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 19:37:00 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id xa12so1755521pbc.36
        for <linux-mm@kvack.org>; Wed, 20 Mar 2013 16:36:59 -0700 (PDT)
Message-ID: <514A4815.4040206@gmail.com>
Date: Thu, 21 Mar 2013 07:36:53 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/9] migrate: add migrate_entry_wait_huge()
References: <1361475708-25991-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1361475708-25991-2-git-send-email-n-horiguchi@ah.jp.nec.com> <5148FB6C.4070202@gmail.com> <1363816399-c6e7mofc-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1363816399-c6e7mofc-mutt-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org

Hi Naoya,
On 03/21/2013 05:53 AM, Naoya Horiguchi wrote:
> On Wed, Mar 20, 2013 at 07:57:32AM +0800, Simon Jeons wrote:
>> Hi Naoya,
>> On 02/22/2013 03:41 AM, Naoya Horiguchi wrote:
>>> When we have a page fault for the address which is backed by a hugepage
>>> under migration, the kernel can't wait correctly until the migration
>>> finishes. This is because pte_offset_map_lock() can't get a correct
>> It seems that current hugetlb_fault still wait hugetlb page under
>> migration, how can it work without lock 2MB memory?
> Hugetlb_fault() does call migration_entry_wait(), but returns immediately.

Could you point out to me which code in function migration_entry_wait()
lead to return immediately?

> So page fault happens over and over again until the migration completes.
> IOW, migration_entry_wait() is now broken for hugepage and doesn't work
> as expected.
>
> Thanks,
> Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
