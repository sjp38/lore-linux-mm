Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 489496B027B
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 09:47:18 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b12-v6so3182412edi.12
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 06:47:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v27-v6si5435876eda.162.2018.07.19.06.47.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 06:47:17 -0700 (PDT)
Date: Thu, 19 Jul 2018 15:47:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 2/5] mm: access zone->node via zone_to_nid() and
 zone_set_nid()
Message-ID: <20180719134716.GF7193@dhcp22.suse.cz>
References: <20180719132740.32743-1-osalvador@techadventures.net>
 <20180719132740.32743-3-osalvador@techadventures.net>
 <20180719134018.GB7193@dhcp22.suse.cz>
 <760195c6-7cfb-76db-1c5c-b85456f3a4ad@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <760195c6-7cfb-76db-1c5c-b85456f3a4ad@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: osalvador@techadventures.net, akpm@linux-foundation.org, vbabka@suse.cz, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

On Thu 19-07-18 09:44:09, Pavel Tatashin wrote:
> 
> 
> On 07/19/2018 09:40 AM, Michal Hocko wrote:
> > On Thu 19-07-18 15:27:37, osalvador@techadventures.net wrote:
> >> From: Pavel Tatashin <pasha.tatashin@oracle.com>
> >>
> >> zone->node is configured only when CONFIG_NUMA=y, so it is a good idea to
> >> have inline functions to access this field in order to avoid ifdef's in
> >> c files.
> > 
> > Is this a manual find & replace or did you use some scripts?
> 
> I used opengrok:
> 
> http://src.illumos.org/source/search?q=%22zone-%3Enode%22&defs=&refs=&path=&hist=&project=linux-master
> 
> http://src.illumos.org/source/search?q=%22z-%3Enode%22&defs=&refs=&path=&hist=&project=linux-master

Then it is good to mention that in the changelog so that people might
use the same tool locally and compare the result or even learn about the
tool ;)
 
> > The change makes sense, but I haven't checked that all the places are
> > replaced properly. If not we can replace them later.
> > 
> >> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> >> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> >> Reviewed-by: Oscar Salvador <osalvador@suse.de>
> > 
> > Acked-by: Michal Hocko <mhocko@suse.com>
> 
> Thank you,
> Pavel

-- 
Michal Hocko
SUSE Labs
