Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D77606B000D
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 12:43:08 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l1-v6so1069793edi.11
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 09:43:08 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k35-v6si1580174edd.227.2018.07.26.09.43.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 09:43:07 -0700 (PDT)
Date: Thu, 26 Jul 2018 18:43:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 2/5] mm: access zone->node via zone_to_nid() and
 zone_set_nid()
Message-ID: <20180726164304.GP28386@dhcp22.suse.cz>
References: <20180725220144.11531-1-osalvador@techadventures.net>
 <20180725220144.11531-3-osalvador@techadventures.net>
 <20180726080500.GX28386@dhcp22.suse.cz>
 <20180726081215.GC22028@techadventures.net>
 <20180726151420.uigttpoclcka6h4h@xakep.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180726151420.uigttpoclcka6h4h@xakep.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Oscar Salvador <osalvador@techadventures.net>, akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, Oscar Salvador <osalvador@suse.de>

On Thu 26-07-18 11:14:20, Pavel Tatashin wrote:
> Hi Oscar,
> 
> Below is updated patch, with comment about OpenGrok and Acked-by Michal added.
> 
> Thank you,
> Pavel
> 
> >From cca1b083d78d0ff99cce6dfaf12f6380d76390c7 Mon Sep 17 00:00:00 2001
> From: Pavel Tatashin <pasha.tatashin@oracle.com>
> Date: Thu, 26 Jul 2018 00:01:41 +0200
> Subject: [PATCH] mm: access zone->node via zone_to_nid() and zone_set_nid()
> 
> zone->node is configured only when CONFIG_NUMA=y, so it is a good idea to
> have inline functions to access this field in order to avoid ifdef's in
> c files.
> 
> OpenGrok was used to find places where zone->node is accessed. A public one
> is available here: http://src.illumos.org/source/

I assume that tool uses some pattern matching or similar so steps to use
the tool to get your results would be more helpful. This is basically
the same thing as coccinelle generated patches.

-- 
Michal Hocko
SUSE Labs
