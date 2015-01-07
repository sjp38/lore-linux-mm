Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id A87EE6B0038
	for <linux-mm@kvack.org>; Wed,  7 Jan 2015 04:15:41 -0500 (EST)
Received: by mail-we0-f180.google.com with SMTP id w62so771558wes.25
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 01:15:41 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ic3si30539593wid.49.2015.01.07.01.15.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 Jan 2015 01:15:40 -0800 (PST)
Message-ID: <54ACF93B.3060801@suse.cz>
Date: Wed, 07 Jan 2015 10:15:39 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH V4 4/4] mm: microoptimize zonelist operations
References: <1420478263-25207-1-git-send-email-vbabka@suse.cz> <1420478263-25207-5-git-send-email-vbabka@suse.cz> <20150106150920.GE20860@dhcp22.suse.cz>
In-Reply-To: <20150106150920.GE20860@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 01/06/2015 04:09 PM, Michal Hocko wrote:
> On Mon 05-01-15 18:17:43, Vlastimil Babka wrote:
>> The function next_zones_zonelist() returns zoneref pointer, as well as zone
>> pointer via extra parameter. Since the latter can be trivially obtained by
>> dereferencing the former, the overhead of the extra parameter is unjustified.
>> 
>> This patch thus removes the zone parameter from next_zones_zonelist(). Both
>> callers happen to be in the same header file, so it's simple to add the
>> zoneref dereference inline. We save some bytes of code size.
> 
> Dunno. It makes first_zones_zonelist and next_zones_zonelist look
> different which might be a bit confusing. It's not a big deal but
> I am not sure it is worth it.

Yeah I thought that nobody uses them directly anyway thanks to
for_each_zone_zonelist* so it's not a big deal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
