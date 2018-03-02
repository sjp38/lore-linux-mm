Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B3F176B0005
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 16:25:38 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id x6so624433pfx.16
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 13:25:38 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id y2si4561439pgr.167.2018.03.02.13.25.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Mar 2018 13:25:37 -0800 (PST)
Subject: Re: [PATCH v4 2/3] mm/free_pcppages_bulk: do not hold lock when
 picking pages to free
References: <20180301062845.26038-1-aaron.lu@intel.com>
 <20180301062845.26038-3-aaron.lu@intel.com>
 <20180301160105.aca958fac871998d582307d4@linux-foundation.org>
 <20180302080125.GB6356@intel.com>
 <20180302132332.2c69559686ff24d15ff44ae8@linux-foundation.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <1110bcae-f4c5-68ff-77df-28934a21dd86@intel.com>
Date: Fri, 2 Mar 2018 13:25:35 -0800
MIME-Version: 1.0
In-Reply-To: <20180302132332.2c69559686ff24d15ff44ae8@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, David Rientjes <rientjes@google.com>

On 03/02/2018 01:23 PM, Andrew Morton wrote:
>> On my Sandybridge desktop, with will-it-scale/page_fault1/single process
>> run to emulate uniprocessor system, the score is(average of 3 runs):
>>
>> base(patch 1/3):	649710 
>> this patch:		653554 +0.6%
> Does that mean we got faster or slower?

Faster.  The unit of measurement here is iterations through a loop.
More iterations are better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
