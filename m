Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id F2C7D6B04EE
	for <linux-mm@kvack.org>; Thu, 17 May 2018 09:50:45 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p1-v6so3086434wrm.7
        for <linux-mm@kvack.org>; Thu, 17 May 2018 06:50:45 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t23-v6si634129edi.108.2018.05.17.06.50.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 May 2018 06:50:44 -0700 (PDT)
Subject: Re: [PATCH] Revert "mm/cma: manage the memory of the CMA area by
 using the ZONE_MOVABLE"
References: <20180517125959.8095-1-ville.syrjala@linux.intel.com>
 <20180517132109.GU12670@dhcp22.suse.cz> <20180517133629.GH23723@intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6b9ad7af-6c7c-ebd8-1dc5-c34db177fdf7@suse.cz>
Date: Thu, 17 May 2018 15:50:36 +0200
MIME-Version: 1.0
In-Reply-To: <20180517133629.GH23723@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?VmlsbGUgU3lyasOkbMOk?= <ville.syrjala@linux.intel.com>, Michal Hocko <mhocko@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Tony Lindgren <tony@atomide.com>, Johannes Weiner <hannes@cmpxchg.org>, Laura Abbott <lauraa@codeaurora.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/17/2018 03:36 PM, Ville SyrjA?lA? wrote:
> On Thu, May 17, 2018 at 03:21:09PM +0200, Michal Hocko wrote:
>> On Thu 17-05-18 15:59:59, Ville Syrjala wrote:
>>> From: Ville SyrjA?lA? <ville.syrjala@linux.intel.com>
>>>
>>> This reverts commit bad8c6c0b1144694ecb0bc5629ede9b8b578b86e.
>>>
>>> Make x86 with HIGHMEM=y and CMA=y boot again.
>>
>> Is there any bug report with some more details? It is much more
>> preferable to fix the issue rather than to revert the whole thing
>> right away.
> 
> The machine I have in front of me right now didn't give me anything.
> Black screen, and netconsole was silent. No serial port on this
> machine unfortunately.

Could you send the .config and more info about the machine, e.g.
/proc/zoneinfo with the patch reverted, etc., the usual stuff when
reporting a bug? Thanks.
