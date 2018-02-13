Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 35DFC6B0005
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 16:54:04 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id r6so8051628wrg.17
        for <linux-mm@kvack.org>; Tue, 13 Feb 2018 13:54:04 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c23si1582959wra.212.2018.02.13.13.54.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Feb 2018 13:54:03 -0800 (PST)
Date: Tue, 13 Feb 2018 13:53:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 0/4] optimize memory hotplug
Message-Id: <20180213135359.705680d373a482b650f38b50@linux-foundation.org>
In-Reply-To: <20180213193159.14606-1-pasha.tatashin@oracle.com>
References: <20180213193159.14606-1-pasha.tatashin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, mgorman@techsingularity.net, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, vbabka@suse.cz, bharata@linux.vnet.ibm.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com

On Tue, 13 Feb 2018 14:31:55 -0500 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:

> This patchset:
> - Improves hotplug performance by eliminating a number of
> struct page traverses during memory hotplug.
> 
> - Fixes some issues with hotplugging, where boundaries
> were not properly checked. And on x86 block size was not properly aligned
> with end of memory
> 
> - Also, potentially improves boot performance by eliminating condition from
>   __init_single_page().
> 
> - Adds robustness by verifying that that struct pages are correctly
>   poisoned when flags are accessed.

I'm now attempting to get a 100% review rate on MM patches, which is
why I started adding my Reviewed-by: when I do that thing.

I'm not familiar enough with this code to add my own Reviewed-by:, and
we'll need to figure out what to do in such cases.  I shall be sending
out periodic review-status summaries.

If you're able to identify a suitable reviewer for this work and to
offer them beer, that would help.  Let's see what happens as the weeks
unfold.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
