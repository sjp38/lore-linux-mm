Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1AF626B0033
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 13:49:08 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k15so10422544wrc.1
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 10:49:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 60si5741698wrp.1.2017.10.23.10.49.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Oct 2017 10:49:06 -0700 (PDT)
Date: Mon, 23 Oct 2017 19:49:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: fix movable_node kernel command-line
Message-ID: <20171023174905.ap4uz6puggeqnz3s@dhcp22.suse.cz>
References: <ad310dfbfb86ef4f1f9a173cad1a030e879d572e.1508536900.git.sharath.k.bhat@linux.intel.com>
 <20171023125213.whdiev6bjxr72gow@dhcp22.suse.cz>
 <20171023160314.GA11853@linux.intel.com>
 <20171023161554.zltjcls34kr4234m@dhcp22.suse.cz>
 <20171023171435.GA12025@linux.intel.com>
 <20171023172008.kr6dzpe63nfpgps7@dhcp22.suse.cz>
 <20171023173544.GA12198@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171023173544.GA12198@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sharath Kumar Bhat <sharath.k.bhat@linux.intel.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

On Mon 23-10-17 10:35:44, Sharath Kumar Bhat wrote:
> On Mon, Oct 23, 2017 at 07:20:08PM +0200, Michal Hocko wrote:
> > On Mon 23-10-17 10:14:35, Sharath Kumar Bhat wrote:
> > [...]
> > > This lets admin to configure the kernel to have movable memory > size of
> > > hotpluggable memories and at the same time hotpluggable nodes have only
> > > movable memory.
> > 
> > Put aside that I believe that having too much of movable memory is
> > dangerous and people are not very prepared for that fact, what is the
> > specific usecase. Allowing users something is nice but as I've said the
> > interface is ugly already and putting more on top is not very desirable.
> > 
> > > This is useful because it lets user to have more movable
> > > memory in the system that can be offlined/onlined. When the same hardware
> > > is shared between two OS's then this helps to dynamically provision the
> > > physical memory between them by offlining/onlining as and when the
> > > application/user need changes.
> > 
> > just use hotplugable memory for that purpose. The latest memory hotplug
> > code allows you to online memory into a kernel or movable zone as per
> > admin policy without the previously hardcoded zone ordering. So I really
> > fail to see why to mock with the command line parameter at all.
> 
> Yes, but it won't let us offline the memory blocks if they are already
> in use by kernel allocations. This is more likely over a long period of
> uptime. The command-line ensures that the memory blocks are movable all
> the time as reserved by the admin from the boot.

I am really confused about your usecase then. Why do you want to make
non-hotplugable memory to be movable then?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
