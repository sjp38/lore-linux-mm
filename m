Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id D13C26B000E
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 09:18:45 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id h26-v6so5766564itj.6
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 06:18:45 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id 78-v6si4220081ioc.252.2018.07.19.06.18.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 06:18:44 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6JDIi6S033611
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 13:18:44 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2120.oracle.com with ESMTP id 2k9yjgq29d-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 13:18:44 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w6JDIhxZ020113
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 13:18:43 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w6JDIgHo018101
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 13:18:42 GMT
Received: by mail-oi0-f44.google.com with SMTP id 13-v6so15499827ois.1
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 06:18:42 -0700 (PDT)
MIME-Version: 1.0
References: <20180718124722.9872-1-osalvador@techadventures.net>
 <20180718124722.9872-2-osalvador@techadventures.net> <20180718141150.imiyuust5txfmfvw@xakep.localdomain>
 <20180719121902.GB8750@techadventures.net>
In-Reply-To: <20180719121902.GB8750@techadventures.net>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Thu, 19 Jul 2018 09:18:06 -0400
Message-ID: <CAGM2reaQkRDYvMsH=nVa=ZZTwAcqEE=omn6ma3=y8N7=UX=65g@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm/page_alloc: Move ifdefery out of free_area_init_core
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, iamjoonsoo.kim@lge.com, aaron.lu@intel.com, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, osalvador@suse.de

 > +             zone_set_nid(nid);
>
> This should be:
>
> zone_set_nid(zone, nid);
>
> I fixed it up in your patch, I hope that is ok.

Yes, thank you. I fixed this when compile tested this patch, but must
have forgotten to regenerate the patch before sending it.

Thank you,
Pavel

>
> Thanks
> --
> Oscar Salvador
> SUSE L3
>
