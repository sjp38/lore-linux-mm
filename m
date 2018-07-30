Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id EC52D6B000A
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 10:08:03 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d5-v6so2472806edq.3
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 07:08:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f3-v6si579009edf.435.2018.07.30.07.08.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 07:08:02 -0700 (PDT)
Subject: Re: [PATCH] mm: Remove zone_id() and make use of zone_idx() in
 is_dev_zone()
References: <20180730133718.28683-1-osalvador@techadventures.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <48a3c91d-14cd-ec1a-dd9f-952cc5e3d5f7@suse.cz>
Date: Mon, 30 Jul 2018 16:07:59 +0200
MIME-Version: 1.0
In-Reply-To: <20180730133718.28683-1-osalvador@techadventures.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net, akpm@linux-foundation.org
Cc: mhocko@suse.com, sfr@canb.auug.org.au, rientjes@google.com, pasha.tatashin@oracle.com, kemi.wang@intel.com, jia.he@hxt-semitech.com, ptesarik@suse.com, aryabinin@virtuozzo.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, Oscar Salvador <osalvador@suse.de>

On 07/30/2018 03:37 PM, osalvador@techadventures.net wrote:
> From: Oscar Salvador <osalvador@suse.de>
> 
> is_dev_zone() is using zone_id() to check if the zone is ZONE_DEVICE.
> zone_id() looks pretty much the same as zone_idx(), and while the use of
> zone_idx() is quite spread in the kernel, zone_id() is only being
> used by is_dev_zone().
> 
> This patch removes zone_id() and makes is_dev_zone() use zone_idx()
> to check the zone, so we do not have two things with the same
> functionality around.
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>

Agreed.

Acked-by: Vlastimil Babka <vbabka@suse.cz>
