Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 30D826B0038
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 15:56:41 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n89so16824645pfk.17
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 12:56:41 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id j6si1848190pll.664.2017.10.23.12.56.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Oct 2017 12:56:39 -0700 (PDT)
Date: Mon, 23 Oct 2017 12:56:37 -0700
From: Sharath Kumar Bhat <sharath.k.bhat@linux.intel.com>
Subject: Re: [PATCH] mm: fix movable_node kernel command-line
Message-ID: <20171023195637.GE12198@linux.intel.com>
Reply-To: sharath.k.bhat@linux.intel.com
References: <20171023160314.GA11853@linux.intel.com>
 <20171023161554.zltjcls34kr4234m@dhcp22.suse.cz>
 <20171023171435.GA12025@linux.intel.com>
 <20171023172008.kr6dzpe63nfpgps7@dhcp22.suse.cz>
 <20171023173544.GA12198@linux.intel.com>
 <20171023174905.ap4uz6puggeqnz3s@dhcp22.suse.cz>
 <20171023184852.GB12198@linux.intel.com>
 <20171023190459.odyu26rqhuja4trj@dhcp22.suse.cz>
 <20171023192524.GC12198@linux.intel.com>
 <20171023193536.c7yptc4tpesa4ffl@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171023193536.c7yptc4tpesa4ffl@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sharath Kumar Bhat <sharath.k.bhat@linux.intel.com>, linux-mm@kvack.org, akpm@linux-foundation.org

On Mon, Oct 23, 2017 at 09:35:36PM +0200, Michal Hocko wrote:
> On Mon 23-10-17 12:25:24, Sharath Kumar Bhat wrote:
> > On Mon, Oct 23, 2017 at 09:04:59PM +0200, Michal Hocko wrote:
> > > On Mon 23-10-17 11:48:52, Sharath Kumar Bhat wrote:
> > > > On Mon, Oct 23, 2017 at 07:49:05PM +0200, Michal Hocko wrote:
> > > [...]
> > > > > I am really confused about your usecase then. Why do you want to make
> > > > > non-hotplugable memory to be movable then?
> > > > 
> > > > Lets say,
> > > > 
> > > > The required total memory in the system which can be dynamically
> > > > offlined/onlined, T = M + N
> > > > 
> > > > M = movable memory in non-hotpluggable memory (say DDR in the example)
> > > 
> > > Why do you need this memory to be on/offlineable if you cannot hotplug
> > > it?
> > 
> > We do not need the memory to be physcially hot added/removed. Instead we
> > just want it to be logically offlined so that these memory blocks are
> > no longer used by the OS which has offlined it and can be used by the
> > second OS. Once it is done using the memory for a certain use case it
> > can be returned back by onlining it.
> 
> I am sorry for being dense here but why cannot you mark that memory
> hotplugable? I assume you are under the control to set attributes of the
> memory to the guest.

When I said two OS's I meant multi-kernel environment sharing the same
hardware and not VMs. So we do not have the control to mark the memory
hotpluggable as done by BIOS through SRAT.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
