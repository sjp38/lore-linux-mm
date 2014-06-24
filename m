Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id B98A66B0062
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 11:44:34 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id q59so575048wes.27
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 08:44:33 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ef8si879158wjd.149.2014.06.24.08.44.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 24 Jun 2014 08:44:25 -0700 (PDT)
Message-ID: <53A99CCD.5050103@suse.cz>
Date: Tue, 24 Jun 2014 17:44:13 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v3 06/13] mm, compaction: periodically drop lock and restore
 IRQs in scanners
References: <1403279383-5862-1-git-send-email-vbabka@suse.cz> <1403279383-5862-7-git-send-email-vbabka@suse.cz> <20140624153900.GB18289@nhori.bos.redhat.com>
In-Reply-To: <20140624153900.GB18289@nhori.bos.redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, linux-kernel@vger.kernel.org

On 06/24/2014 05:39 PM, Naoya Horiguchi wrote:
> On Fri, Jun 20, 2014 at 05:49:36PM +0200, Vlastimil Babka wrote:
>> Compaction scanners regularly check for lock contention and need_resched()
>> through the compact_checklock_irqsave() function. However, if there is no
>> contention, the lock can be held and IRQ disabled for potentially long time.
>>
>> This has been addressed by commit b2eef8c0d0 ("mm: compaction: minimise the
>> time IRQs are disabled while isolating pages for migration") for the migration
>> scanner. However, the refactoring done by commit 748446bb6b ("mm: compaction:
>> acquire the zone->lru_lock as late as possible") has changed the conditions so
>
> You seem to refer to the incorrect commit, maybe you meant commit 2a1402aa044b?

Oops, right. Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
