Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id AA1C16B0531
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 08:17:59 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id q189so2236399wmd.6
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 05:17:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m9si25706668wrb.367.2017.08.01.05.17.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Aug 2017 05:17:58 -0700 (PDT)
Date: Tue, 1 Aug 2017 14:17:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 09/15] mm/hmm/devmem: device memory hotplug using
 ZONE_DEVICE v6
Message-ID: <20170801121755.GJ15774@dhcp22.suse.cz>
References: <20170628180047.5386-1-jglisse@redhat.com>
 <20170628180047.5386-10-jglisse@redhat.com>
 <20170728111003.GA2278@dhcp22.suse.cz>
 <20170731172122.GA24626@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170731172122.GA24626@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Mon 31-07-17 13:21:24, Jerome Glisse wrote:
> On Fri, Jul 28, 2017 at 01:10:03PM +0200, Michal Hocko wrote:
> > I haven't seen a newer version posted but the same comment applies on
> > your hmm-v25-4.9 git version from
> > git://people.freedesktop.org/~glisse/linux
> > 
> > On Wed 28-06-17 14:00:41, Jerome Glisse wrote:
> > > This introduce a simple struct and associated helpers for device driver
> > > to use when hotpluging un-addressable device memory as ZONE_DEVICE. It
> > > will find a unuse physical address range and trigger memory hotplug for
> > > it which allocates and initialize struct page for the device memory.
> > 
> > Please document the hotplug semantic some more please (who is in charge,
> > what is the lifetime, userspace API to add/remove this memory if any
> > etc...).
> > 
> > I can see you call add_pages. Please document why arch_add_memory (like
> > devm_memremap_pages) is not used. You also never seem to online the
> > range which is in line with nvdim usage and it is OK. But then I fail to
> > understand why you need
> 
> I added documentation in function and in commit message:
> https://cgit.freedesktop.org/~glisse/linux/commit/?h=hmm-next&id=33e236a64da84423c83db401fc62ea13877111f2

OK, that makes more clear. Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
