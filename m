Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 905268E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 06:57:10 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id e15-v6so14568205pfi.5
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 03:57:10 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id 14-v6si4962084pgm.488.2018.09.26.03.57.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Sep 2018 03:57:09 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Wed, 26 Sep 2018 16:27:08 +0530
From: Arun KS <arunks@codeaurora.org>
Subject: Re: [PATCH v2] memory_hotplug: Free pages as higher order
In-Reply-To: <20180925181826.GW18685@dhcp22.suse.cz>
References: <1537854158-9766-1-git-send-email-arunks@codeaurora.org>
 <ccdbaf76-cbdd-759e-c6de-c5b738f156e9@suse.cz>
 <20180925181826.GW18685@dhcp22.suse.cz>
Message-ID: <bdba4200b69f560af36967e2d23dde8f@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com, boris.ostrovsky@oracle.com, jgross@suse.com, akpm@linux-foundation.org, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, osalvador@suse.de, malat@debian.org, yasu.isimatu@gmail.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, vatsa@codeaurora.org, vinmenon@codeaurora.org, getarunks@gmail.com

On 2018-09-25 23:48, Michal Hocko wrote:
> On Tue 25-09-18 11:59:09, Vlastimil Babka wrote:
> [...]
>> This seems like almost complete copy of __free_pages_boot_core(), 
>> could
>> you do some code reuse instead? I think Michal Hocko also suggested 
>> that.
> 
> Yes, please try to reuse as much code as possible
Sure, Will address in next spin.

Regards,
Arun
