Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id DC16F6B0007
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 10:44:05 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id i23-v6so13301892qtf.9
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 07:44:05 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id b10-v6si2331189qvj.135.2018.07.31.07.44.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jul 2018 07:44:05 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6VE8w19077517
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 14:44:04 GMT
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp2120.oracle.com with ESMTP id 2kggep1bt4-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 14:44:04 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w6VEi2f3011135
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 14:44:02 GMT
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w6VEi1qH018644
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 14:44:02 GMT
Received: by mail-oi0-f42.google.com with SMTP id k12-v6so28391215oiw.8
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 07:44:01 -0700 (PDT)
MIME-Version: 1.0
References: <20180731124504.27582-1-osalvador@techadventures.net>
 <CAGM2rebds=A5m1ZB1LtD7oxMzM9gjVQvm-QibHjEENmXViw5eA@mail.gmail.com> <20180731144157.GA1499@techadventures.net>
In-Reply-To: <20180731144157.GA1499@techadventures.net>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Tue, 31 Jul 2018 10:43:25 -0400
Message-ID: <CAGM2reYmwqQDfk7Lx-whqxDnAb41VU=dusJjGrP3zhNyYQQJcg@mail.gmail.com>
Subject: Re: [PATCH] mm: make __paginginit based on CONFIG_MEMORY_HOTPLUG
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, kirill.shutemov@linux.intel.com, iamjoonsoo.kim@lge.com, Mel Gorman <mgorman@suse.de>, Souptick Joarder <jrdr.linux@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, osalvador@suse.de

Hi Oscar,

There is a simpler way. I will send it out in a bit. No need for your
first function, only  setup_usemap() needs to be changed to __ref.

Pavel
On Tue, Jul 31, 2018 at 10:42 AM Oscar Salvador
<osalvador@techadventures.net> wrote:
>
> On Tue, Jul 31, 2018 at 08:49:11AM -0400, Pavel Tatashin wrote:
> > Hi Oscar,
> >
> > Have you looked into replacing __paginginit via __meminit ? What is
> > the reason to keep both?
> Hi Pavel,
>
> Actually, thinking a bit more about this, it might make sense to remove
> __paginginit altogether and keep only __meminit.
> Looking at the original commit, I think that it was put as a way to abstract it.
>
> After the patchset [1] has been applied, only two functions marked as __paginginit
> remain, so it will be less hassle to replace that with __meminit.
>
> I will send a v2 tomorrow to be applied on top of [1].
>
> [1] https://patchwork.kernel.org/patch/10548861/
>
> Thanks
> --
> Oscar Salvador
> SUSE L3
>
