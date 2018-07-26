Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id C66236B0269
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 11:36:15 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id u68-v6so1666840qku.5
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 08:36:15 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id t68-v6si1588915qkl.70.2018.07.26.08.36.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 08:36:15 -0700 (PDT)
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6QFY1XV165910
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 15:36:14 GMT
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp2130.oracle.com with ESMTP id 2kbtbd3sbg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 15:36:14 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w6QFaCNE011612
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 15:36:13 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w6QFaC81010600
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 15:36:12 GMT
Received: by mail-oi0-f44.google.com with SMTP id w126-v6so3699730oie.7
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 08:36:12 -0700 (PDT)
MIME-Version: 1.0
References: <20180725220144.11531-1-osalvador@techadventures.net>
 <20180725220144.11531-5-osalvador@techadventures.net> <20180726081200.GY28386@dhcp22.suse.cz>
In-Reply-To: <20180726081200.GY28386@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Thu, 26 Jul 2018 11:35:35 -0400
Message-ID: <CAGM2rebcp=S+WN3owDWVSa3_6QqLzs=qbOFs76rhsxuepQ1ALw@mail.gmail.com>
Subject: Re: [PATCH v3 4/5] mm/page_alloc: Move initialization of node and
 zones to an own function
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: osalvador@techadventures.net, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, dan.j.williams@intel.com, osalvador@suse.de

> OK, this looks definitely better. I will have to check that all the
> required state is initialized properly. Considering the above
> explanation I would simply fold the follow up patch into this one. It is
> not so large it would get hard to review and you would make it clear why
> the work is done.

I will review this work, once Oscar combines patches 4 & 5 as Michal suggested.


>
> > +/*
> > + * Set up the zone data structures:
> > + *   - mark all pages reserved
> > + *   - mark all memory queues empty
> > + *   - clear the memory bitmaps
> > + *
> > + * NOTE: pgdat should get zeroed by caller.
> > + * NOTE: this function is only called during early init.
> > + */
> > +static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>
> now that this function is called only from the early init code we can
> make it s@__paginginit@__init@ AFAICS.

True, in patch 5. Also, zone_init_internals() should be marked as __paginginit.

Thank you,
Pavel
