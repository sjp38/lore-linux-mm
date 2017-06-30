Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6803E2802FE
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 05:55:50 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 62so6358239wmw.13
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 02:55:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 10si9950390wme.0.2017.06.30.02.55.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Jun 2017 02:55:49 -0700 (PDT)
Date: Fri, 30 Jun 2017 11:55:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, memory_hotplug: remove zone restrictions
Message-ID: <20170630095545.GF22917@dhcp22.suse.cz>
References: <20170629073509.623-1-mhocko@kernel.org>
 <20170629073509.623-3-mhocko@kernel.org>
 <CADZGycaXs-TsVN2xy_rpFE_ML5_rs=iYN6ZQZsAfjTVHFyLyEQ@mail.gmail.com>
 <20170630083926.GA22923@dhcp22.suse.cz>
 <CADZGyca1-CzaHoR-==DN4kK_YrwmMVnKvowUv-5M4GQP7ZYubg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADZGyca1-CzaHoR-==DN4kK_YrwmMVnKvowUv-5M4GQP7ZYubg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Xishi Qiu <qiuxishi@huawei.com>, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Fri 30-06-17 17:39:56, Wei Yang wrote:
> On Fri, Jun 30, 2017 at 4:39 PM, Michal Hocko <mhocko@kernel.org> wrote:
[...]
> > yes and to be honest I do not plan to fix it unless somebody has a real
> > life usecase for it. Now that we allow explicit onlininig type anywhere
> > it seems like a reasonable behavior and this will allow us to remove
> > quite some code which is always a good deal wrt longterm maintenance.
> >
> 
> hmm... the statistics displayed in /proc/zoneinfo would be meaningless
> for zone_normal and zone_movable.

Why would they be meaningless? Counters will always reflect the actual
use - if not then it is a bug. And wrt to zone description what is
meaningless about
memory34/valid_zones:Normal
memory35/valid_zones:Normal Movable
memory36/valid_zones:Movable
memory37/valid_zones:Movable Normal
memory38/valid_zones:Movable Normal
memory39/valid_zones:Movable Normal
memory40/valid_zones:Normal
memory41/valid_zones:Movable

And
Node 1, zone   Normal
  pages free     65465
        min      156
        low      221
        high     286
        spanned  229376
        present  65536
        managed  65536
[...]
  start_pfn:           1114112
Node 1, zone  Movable
  pages free     65443
        min      156
        low      221
        high     286
        spanned  196608
        present  65536
        managed  65536
[...]
  start_pfn:           1179648

ranges are clearly defined as [start_pfn, start_pfn+managed] and managed
matches the number of onlined pages (256MB).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
