Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id EED916B0033
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 13:57:53 -0400 (EDT)
Received: by mail-ee0-f53.google.com with SMTP id c41so3920190eek.26
        for <linux-mm@kvack.org>; Tue, 09 Jul 2013 10:57:52 -0700 (PDT)
Date: Tue, 9 Jul 2013 19:57:49 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130709175749.GA31848@dhcp22.suse.cz>
References: <20130701012558.GB27780@dastard>
 <20130701075005.GA28765@dhcp22.suse.cz>
 <20130701081056.GA4072@dastard>
 <20130702092200.GB16815@dhcp22.suse.cz>
 <20130702121947.GE14996@dastard>
 <20130702124427.GG16815@dhcp22.suse.cz>
 <20130703112403.GP14996@dastard>
 <20130704163643.GF7833@dhcp22.suse.cz>
 <20130708125352.GC20149@dhcp22.suse.cz>
 <20130709173242.GA9098@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130709173242.GA9098@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 09-07-13 21:32:51, Glauber Costa wrote:
[...]
> You seem to have switched to XFS.

Yes, to make sure that the original hang is not fs specific. I can
switch to other fs if it helps. This seems to be really hard to
reproduce now so I would rather not change things if possible.

> Dave posted a patch two days ago fixing some missing conversions in
> the XFS side. AFAIK, Andrew hasn't yet picked the patch.

Could you point me to those patches, please?

> Are you running with that patch applied?

I am currently running with "list_lru: fix broken LRU_RETRY behaviour"

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
