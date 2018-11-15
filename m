Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C10186B000A
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 02:35:00 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c3so5732481eda.3
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 23:35:00 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m5si5223007edv.193.2018.11.14.23.34.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 23:34:59 -0800 (PST)
Date: Thu, 15 Nov 2018 08:34:57 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, memory_hotplug: do not clear numa_node
 association after hot_remove
Message-ID: <20181115073457.GB23831@dhcp22.suse.cz>
References: <20181108100413.966-1-mhocko@kernel.org>
 <20181114071442.GB23419@dhcp22.suse.cz>
 <20181114151809.06c43a508cc773d3a5ee04f4@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181114151809.06c43a508cc773d3a5ee04f4@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Oscar Salvador <OSalvador@suse.com>, LKML <linux-kernel@vger.kernel.org>, Wen Congyang <tangchen@cn.fujitsu.com>, Tang Chen <wency@cn.fujitsu.com>, Miroslav Benes <mbenes@suse.cz>, Vlastimil Babka <vbabka@suse.cz>

On Wed 14-11-18 15:18:09, Andrew Morton wrote:
> On Wed, 14 Nov 2018 08:14:42 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > It seems there were no objections here. So can we have it in linux-next
> > for a wider testing a possibly target the next merge window?
> > 
> 
> top-posting sucks!

I thought it would make your life easier in this case. Will do it
differently next time.

> I already have this queued for 4.21-rc1.

Thanks! I must have missed the mm-commit email.

-- 
Michal Hocko
SUSE Labs
