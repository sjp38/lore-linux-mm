Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id F3EC36B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 02:55:56 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id z83so6376165wmc.5
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 23:55:56 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c6si8637995wma.275.2018.01.29.23.55.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Jan 2018 23:55:55 -0800 (PST)
Date: Tue, 30 Jan 2018 08:55:53 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/swap: add function get_total_swap_pages to expose
 total_swap_pages
Message-ID: <20180130075553.GM21609@dhcp22.suse.cz>
References: <1517214582-30880-1-git-send-email-Hongbo.He@amd.com>
 <20180129163114.GH21609@dhcp22.suse.cz>
 <MWHPR1201MB01278542F6EE848ABD187BDBFDE40@MWHPR1201MB0127.namprd12.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <MWHPR1201MB01278542F6EE848ABD187BDBFDE40@MWHPR1201MB0127.namprd12.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "He, Roger" <Hongbo.He@amd.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, "Koenig, Christian" <Christian.Koenig@amd.com>

On Tue 30-01-18 02:56:51, He, Roger wrote:
> Hi Michal:
> 
> We need a API to tell TTM module the system totally has how many swap
> cache.  Then TTM module can use it to restrict how many the swap cache
> it can use to prevent triggering OOM.  For Now we set the threshold of
> swap size TTM used as 1/2 * total size and leave the rest for others
> use.

Why do you so much memory? Are you going to use TB of memory on large
systems? What about memory hotplug when the memory is added/released?
 
> But get_nr_swap_pages is the only API we can accessed from other
> module now.  It can't cover the case of the dynamic swap size
> increment.  I mean: user can use "swapon" to enable new swap file or
> swap disk dynamically or "swapoff" to disable swap space.

Exactly. Your scaling configuration based on get_nr_swap_pages or the
available memory simply sounds wrong.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
