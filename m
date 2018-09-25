Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 313258E00A4
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 14:18:31 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id e11so975660edv.20
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 11:18:31 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z36-v6si6109946ede.349.2018.09.25.11.18.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 11:18:29 -0700 (PDT)
Date: Tue, 25 Sep 2018 20:18:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] memory_hotplug: Free pages as higher order
Message-ID: <20180925181826.GW18685@dhcp22.suse.cz>
References: <1537854158-9766-1-git-send-email-arunks@codeaurora.org>
 <ccdbaf76-cbdd-759e-c6de-c5b738f156e9@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ccdbaf76-cbdd-759e-c6de-c5b738f156e9@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com, boris.ostrovsky@oracle.com, jgross@suse.com, akpm@linux-foundation.org, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, osalvador@suse.de, malat@debian.org, yasu.isimatu@gmail.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, vatsa@codeaurora.org, vinmenon@codeaurora.org, getarunks@gmail.com

On Tue 25-09-18 11:59:09, Vlastimil Babka wrote:
[...]
> This seems like almost complete copy of __free_pages_boot_core(), could
> you do some code reuse instead? I think Michal Hocko also suggested that.

Yes, please try to reuse as much code as possible

-- 
Michal Hocko
SUSE Labs
