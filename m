Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 40ED66B0269
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 05:54:16 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id n23-v6so667904pfk.23
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 02:54:16 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id t187-v6si21852681pfd.148.2018.10.09.02.54.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 02:54:15 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Tue, 09 Oct 2018 15:24:13 +0530
From: Arun KS <arunks@codeaurora.org>
Subject: Re: [PATCH v5 1/2] memory_hotplug: Free pages as higher order
In-Reply-To: <20181009092938.GH8528@dhcp22.suse.cz>
References: <1538727006-5727-1-git-send-email-arunks@codeaurora.org>
 <20181009092938.GH8528@dhcp22.suse.cz>
Message-ID: <9b56e156b911e943eba3a1daa0a1cb31@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com, boris.ostrovsky@oracle.com, jgross@suse.com, akpm@linux-foundation.org, dan.j.williams@intel.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, gregkh@linuxfoundation.org, osalvador@suse.de, malat@debian.org, kirill.shutemov@linux.intel.com, jrdr.linux@gmail.com, yasu.isimatu@gmail.com, mgorman@techsingularity.net, aaron.lu@intel.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, vatsa@codeaurora.org, vinmenon@codeaurora.org, getarunks@gmail.com

On 2018-10-09 14:59, Michal Hocko wrote:
> On Fri 05-10-18 13:40:05, Arun KS wrote:
>> When free pages are done with higher order, time spend on
>> coalescing pages by buddy allocator can be reduced. With
>> section size of 256MB, hot add latency of a single section
>> shows improvement from 50-60 ms to less than 1 ms, hence
>> improving the hot add latency by 60%. Modify external
>> providers of online callback to align with the change.
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> Thanks for your patience with all the resubmission.

Hello Michal,

I got the below email few days back. Do I still need to resubmit the 
patch? or is it already on the way to merge?

Regards,
Arun

The patch titled
      Subject: mm/page_alloc.c: memory hotplug: free pages as higher 
order
has been added to the -mm tree.  Its filename is
      memory_hotplug-free-pages-as-higher-order.patch

This patch should soon appear at
     
http://ozlabs.org/~akpm/mmots/broken-out/memory_hotplug-free-pages-as-higher-order.patch
and later at
     
http://ozlabs.org/~akpm/mmotm/broken-out/memory_hotplug-free-pages-as-higher-order.patch

Before you just go and hit "reply", please:
    a) Consider who else should be cc'ed
    b) Prefer to cc a suitable mailing list as well
    c) Ideally: find the original patch on the mailing list and do a
       reply-to-all to that, adding suitable additional cc's

*** Remember to use Documentation/process/submit-checklist.rst when 
testing your code ***

The -mm tree is included into linux-next and is updated
there every 3-4 working days
