Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id B8C8A6B0005
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 16:50:53 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id r3-v6so5279357wrj.21
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 13:50:53 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q201-v6sor2329191wmg.15.2018.08.09.13.50.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 Aug 2018 13:50:52 -0700 (PDT)
Date: Thu, 9 Aug 2018 22:50:50 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [RFC PATCH 2/3] mm/memory_hotplug: Create __shrink_pages and
 move it to offline_pages
Message-ID: <20180809205050.GA17222@techadventures.net>
References: <20180807133757.18352-3-osalvador@techadventures.net>
 <20180807135221.GA3301@redhat.com>
 <20180807145900.GH10003@dhcp22.suse.cz>
 <20180807151810.GB3301@redhat.com>
 <20180808064758.GB27972@dhcp22.suse.cz>
 <20180808165814.GB3429@redhat.com>
 <20180809082415.GB24884@dhcp22.suse.cz>
 <20180809142709.GA3386@redhat.com>
 <20180809150950.GB15611@dhcp22.suse.cz>
 <20180809165821.GC3386@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180809165821.GC3386@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, dan.j.williams@intel.com, pasha.tatashin@oracle.com, david@redhat.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Thu, Aug 09, 2018 at 12:58:21PM -0400, Jerome Glisse wrote:
> > I would really prefer to be explicit about these requirements rather
> > than having subtle side effects quite deep in the memory hotplug code
> > and checks for zone device sprinkled at places for special handling.
> 
> I agree, i never thought about that before. Looking at existing resource
> management i think the simplest solution would be to use a refcount on the
> resources instead of the IORESOURCE_BUSY flags.
> 
> So when you release resource as part of hotremove you would only dec the
> refcount and a resource is not busy only when refcount is zero.
> 
> Just the idea i had in mind. Right now i am working on other thing, Oscar
> is this something you would like to work on ? Feel free to come up with
> something better than my first idea :)

Hi Jerome,

Definetly it would be something I am interested to work on.
Let me think a bit about this and see if I can come up with something.

Thanks
-- 
Oscar Salvador
SUSE L3
