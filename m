Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id D40596B0253
	for <linux-mm@kvack.org>; Sat, 16 Jul 2016 13:30:05 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id w207so239635623oiw.1
        for <linux-mm@kvack.org>; Sat, 16 Jul 2016 10:30:05 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0074.outbound.protection.outlook.com. [104.47.34.74])
        by mx.google.com with ESMTPS id i3si3894036oia.125.2016.07.16.10.30.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 16 Jul 2016 10:30:04 -0700 (PDT)
From: Jens Rottmann <jens.rottmann@adlinktech.com>
Subject: Re: 4.1.28: memory leak introduced by "mm/swap.c: flush lru pvecs on
 compound page arrival"
Date: Sat, 16 Jul 2016 17:29:59 +0000
Message-ID: <BLUPR0501MB208230C3CCB7AC91F4E91B0087340@BLUPR0501MB2082.namprd05.prod.outlook.com>
References: <83d21ffc-eeb8-40f8-7443-8d8291cd5973@ADLINKtech.com>,<20160716144740.GA29708@bbox>
In-Reply-To: <20160716144740.GA29708@bbox>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Lukasz Odzioba <lukasz.odzioba@intel.com>, Sasha Levin <sasha.levin@oracle.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mikulas
 Patocka <mpatocka@redhat.com>

Hi Minchan (& all),

Minchan Kim wrote:
> [...] found __lru_cache_add has a bug. [...]
[-]     if (!pagevec_space(pvec) || PageCompound(page))
[+]     if (!pagevec_add(pvec, page) || PageCompound(page))

Confirm that did plug the leak, thanks!

Also I just saw this was known already:
https://marc.info/?l=3Dlinux-kernel&m=3D146858368215856
Sorry for not noticing earlier, I did search for "4.1.28 memory leak", but =
not for "memleak".

Many thanks,
Jens

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
