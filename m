Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B074E8E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 08:21:34 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z30-v6so795215edd.19
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 05:21:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w7-v6si518025edd.362.2018.09.12.05.21.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 05:21:33 -0700 (PDT)
Date: Wed, 12 Sep 2018 14:21:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memory_hotplug: fix the panic when memory end is not on
 the section boundary
Message-ID: <20180912122132.GF10951@dhcp22.suse.cz>
References: <20180910123527.71209-1-zaslonko@linux.ibm.com>
 <20180910131754.GG10951@dhcp22.suse.cz>
 <04b427ad-df4e-67bd-2942-2a7a2cccf1aa@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <04b427ad-df4e-67bd-2942-2a7a2cccf1aa@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zaslonko Mikhail <zaslonko@linux.vnet.ibm.com>
Cc: Mikhail Zaslonko <zaslonko@linux.ibm.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pavel.Tatashin@microsoft.com, osalvador@suse.de, gerald.schaefer@de.ibm.com

On Tue 11-09-18 16:06:23, Zaslonko Mikhail wrote:
[...]
> > Well, I am afraid this is not the proper solution. We are relying on the
> > full pageblock worth of initialized struct pages at many other place. We
> > used to do that in the past because we have initialized the full
> > section but this has been changed recently. Pavel, do you have any ideas
> > how to deal with this partial mem sections now?
> 
> I think this is not related to the recent changes of memory initialization.
> If
> you mean deferred init case, the problem exists even without
> CONFIG_DEFERRED_STRUCT_PAGE_INIT kernel option.

This is more about struct page initialization (which doesn't clear
whole) memmap area and as such it stays unitialized. So you are right
this is a much older issue we just happened to not notice without
explicit memmap poisoning.
-- 
Michal Hocko
SUSE Labs
