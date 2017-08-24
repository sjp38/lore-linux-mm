Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id BC654280704
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 03:01:55 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 184so2248344wmi.12
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 00:01:55 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 16si2981733wrx.316.2017.08.24.00.01.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Aug 2017 00:01:54 -0700 (PDT)
Subject: Re: [PATCH 1/4] mm, page_owner: make init_pages_in_zone() faster
From: Vlastimil Babka <vbabka@suse.cz>
References: <20170720134029.25268-1-vbabka@suse.cz>
 <20170720134029.25268-2-vbabka@suse.cz>
 <20170724123843.GH25221@dhcp22.suse.cz>
 <483227ce-6786-f04b-72d1-dba18e06ccaa@suse.cz>
Message-ID: <cf8d0c4f-0e1e-14ee-8dae-a1f71099b887@suse.cz>
Date: Thu, 24 Aug 2017 09:01:52 +0200
MIME-Version: 1.0
In-Reply-To: <483227ce-6786-f04b-72d1-dba18e06ccaa@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Yang Shi <yang.shi@linaro.org>, Laura Abbott <labbott@redhat.com>, Vinayak Menon <vinmenon@codeaurora.org>, zhong jiang <zhongjiang@huawei.com>

On 08/23/2017 08:47 AM, Vlastimil Babka wrote:
> On 07/24/2017 02:38 PM, Michal Hocko wrote:
>>
>> Do we need to duplicated a part of __set_page_owner? Can we pull out
>> both owner and handle out __set_page_owner?
> 
> I wanted to avoid overhead in __set_page_owner() by introducing extra
> shared function, but I'll check if that can be helped.

Ok, here's a -fix for that.

----8<----
