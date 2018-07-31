Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id CCA2A6B026B
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 10:54:32 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id o6-v6so13339146qtp.15
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 07:54:32 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id d132-v6si793627qkg.18.2018.07.31.07.54.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jul 2018 07:54:32 -0700 (PDT)
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6VEsDoQ108123
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 14:54:31 GMT
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp2130.oracle.com with ESMTP id 2kge0d1j06-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 14:54:31 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w6VEsTdq014857
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 14:54:29 GMT
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w6VEsSHq022608
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 14:54:28 GMT
Received: by mail-oi0-f42.google.com with SMTP id b15-v6so28450382oib.10
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 07:54:28 -0700 (PDT)
MIME-Version: 1.0
References: <20180731124504.27582-1-osalvador@techadventures.net>
 <CAGM2rebds=A5m1ZB1LtD7oxMzM9gjVQvm-QibHjEENmXViw5eA@mail.gmail.com>
 <20180731144157.GA1499@techadventures.net> <20180731144545.fh5syvwcecgvqul6@xakep.localdomain>
 <20180731145125.GB1499@techadventures.net>
In-Reply-To: <20180731145125.GB1499@techadventures.net>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Tue, 31 Jul 2018 10:53:52 -0400
Message-ID: <CAGM2reZSZHdWECr8-7pj6j=CtjWVF2oKC9SwHhMuOsDkigdzgA@mail.gmail.com>
Subject: Re: [PATCH] mm: make __paginginit based on CONFIG_MEMORY_HOTPLUG
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, kirill.shutemov@linux.intel.com, iamjoonsoo.kim@lge.com, Mel Gorman <mgorman@suse.de>, Souptick Joarder <jrdr.linux@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, osalvador@suse.de

Thats correct on arches where no sparsemem setup_usemap() will not be
freed up. It is a tiny function, just a few instructions. Not a big
deal.

Pavel
On Tue, Jul 31, 2018 at 10:51 AM Oscar Salvador
<osalvador@techadventures.net> wrote:
>
> On Tue, Jul 31, 2018 at 10:45:45AM -0400, Pavel Tatashin wrote:
> > Here the patch would look like this:
> >
> > From e640b32dbd329bba5a785cc60050d5d7e1ca18ce Mon Sep 17 00:00:00 2001
> > From: Pavel Tatashin <pasha.tatashin@oracle.com>
> > Date: Tue, 31 Jul 2018 10:37:44 -0400
> > Subject: [PATCH] mm: remove __paginginit
> >
> > __paginginit is the same thing as __meminit except for platforms without
> > sparsemem, there it is defined as __init.
> >
> > Remove __paginginit and use __meminit. Use __ref in one single function
> > that merges __meminit and __init sections: setup_usemap().
> >
> > Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
>
> Uhm, I am probably missing something, but with this change, the functions will not be freed up
> while freeing init memory, right?
>
> Thanks
> --
> Oscar Salvador
> SUSE L3
>
