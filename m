Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B4B4E6B0022
	for <linux-mm@kvack.org>; Tue,  3 May 2011 12:35:55 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4392cMd012538
	for <linux-mm@kvack.org>; Tue, 3 May 2011 03:02:38 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p43GZlo6142934
	for <linux-mm@kvack.org>; Tue, 3 May 2011 10:35:47 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p43GZjJA014952
	for <linux-mm@kvack.org>; Tue, 3 May 2011 10:35:46 -0600
Subject: Re: [PATCH V2] xen/balloon: Memory hotplug support for Xen balloon
 driver
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110502220148.GI4623@router-fw-old.local.net-space.pl>
References: <20110502220148.GI4623@router-fw-old.local.net-space.pl>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Tue, 03 May 2011 09:32:33 -0700
Message-ID: <1304440353.30823.73.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 2011-05-03 at 00:01 +0200, Daniel Kiper wrote:
> @@ -448,6 +575,14 @@ static int __init balloon_init(void)
>         balloon_stats.retry_count = 1;
>         balloon_stats.max_retry_count = RETRY_UNLIMITED;
> 
> +#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
> +       balloon_stats.hotplug_pages = 0;
> +       balloon_stats.balloon_hotplug = 0;
> +
> +       register_online_page_callback(&xen_online_page);
> +       register_memory_notifier(&xen_memory_nb);
> +#endif 

This is 100% static, apparently.  XEN_BALLOON can't be a module, so I
still don't see the point of having the un/register stuff.  

-- Dave


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
