Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BDFED6B0003
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 11:01:17 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l4-v6so2537483wme.7
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 08:01:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n7-v6sor2941292wrj.83.2018.07.19.08.01.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Jul 2018 08:01:16 -0700 (PDT)
Date: Thu, 19 Jul 2018 17:01:14 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v2 5/5] mm/page_alloc: Only call pgdat_set_deferred_range
 when the system boots
Message-ID: <20180719150114.GC10988@techadventures.net>
References: <20180719132740.32743-1-osalvador@techadventures.net>
 <20180719132740.32743-6-osalvador@techadventures.net>
 <20180719134622.GE7193@dhcp22.suse.cz>
 <20180719135859.GA10988@techadventures.net>
 <20180719140308.GG7193@dhcp22.suse.cz>
 <CAGM2reZ-+njLtZSnNpry11frg85KmMk4WWxGdaqk1o4BUJVO1w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGM2reZ-+njLtZSnNpry11frg85KmMk4WWxGdaqk1o4BUJVO1w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: mhocko@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, osalvador@suse.de

On Thu, Jul 19, 2018 at 10:27:44AM -0400, Pavel Tatashin wrote:
> On Thu, Jul 19, 2018 at 10:03 AM Michal Hocko <mhocko@kernel.org> wrote:
> > I am not really sure. I am not a big fan of SYSTEM_BOOTING global
> > thingy so I would rather not spread its usage.
> 
> I agree, I do not think this patch is necessary. Calling
> pgdat_set_deferred_range() does not hurt in hotplug context, and it is
> cheap too. SYSTEM_BOOTING sometimes useful, but it is better to use it
> only where necessary, where without this "if" we will encounter some
> bugs.

Ok, let us drop it then ;-).

Thanks
-- 
Oscar Salvador
SUSE L3
