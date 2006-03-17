Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k2HHxD9B007442
	for <linux-mm@kvack.org>; Fri, 17 Mar 2006 12:59:13 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k2HHuIAg261494
	for <linux-mm@kvack.org>; Fri, 17 Mar 2006 10:56:18 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k2HHxCRX013013
	for <linux-mm@kvack.org>; Fri, 17 Mar 2006 10:59:13 -0700
Subject: Re: [PATCH: 012/017]Memory hotplug for new nodes v.4.(rebuild
	zonelists after online pages)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20060317163612.C64F.Y-GOTO@jp.fujitsu.com>
References: <20060317163612.C64F.Y-GOTO@jp.fujitsu.com>
Content-Type: text/plain
Date: Fri, 17 Mar 2006 09:58:17 -0800
Message-Id: <1142618297.10906.97.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2006-03-17 at 17:22 +0900, Yasunori Goto wrote:
> +++ pgdat8/mm/memory_hotplug.c  2006-03-17 13:53:40.712581399 +0900
> @@ -123,6 +123,7 @@ int online_pages(unsigned long pfn, unsi
>         unsigned long flags;
>         unsigned long onlined_pages = 0;
>         struct zone *zone;
> +       int need_refresh_zonelist = 0; 

I'd make this "need_to_rebuild_zonelists" or "need_zonelists_rebuild".
I think those sound a little bit better.

Plus, it makes even more sense when you see:

       if (need_to_rebuild_zonelists)
               build_all_zonelists();

if the names all match up.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
