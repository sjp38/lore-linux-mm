Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 67F056B025F
	for <linux-mm@kvack.org>; Sat, 16 Jul 2016 14:48:54 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id r65so304856489qkd.1
        for <linux-mm@kvack.org>; Sat, 16 Jul 2016 11:48:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 30si10301451qtg.21.2016.07.16.11.48.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Jul 2016 11:48:53 -0700 (PDT)
Date: Sat, 16 Jul 2016 14:48:47 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: 4.1.28: memory leak introduced by "mm/swap.c: flush lru pvecs
 on compound page arrival"
In-Reply-To: <BLUPR0501MB208230C3CCB7AC91F4E91B0087340@BLUPR0501MB2082.namprd05.prod.outlook.com>
Message-ID: <alpine.LRH.2.02.1607161448350.26056@file01.intranet.prod.int.rdu2.redhat.com>
References: <83d21ffc-eeb8-40f8-7443-8d8291cd5973@ADLINKtech.com>,<20160716144740.GA29708@bbox> <BLUPR0501MB208230C3CCB7AC91F4E91B0087340@BLUPR0501MB2082.namprd05.prod.outlook.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Rottmann <jens.rottmann@adlinktech.com>
Cc: Minchan Kim <minchan@kernel.org>, Lukasz Odzioba <lukasz.odzioba@intel.com>, Sasha Levin <sasha.levin@oracle.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>



On Sat, 16 Jul 2016, Jens Rottmann wrote:

> Hi Minchan (& all),
> 
> Minchan Kim wrote:
> > [...] found __lru_cache_add has a bug. [...]
> [-]     if (!pagevec_space(pvec) || PageCompound(page))
> [+]     if (!pagevec_add(pvec, page) || PageCompound(page))
> 
> Confirm that did plug the leak, thanks!
> 
> Also I just saw this was known already:
> https://marc.info/?l=linux-kernel&m=146858368215856
> Sorry for not noticing earlier, I did search for "4.1.28 memory leak", but not for "memleak".
> 
> Many thanks,
> Jens

For me it fixed the bug too.

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
