Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id BFE1B6B0010
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 10:44:31 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id u19-v6so14243562qkl.13
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 07:44:31 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id f34-v6si2574134qtb.125.2018.07.31.07.44.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jul 2018 07:44:30 -0700 (PDT)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6VE8xpm040816
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 14:44:29 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2kgh4q19f9-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 14:44:29 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w6VEiSqW016289
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 14:44:28 GMT
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w6VEiSGr018986
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 14:44:28 GMT
Received: by mail-oi0-f52.google.com with SMTP id d189-v6so28376906oib.6
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 07:44:27 -0700 (PDT)
MIME-Version: 1.0
References: <20180731124504.27582-1-osalvador@techadventures.net>
 <CAGM2rebds=A5m1ZB1LtD7oxMzM9gjVQvm-QibHjEENmXViw5eA@mail.gmail.com>
 <20180731144157.GA1499@techadventures.net> <CAGM2reYmwqQDfk7Lx-whqxDnAb41VU=dusJjGrP3zhNyYQQJcg@mail.gmail.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Tue, 31 Jul 2018 10:43:51 -0400
Message-ID: <CAGM2reZa0z9-H+630ojegw6Z8n2KDFY7k+w5mYtTru2=MCUrJQ@mail.gmail.com>
Subject: Re: [PATCH] mm: make __paginginit based on CONFIG_MEMORY_HOTPLUG
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, kirill.shutemov@linux.intel.com, iamjoonsoo.kim@lge.com, Mel Gorman <mgorman@suse.de>, Souptick Joarder <jrdr.linux@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, osalvador@suse.de

On Tue, Jul 31, 2018 at 10:43 AM Pavel Tatashin
<pasha.tatashin@oracle.com> wrote:
>
> Hi Oscar,
>
> There is a simpler way. I will send it out in a bit. No need for your first function, only  setup_usemap() needs to be changed to __ref.

I meant first patch  not function :)

>
> Pavel
> On Tue, Jul 31, 2018 at 10:42 AM Oscar Salvador <osalvador@techadventures.net> wrote:
> >
> > On Tue, Jul 31, 2018 at 08:49:11AM -0400, Pavel Tatashin wrote:
> > > Hi Oscar,
> > >
> > > Have you looked into replacing __paginginit via __meminit ? What is
> > > the reason to keep both?
> > Hi Pavel,
> >
> > Actually, thinking a bit more about this, it might make sense to remove
> > __paginginit altogether and keep only __meminit.
> > Looking at the original commit, I think that it was put as a way to abstract it.
> >
> > After the patchset [1] has been applied, only two functions marked as __paginginit
> > remain, so it will be less hassle to replace that with __meminit.
> >
> > I will send a v2 tomorrow to be applied on top of [1].
> >
> > [1] https://patchwork.kernel.org/patch/10548861/
> >
> > Thanks
> > --
> > Oscar Salvador
> > SUSE L3
> >
