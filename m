Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 85B5B6B0003
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 03:15:24 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id f15so1403379wmd.1
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 00:15:24 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x1si4478449wrg.466.2018.02.01.00.15.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Feb 2018 00:15:22 -0800 (PST)
Date: Thu, 1 Feb 2018 09:15:20 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/swap: add function get_total_swap_pages to expose
 total_swap_pages
Message-ID: <20180201081520.GF21609@dhcp22.suse.cz>
References: <1517214582-30880-1-git-send-email-Hongbo.He@amd.com>
 <20180129163114.GH21609@dhcp22.suse.cz>
 <MWHPR1201MB01278542F6EE848ABD187BDBFDE40@MWHPR1201MB0127.namprd12.prod.outlook.com>
 <20180130075553.GM21609@dhcp22.suse.cz>
 <9060281e-62dd-8775-2903-339ff836b436@amd.com>
 <20180130101823.GX21609@dhcp22.suse.cz>
 <7d5ce7ab-d16d-36bc-7953-e1da2db350bf@amd.com>
 <20180130122853.GC21609@dhcp22.suse.cz>
 <MWHPR1201MB0127CEE71F679F43BF0D25B6FDFA0@MWHPR1201MB0127.namprd12.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <MWHPR1201MB0127CEE71F679F43BF0D25B6FDFA0@MWHPR1201MB0127.namprd12.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "He, Roger" <Hongbo.He@amd.com>
Cc: "Koenig, Christian" <Christian.Koenig@amd.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>

On Thu 01-02-18 06:13:20, He, Roger wrote:
> Hi Michal:
> 
> How about only  
> EXPORT_SYMBOL_GPL(total_swap_pages) ?

I've already expressed that messing up with the amount of swap pages is
a wrong approach. You should scale your additional buffers according the
the current memory pressure. There are other users of memory on the
system other than your subsystem.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
