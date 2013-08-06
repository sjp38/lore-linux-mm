Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 5089F6B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 21:52:13 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 6 Aug 2013 07:13:44 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id B44BD394004D
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 07:21:55 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r761pxdK47317092
	for <linux-mm@kvack.org>; Tue, 6 Aug 2013 07:21:59 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r761q1Ip030909
	for <linux-mm@kvack.org>; Tue, 6 Aug 2013 07:22:02 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 8/8] prepare to remove /proc/sys/vm/hugepages_treat_as_movable
In-Reply-To: <1375411396-bw4cbhso-mutt-n-horiguchi@ah.jp.nec.com>
References: <1374728103-17468-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1374728103-17468-9-git-send-email-n-horiguchi@ah.jp.nec.com> <87k3k7q4ox.fsf@linux.vnet.ibm.com> <1375302249-scfvftrh-mutt-n-horiguchi@ah.jp.nec.com> <87vc3qvtmc.fsf@linux.vnet.ibm.com> <1375411396-bw4cbhso-mutt-n-horiguchi@ah.jp.nec.com>
Date: Tue, 06 Aug 2013 07:22:02 +0530
Message-ID: <87haf3oabh.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:


>> 
>> Considering that we have architectures that won't support migrating
>> explicit hugepages with this patch series, is it ok to use
>> GFP_HIGHUSER_MOVABLE for hugepage allocation ?
>
> Originally this parameter was introduced to make hugepage pool on ZONE_MOVABLE.
> The benefit is that we can extend the hugepage pool more easily,
> because external fragmentation less likely happens than other zone type
> by rearranging fragmented pages with page migration/reclaim.
>
> So I think using ZONE_MOVABLE for hugepage allocation by default makes sense
> even on the architectures which don't support hugepage migration.

But allocating hugepages from ZONE_MOVABLE means we have pages in that
zone which we can't migrate. Doesn't that impact other features like
hotplug ?


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
