Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 575166B209C
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 10:18:09 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id s50so1427436edd.11
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 07:18:09 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y2-v6si5419980ejp.179.2018.11.20.07.18.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 07:18:08 -0800 (PST)
Date: Tue, 20 Nov 2018 16:18:06 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/3] mm, memory_hotplug: deobfuscate migration part
 of offlining
Message-ID: <20181120151806.GQ22247@dhcp22.suse.cz>
References: <20181120134323.13007-1-mhocko@kernel.org>
 <20181120134323.13007-3-mhocko@kernel.org>
 <1542726815.6817.8.camel@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1542726815.6817.8.camel@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador <osalvador@suse.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Hildenbrand <david@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 20-11-18 16:13:35, Oscar Salvador wrote:
> 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> [...]
> > +	do {
> > +		for (pfn = start_pfn; pfn;)
> > +		{
> > +			/* start memory hot removal */
> 
> Should we change thAT comment? I mean, this is not really the hot-
> removal stage.
> 
> Maybe "start memory migration" suits better? or memory offlining?

I will just drop it. It doesn't really explain anything.
[...]
> 
> This indeed looks much nicer and it is easier to follow.
> With the changes commented by David:
> 
> Reviewed-by: Oscar Salvador <osalvador@suse.de>

Thanks!

-- 
Michal Hocko
SUSE Labs
