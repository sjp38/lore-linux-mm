Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8CF3C6B026E
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 04:07:28 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id 203-v6so1982456wmv.1
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 01:07:28 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d133-v6sor9540163wmf.19.2018.10.10.01.07.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Oct 2018 01:07:27 -0700 (PDT)
Date: Wed, 10 Oct 2018 10:07:24 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v5 1/2] memory_hotplug: Free pages as higher order
Message-ID: <20181010080724.GA20338@techadventures.net>
References: <1538727006-5727-1-git-send-email-arunks@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1538727006-5727-1-git-send-email-arunks@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>
Cc: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com, boris.ostrovsky@oracle.com, jgross@suse.com, akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, gregkh@linuxfoundation.org, osalvador@suse.de, malat@debian.org, kirill.shutemov@linux.intel.com, jrdr.linux@gmail.com, yasu.isimatu@gmail.com, mgorman@techsingularity.net, aaron.lu@intel.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, vatsa@codeaurora.org, vinmenon@codeaurora.org, getarunks@gmail.com

On Fri, Oct 05, 2018 at 01:40:05PM +0530, Arun KS wrote:
> When free pages are done with higher order, time spend on
> coalescing pages by buddy allocator can be reduced. With
> section size of 256MB, hot add latency of a single section
> shows improvement from 50-60 ms to less than 1 ms, hence
> improving the hot add latency by 60%. Modify external
> providers of online callback to align with the change.

Hi Arun, out of curiosity:

could you please explain how exactly did you mesure the speed
improvement?

Thanks
-- 
Oscar Salvador
SUSE L3
