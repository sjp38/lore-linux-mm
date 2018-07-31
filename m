Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 53F7A6B0005
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 12:13:29 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id d14-v6so13323783qtn.12
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 09:13:29 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id 42-v6si5406177qvf.139.2018.07.31.09.13.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jul 2018 09:13:28 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6VG4dQJ174816
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 16:13:27 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2120.oracle.com with ESMTP id 2kggep1t6a-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 16:13:27 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w6VGDP5i003748
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 16:13:26 GMT
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w6VGDPSJ014212
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 16:13:25 GMT
Received: by mail-oi0-f49.google.com with SMTP id v8-v6so28983995oie.5
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 09:13:25 -0700 (PDT)
MIME-Version: 1.0
References: <20180730101757.28058-1-osalvador@techadventures.net>
 <20180730101757.28058-5-osalvador@techadventures.net> <20180731101752.GA473@techadventures.net>
In-Reply-To: <20180731101752.GA473@techadventures.net>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Tue, 31 Jul 2018 12:12:49 -0400
Message-ID: <CAGM2reade9+=5+qoCkmYrtMxDnQzoAi3u0nnHV-K5_iFmnOXmA@mail.gmail.com>
Subject: Re: [PATCH v5 4/4] mm/page_alloc: Introduce free_area_init_core_hotplug
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, dan.j.williams@intel.com, david@redhat.com, osalvador@suse.de

On Tue, Jul 31, 2018 at 6:17 AM Oscar Salvador
<osalvador@techadventures.net> wrote:
>
> On Mon, Jul 30, 2018 at 12:17:57PM +0200, osalvador@techadventures.net wrote:
> > From: Oscar Salvador <osalvador@suse.de>
> ...
> > Also, since free_area_init_core/free_area_init_node will now only get called during early init, let us replace
> > __paginginit with __init, so their code gets freed up.
> >
> > Signed-off-by: Oscar Salvador <osalvador@suse.de>
> > Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>
>
> Andrew, could you please fold the following cleanup into this patch?
> thanks
>
> Pavel, since this has your Reviewed-by, are you ok with the following on top?

Yes, Looks good to me.

Thank you,
Pavel
