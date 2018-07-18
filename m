Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 94CE36B0006
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 10:35:04 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id s63-v6so3733633qkc.7
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 07:35:04 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id n32-v6si3563538qta.356.2018.07.18.07.35.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 07:35:03 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6IEXjOT142602
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 14:35:02 GMT
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp2120.oracle.com with ESMTP id 2k9yjghwtu-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 14:35:02 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w6IEZ1GX001291
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 14:35:01 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w6IEZ1l6021600
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 14:35:01 GMT
Received: by mail-oi0-f46.google.com with SMTP id b15-v6so9164026oib.10
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 07:35:01 -0700 (PDT)
MIME-Version: 1.0
References: <20180718124722.9872-1-osalvador@techadventures.net> <20180718124722.9872-4-osalvador@techadventures.net>
In-Reply-To: <20180718124722.9872-4-osalvador@techadventures.net>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Wed, 18 Jul 2018 10:34:19 -0400
Message-ID: <CAGM2reY8ODmr=u4bsCrdEX3f-c6NkSuKuEcXowRy=SkuMppjiw@mail.gmail.com>
Subject: Re: [PATCH 3/3] mm/page_alloc: Split context in free_area_init_node
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, iamjoonsoo.kim@lge.com, aaron.lu@intel.com, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, osalvador@suse.de

On Wed, Jul 18, 2018 at 8:47 AM <osalvador@techadventures.net> wrote:
>
> From: Oscar Salvador <osalvador@suse.de>
>
> If free_area_init_node gets called from memhotplug code,
> we do not need to call calculate_node_totalpages(),
> as the node has no pages.

I am not positive this is safe. Some pgdat fields in
calculate_node_totalpages() are set. Even if those fields are always
set to zeros, pgdat may be reused (i.e. node went offline and later
came back online), so we might still need to set those fields to
zeroes.

Pavel
