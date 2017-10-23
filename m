Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id EDDB46B0253
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 13:20:10 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id d21so1422260wma.20
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 10:20:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k7si5889515wrc.509.2017.10.23.10.20.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Oct 2017 10:20:09 -0700 (PDT)
Date: Mon, 23 Oct 2017 19:20:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: fix movable_node kernel command-line
Message-ID: <20171023172008.kr6dzpe63nfpgps7@dhcp22.suse.cz>
References: <ad310dfbfb86ef4f1f9a173cad1a030e879d572e.1508536900.git.sharath.k.bhat@linux.intel.com>
 <20171023125213.whdiev6bjxr72gow@dhcp22.suse.cz>
 <20171023160314.GA11853@linux.intel.com>
 <20171023161554.zltjcls34kr4234m@dhcp22.suse.cz>
 <20171023171435.GA12025@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171023171435.GA12025@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sharath Kumar Bhat <sharath.k.bhat@linux.intel.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

On Mon 23-10-17 10:14:35, Sharath Kumar Bhat wrote:
[...]
> This lets admin to configure the kernel to have movable memory > size of
> hotpluggable memories and at the same time hotpluggable nodes have only
> movable memory.

Put aside that I believe that having too much of movable memory is
dangerous and people are not very prepared for that fact, what is the
specific usecase. Allowing users something is nice but as I've said the
interface is ugly already and putting more on top is not very desirable.

> This is useful because it lets user to have more movable
> memory in the system that can be offlined/onlined. When the same hardware
> is shared between two OS's then this helps to dynamically provision the
> physical memory between them by offlining/onlining as and when the
> application/user need changes.

just use hotplugable memory for that purpose. The latest memory hotplug
code allows you to online memory into a kernel or movable zone as per
admin policy without the previously hardcoded zone ordering. So I really
fail to see why to mock with the command line parameter at all.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
