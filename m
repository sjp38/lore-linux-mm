Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8C8DE6B0008
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 10:12:29 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id q18-v6so1946538wrr.12
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 07:12:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v16-v6sor1819546wrr.24.2018.07.18.07.12.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Jul 2018 07:12:28 -0700 (PDT)
Date: Wed, 18 Jul 2018 16:12:26 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH 2/3] mm/page_alloc: Refactor free_area_init_core
Message-ID: <20180718141226.GA2588@techadventures.net>
References: <20180718124722.9872-1-osalvador@techadventures.net>
 <20180718124722.9872-3-osalvador@techadventures.net>
 <20180718133647.GD7193@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180718133647.GD7193@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, pasha.tatashin@oracle.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, aaron.lu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

On Wed, Jul 18, 2018 at 03:36:47PM +0200, Michal Hocko wrote:
> On Wed 18-07-18 14:47:21, osalvador@techadventures.net wrote:
> > From: Oscar Salvador <osalvador@suse.de>
> > 
> > When free_area_init_core gets called from the memhotplug code,
> > we only need to perform some of the operations in
> > there.
> 
> Which ones? Or other way around. Which we do not want to do and why?
> 
> > Since memhotplug code is the only place where free_area_init_core
> > gets called while node being still offline, we can better separate
> > the context from where it is called.
> 
> I really do not like this if node is offline than only perform half of
> the function. This will generate more mess in the future. Why don't you
> simply. If we can split out this code into logical units then let's do
> that but no, please do not make random ifs for hotplug code paths.
> Sooner or later somebody will simply don't know what is needed and what
> is not.

Yes, you are right.
I gave it another thought and it was not a really good idea.
Although I think the code from free_area_init_core can be simplified.

I will try to come up with something that makes more sense.

Thanks
-- 
Oscar Salvador
SUSE L3
