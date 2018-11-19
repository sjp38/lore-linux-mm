Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 30F346B1ABD
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 09:15:08 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x1-v6so15287072edh.8
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 06:15:08 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o2-v6sor6786552eja.51.2018.11.19.06.15.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Nov 2018 06:15:06 -0800 (PST)
Date: Mon, 19 Nov 2018 14:15:05 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, page_alloc: fix calculation of pgdat->nr_zones
Message-ID: <20181119141505.xugul3s5nbzssybm@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181117022022.9956-1-richard.weiyang@gmail.com>
 <1542622061.3002.6.camel@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1542622061.3002.6.camel@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador <osalvador@suse.de>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, mhocko@suse.com, dave.hansen@intel.com, linux-mm@kvack.org

On Mon, Nov 19, 2018 at 11:07:41AM +0100, osalvador wrote:
>
>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>
>Good catch.
>
>One thing I was wondering is that if we also should re-adjust it when a
>zone gets emptied during offlining memory.
>I checked, and whenever we work wirh pgdat->nr_zones we seem to check
>if the zone is populated in order to work with it.
>But still, I wonder if we should re-adjust it.

Well, thanks all for comments. I am glad you like it.

Actually, I have another proposal or I notice another potential issue.

In case user online pages in parallel, we may face a contention and get
a wrong nr_zones.

If this analysis is correct, I propose to have a lock around this.

Look forward your comments :-)

>
>Reviewed-by: Oscar Salvador <osalvador@suse.de>
>
>Oscar Salvador
>

-- 
Wei Yang
Help you, Help me
