Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id E99996B0006
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 10:12:01 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id g6-v6so2586506iti.7
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 07:12:01 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id 199-v6si1621976ity.8.2018.07.18.07.12.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 07:12:00 -0700 (PDT)
Date: Wed, 18 Jul 2018 10:11:50 -0400
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: Re: [PATCH 1/3] mm/page_alloc: Move ifdefery out of
 free_area_init_core
Message-ID: <20180718141150.imiyuust5txfmfvw@xakep.localdomain>
References: <20180718124722.9872-1-osalvador@techadventures.net>
 <20180718124722.9872-2-osalvador@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180718124722.9872-2-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, aaron.lu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

On 18-07-18 14:47:20, osalvador@techadventures.net wrote:
> From: Oscar Salvador <osalvador@suse.de>
> 
> Moving the #ifdefs out of the function makes it easier to follow.
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>

Hi Oscar,

Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>

Please include the following patch in your series, to get rid of the last
ifdef in this function.
