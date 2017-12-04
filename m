Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5D7686B027F
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 07:34:07 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id n6so12998083pfg.19
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 04:34:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 3si9649221ple.169.2017.12.04.04.34.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Dec 2017 04:34:06 -0800 (PST)
Date: Mon, 4 Dec 2017 13:33:56 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 4/5] mm: memory_hotplug: Add memory hotremove probe
 device
Message-ID: <20171204123355.4tam7pfv34zmwzyu@dhcp22.suse.cz>
References: <cover.1511433386.git.ar@linux.vnet.ibm.com>
 <22d34fe30df0fbacbfceeb47e20cb1184af73585.1511433386.git.ar@linux.vnet.ibm.com>
 <20171130144905.ntpovhy66gekj6e6@dhcp22.suse.cz>
 <20171204115129.GD6373@samekh>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171204115129.GD6373@samekh>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Reale <ar@linux.vnet.ibm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, m.bielski@virtualopensystems.com, arunks@qti.qualcomm.com, mark.rutland@arm.com, scott.branden@broadcom.com, will.deacon@arm.com, qiuxishi@huawei.com, catalin.marinas@arm.com, realean2@ie.ibm.com

On Mon 04-12-17 11:51:29, Andrea Reale wrote:
> On Thu 30 Nov 2017, 15:49, Michal Hocko wrote:
> > On Thu 23-11-17 11:14:52, Andrea Reale wrote:
> > > Adding a "remove" sysfs handle that can be used to trigger
> > > memory hotremove manually, exactly simmetrically with
> > > what happens with the "probe" device for hot-add.
> > > 
> > > This is usueful for architecture that do not rely on
> > > ACPI for memory hot-remove.
> > 
> > As already said elsewhere, this really has to check the online status of
> > the range and fail some is still online.
> > 
> 
> This is actually still done in remove_memory() (patch 2/5) with
> walk_memory_range. We just return an error rather than BUGing().
> 
> Or are you referring to something else?

But you are not returning that error to the caller, are you?

[...]
> > > +	nid = memory_add_physaddr_to_nid(phys_addr);
> > > +	ret = lock_device_hotplug_sysfs();
> > > +	if (ret)
> > > +		return ret;
> > > +
> > > +	remove_memory(nid, phys_addr,
> > > +			 MIN_MEMORY_BLOCK_SIZE * sections_per_block);
> > > +	unlock_device_hotplug();
> > > +	return count;

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
