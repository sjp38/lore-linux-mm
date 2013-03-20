Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 70DE56B0002
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 17:53:35 -0400 (EDT)
Date: Wed, 20 Mar 2013 17:53:19 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1363816399-c6e7mofc-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <5148FB6C.4070202@gmail.com>
References: <1361475708-25991-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1361475708-25991-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <5148FB6C.4070202@gmail.com>
Subject: Re: [PATCH 1/9] migrate: add migrate_entry_wait_huge()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org

On Wed, Mar 20, 2013 at 07:57:32AM +0800, Simon Jeons wrote:
> Hi Naoya,
> On 02/22/2013 03:41 AM, Naoya Horiguchi wrote:
> >When we have a page fault for the address which is backed by a hugepage
> >under migration, the kernel can't wait correctly until the migration
> >finishes. This is because pte_offset_map_lock() can't get a correct
> 
> It seems that current hugetlb_fault still wait hugetlb page under
> migration, how can it work without lock 2MB memory?

Hugetlb_fault() does call migration_entry_wait(), but returns immediately.
So page fault happens over and over again until the migration completes.
IOW, migration_entry_wait() is now broken for hugepage and doesn't work
as expected.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
