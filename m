Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3828D6B0006
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 13:56:14 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id k204-v6so144702ite.1
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 10:56:14 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id r13-v6si1133850ioo.111.2018.07.26.10.56.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 10:56:13 -0700 (PDT)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6QHrjRH054012
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 17:56:12 GMT
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2120.oracle.com with ESMTP id 2kbwfq46c5-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 17:56:12 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w6QHuB97027616
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 17:56:11 GMT
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w6QHuBTX031364
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 17:56:11 GMT
Received: by mail-oi0-f46.google.com with SMTP id n84-v6so4504465oib.9
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 10:56:11 -0700 (PDT)
MIME-Version: 1.0
References: <20180725220144.11531-1-osalvador@techadventures.net>
 <20180725220144.11531-3-osalvador@techadventures.net> <20180726080500.GX28386@dhcp22.suse.cz>
 <20180726081215.GC22028@techadventures.net> <20180726151420.uigttpoclcka6h4h@xakep.localdomain>
 <20180726164304.GP28386@dhcp22.suse.cz> <CAGM2reatUAekg=e9FQM1-UVLOSBKb74-FYo7FcPqO_WaR7AmOQ@mail.gmail.com>
 <20180726175212.GQ28386@dhcp22.suse.cz>
In-Reply-To: <20180726175212.GQ28386@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Thu, 26 Jul 2018 13:55:34 -0400
Message-ID: <CAGM2reY2HAo3UDzw=P8ue0jJmRRZou-osyJwWjXt6vtC+CF8Ug@mail.gmail.com>
Subject: Re: [PATCH v3 2/5] mm: access zone->node via zone_to_nid() and zone_set_nid()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: osalvador@techadventures.net, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, dan.j.williams@intel.com, osalvador@suse.de

On Thu, Jul 26, 2018 at 1:52 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 26-07-18 13:18:46, Pavel Tatashin wrote:
> > > > OpenGrok was used to find places where zone->node is accessed. A public one
> > > > is available here: http://src.illumos.org/source/
> > >
> > > I assume that tool uses some pattern matching or similar so steps to use
> > > the tool to get your results would be more helpful. This is basically
> > > the same thing as coccinelle generated patches.
> >
> > OpenGrok is very easy to use, it is source browser, similar to cscope
> > except obviously you can't edit the browsed code. I could have used
> > cscope just as well here.
>
> OK, then I misunderstood. I thought it was some kind of c aware grep
> that found all the usage for you. If this is cscope like then it is not
> worth mentioning in the changelog.

That's what I thought :) Oscar, will you remove the comment about
opengrok, or should I paste a new patch?

Thank you,
Pavel

> --
> Michal Hocko
> SUSE Labs
>
