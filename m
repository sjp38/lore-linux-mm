Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 503808E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 03:10:01 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id k44-v6so1486680wre.21
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 00:10:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d14-v6sor1075434wmd.25.2018.09.27.00.09.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Sep 2018 00:09:59 -0700 (PDT)
Date: Thu, 27 Sep 2018 09:09:58 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v3] memory_hotplug: Free pages as higher order
Message-ID: <20180927070957.GA19369@techadventures.net>
References: <1538031530-25489-1-git-send-email-arunks@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1538031530-25489-1-git-send-email-arunks@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>
Cc: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com, boris.ostrovsky@oracle.com, jgross@suse.com, akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, gregkh@linuxfoundation.org, osalvador@suse.de, malat@debian.org, kirill.shutemov@linux.intel.com, jrdr.linux@gmail.com, yasu.isimatu@gmail.com, mgorman@techsingularity.net, aaron.lu@intel.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, vatsa@codeaurora.org, vinmenon@codeaurora.org, getarunks@gmail.com

On Thu, Sep 27, 2018 at 12:28:50PM +0530, Arun KS wrote:
> +	__free_pages_boot_core(page, order);

I am not sure, but if we are going to use that function from the memory-hotplug code,
we might want to rename that function to something more generic?
The word "boot" suggests that this is only called from the boot stage.

And what about the prefetch operations? 
I saw that you removed them in your previous patch and that had some benefits [1].

Should we remove them here as well?

[1] https://patchwork.kernel.org/patch/10613359/ 

Thanks
-- 
Oscar Salvador
SUSE L3
