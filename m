Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A42336B0003
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 07:42:27 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id y13-v6so323998wma.1
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 04:42:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y199-v6sor818227wmd.8.2018.07.23.04.42.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Jul 2018 04:42:26 -0700 (PDT)
Date: Mon, 23 Jul 2018 13:42:24 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v2 3/5] mm/page_alloc: Optimize free_area_init_core
Message-ID: <20180723114224.GA7104@techadventures.net>
References: <20180719132740.32743-1-osalvador@techadventures.net>
 <20180719132740.32743-4-osalvador@techadventures.net>
 <20180719134417.GC7193@dhcp22.suse.cz>
 <20180719140327.GB10988@techadventures.net>
 <20180719151555.GH7193@dhcp22.suse.cz>
 <20180719205235.GA14010@techadventures.net>
 <20180720100327.GA19478@techadventures.net>
 <20180723083519.GG17905@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180723083519.GG17905@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, pasha.tatashin@oracle.com, vbabka@suse.cz, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

On Mon, Jul 23, 2018 at 10:35:19AM +0200, Michal Hocko wrote:
> No, I do not think this is much better. Why do we need to separate those
> functions out? I think you are too focused on the current function
> without a broader context. Think about it. We have two code paths.
> Early initialization and the hotplug. The two are subtly different in
> some aspects. Maybe reusing free_area_init_core is the wrong thing and
> we should have a dedicated subset of this function. This would make the
> code more clear probably. You wouldn't have to think which part of
> free_area_init_core is special and what has to be done if this function
> was to be used in a different context. See my point?

Yes, I see your point now.
I will think about it with a wider approach.

Thanks
-- 
Oscar Salvador
SUSE L3
