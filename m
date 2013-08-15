Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 509D06B005C
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 15:39:05 -0400 (EDT)
Date: Thu, 15 Aug 2013 12:39:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 0/9] extend hugepage migration
Message-Id: <20130815123903.2425f4375ad8554b980d586f@linux-foundation.org>
In-Reply-To: <1376547820-91ccjgp3-mutt-n-horiguchi@ah.jp.nec.com>
References: <1376025702-14818-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<20130814164052.2ccdd5bdf7ab56deeba88e68@linux-foundation.org>
	<1376547820-91ccjgp3-mutt-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, 15 Aug 2013 02:23:40 -0400 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

>
> ...
>
> > mm-prepare-to-remove-proc-sys-vm-hugepages_treat_as_movable.patch had a
> > conflict with
> > http://ozlabs.org/~akpm/mmots/broken-out/mm-hugetlb-move-up-the-code-which-check-availability-of-free-huge-page.patch
> > which I resolved in the obvious manner.  Please check that from a
> > runtime perspective.
> 
> As replied to the mm-commits notification ("Subject: + mm-prepare-to-remove-
> proc-sys-vm-hugepages_treat_as_movable.patch added to -mm tree",)

I can't find that email anywhere :(

> I want to replace that patch with another one ("Subject: [PATCH] hugetlb:
> make htlb_alloc_mask dependent on migration support").

Can you please formally resend this?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
