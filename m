Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 67CDB6B0031
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 20:58:11 -0400 (EDT)
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MR80056WO0L2OA0@mailout1.samsung.com> for linux-mm@kvack.org;
 Fri, 09 Aug 2013 09:58:10 +0900 (KST)
Message-id: <52043EA3.3080704@samsung.com>
Date: Fri, 09 Aug 2013 09:58:11 +0900
From: Joonyoung Shim <jy0922.shim@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH] Revert
 "mm/memory-hotplug: fix lowmem count overflow when offline pages"
References: <1375260602-2462-1-git-send-email-jy0922.shim@samsung.com>
 <1572085.gN7iX7IvMe@amdc1032> <3049413.HnxJdeugZK@amdc1032>
In-reply-to: <3049413.HnxJdeugZK@amdc1032>
Content-type: text/plain; charset=ISO-8859-1; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, liuj97@gmail.com, kosaki.motohiro@gmail.com

On 07/31/2013 08:48 PM, Bartlomiej Zolnierkiewicz wrote:
> On Wednesday, July 31, 2013 01:17:46 PM Bartlomiej Zolnierkiewicz wrote:
>> Hi,
>>
>> On Wednesday, July 31, 2013 05:50:02 PM Joonyoung Shim wrote:
>>> This reverts commit cea27eb2a202959783f81254c48c250ddd80e129.
>> Could you please also include commit descriptions, i.e.
>> commit cea27eb2a202959783f81254c48c250ddd80e129 ("mm/memory-hotplug: fix
>> lowmem count overflow when offline pages")?
>>
>>> Fixed to adjust totalhigh_pages when hot-removing memory by commit
>>> 3dcc0571cd64816309765b7c7e4691a4cadf2ee7, so that commit occurs
>>> duplicated decreasing of totalhigh_pages.
>> Could you please describe it a bit more (because it is non-obvious) how
>> the commit cea27eb effectively does the same totalhigh_pages adjustment
>> that is present in the commit 3dcc057?
> Err, the other way around. How the commit 3dcc057 ("mm: correctly update
> zone->managed_pages") does what cea27eb ("mm/memory-hotplug: fix lowmem
> count overflow when offline pages") did.
>

OK, i updated to patch v2.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
