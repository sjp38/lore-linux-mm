Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id E8FC1828E6
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 08:19:19 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id p63so164774409wmp.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 05:19:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i74si30397600wmc.39.2016.02.03.05.19.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 03 Feb 2016 05:19:18 -0800 (PST)
Date: Wed, 3 Feb 2016 14:19:31 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Persistent memory: pmem as storage
 device vs pmem as memory
Message-ID: <20160203131931.GH12574@quack.suse.cz>
References: <CAPcyv4jtbsc45r4EzZvLJhqCzB4X4nJmKdpQ8cE46gGkMaRB3w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jtbsc45r4EzZvLJhqCzB4X4nJmKdpQ8cE46gGkMaRB3w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-block@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>

On Tue 02-02-16 17:10:18, Dan Williams wrote:
> The current state of persistent memory enabling in Linux is that a
> physical memory range discovered by a device driver is exposed to the
> system as a block device.  That block device has the added property of
> being capable of DAX which, at its core, allows converting
> storage-device-sectors allocated to a file into pages that can be
> mmap()ed, DMAed, etc...
> 
> In that quick two sentence summary the impacted kernel sub-systems
> span mm, fs, block, and a device-driver.  As a result when a
> persistent memory design question arises there are mm, fs, block, and
> device-driver specific implications to consider.  Are there existing
> persistent memory handling features that could be better handled with
> a more "memory" vs "device" perspective?  What are we trading off?
> More importantly how do our current interfaces hold up when
> considering new features?
> 
> For example, how to support DAX in coordination with the BTT (atomic
> sector update) driver.  That might require a wider interface than the
> current bdev_direct_access() to tell the BTT driver when it is free to
> remap the block.  A wider ranging example, there are some that would
> like to see high capacity persistent memory as just another level in a
> system's volatile-memory hierarchy.  Depending on whom you ask that
> pmem tier looks like either page cache extensions, reworked/optimized
> swap, or a block-device-cache with DAX capabilities.
> 
> For LSF/MM, with all the relevant parties in the room, it would be
> useful to share some successes/pain-points of the direction to date
> and look at the interfaces/coordination we might need between
> sub-systems going forward.  Especially with respect to supporting pmem
> as one of a set of new performance differentiated memory types that
> need to be considered by the mm sub-system.

So do you want a BoF where we'd just exchange opinions and look into deeply
technical subtleties or do you want a general session where you'd like to
discuss some architectural decisions? Or both (but then we need to schedule
two sessions and clearly separate them)? For the general session my
experience shows you need rather clear problem statement (only the
integration with BTT looks like that in your proposal) or the discussion
leads nowhere...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
