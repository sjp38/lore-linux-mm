Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 68EE06B0069
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 15:05:02 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l8so5945652wre.19
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 12:05:02 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g25si5079697wrb.544.2017.10.23.12.05.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Oct 2017 12:05:01 -0700 (PDT)
Date: Mon, 23 Oct 2017 21:04:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: fix movable_node kernel command-line
Message-ID: <20171023190459.odyu26rqhuja4trj@dhcp22.suse.cz>
References: <ad310dfbfb86ef4f1f9a173cad1a030e879d572e.1508536900.git.sharath.k.bhat@linux.intel.com>
 <20171023125213.whdiev6bjxr72gow@dhcp22.suse.cz>
 <20171023160314.GA11853@linux.intel.com>
 <20171023161554.zltjcls34kr4234m@dhcp22.suse.cz>
 <20171023171435.GA12025@linux.intel.com>
 <20171023172008.kr6dzpe63nfpgps7@dhcp22.suse.cz>
 <20171023173544.GA12198@linux.intel.com>
 <20171023174905.ap4uz6puggeqnz3s@dhcp22.suse.cz>
 <20171023184852.GB12198@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171023184852.GB12198@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sharath Kumar Bhat <sharath.k.bhat@linux.intel.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

On Mon 23-10-17 11:48:52, Sharath Kumar Bhat wrote:
> On Mon, Oct 23, 2017 at 07:49:05PM +0200, Michal Hocko wrote:
[...]
> > I am really confused about your usecase then. Why do you want to make
> > non-hotplugable memory to be movable then?
> 
> Lets say,
> 
> The required total memory in the system which can be dynamically
> offlined/onlined, T = M + N
> 
> M = movable memory in non-hotpluggable memory (say DDR in the example)

Why do you need this memory to be on/offlineable if you cannot hotplug
it?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
