Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 4D23D6B003B
	for <linux-mm@kvack.org>; Thu, 31 Oct 2013 13:14:48 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so2627071pdj.8
        for <linux-mm@kvack.org>; Thu, 31 Oct 2013 10:14:47 -0700 (PDT)
Received: from psmtp.com ([74.125.245.120])
        by mx.google.com with SMTP id sd2si2442916pbb.319.2013.10.31.10.14.45
        for <linux-mm@kvack.org>;
        Thu, 31 Oct 2013 10:14:46 -0700 (PDT)
Received: by mail-gg0-f179.google.com with SMTP id q4so362784ggn.38
        for <linux-mm@kvack.org>; Thu, 31 Oct 2013 10:14:44 -0700 (PDT)
Message-ID: <52729003.1060209@gmail.com>
Date: Thu, 31 Oct 2013 13:14:43 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: get rid of unnecessary pageblock scanning in setup_zone_migrate_reserve
References: <1382562092-15570-1-git-send-email-kosaki.motohiro@gmail.com> <20131030151904.GO2400@suse.de> <527169BB.8020104@gmail.com> <20131031101525.GT2400@suse.de>
In-Reply-To: <20131031101525.GT2400@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: kosaki.motohiro@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

>> Nit. I would like to add following hunk. This is just nit because moving
>> reserve pageblock is extreme rare.
>>
>> 		if (block_migratetype == MIGRATE_RESERVE) {
>> +                       found++;
>> 			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
>> 			move_freepages_block(zone, page, MIGRATE_MOVABLE);
>> 		}
>
> I don't really see the advantage but if you think it is necessary then I
> do not object either.

For example, a zone has five pageblock b1,b2,b3,b4,b5 and b1 has MIGRATE_RESERVE.
When hotremove b1 and hotadd again, your code need to scan all of blocks. But
mine only need to scan b1 and b2. I mean that's a hotplug specific optimization.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
