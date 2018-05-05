Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id CB7CA6B000C
	for <linux-mm@kvack.org>; Fri,  4 May 2018 22:10:56 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id j33-v6so17276596qtc.18
        for <linux-mm@kvack.org>; Fri, 04 May 2018 19:10:56 -0700 (PDT)
Received: from mail1.bemta8.messagelabs.com (mail1.bemta8.messagelabs.com. [216.82.243.205])
        by mx.google.com with ESMTPS id v57-v6si6054124qtj.154.2018.05.04.19.10.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 May 2018 19:10:55 -0700 (PDT)
From: Huaisheng HS1 Ye <yehs1@lenovo.com>
Subject: RE: [External]  Re: [PATCH 3/3] mm/page_alloc: Fix typo in debug info
 of calculate_node_totalpages
Date: Sat, 5 May 2018 02:10:35 +0000
Message-ID: <HK2PR03MB16841DAC9D4C5D0569676F7692850@HK2PR03MB1684.apcprd03.prod.outlook.com>
References: <1525416729-108201-1-git-send-email-yehs1@lenovo.com>
 <1525416729-108201-4-git-send-email-yehs1@lenovo.com>
 <20180504131854.GQ4535@dhcp22.suse.cz>
In-Reply-To: <20180504131854.GQ4535@dhcp22.suse.cz>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "pasha.tatashin@oracle.com" <pasha.tatashin@oracle.com>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "penguin-kernel@I-love.SAKURA.ne.jp" <penguin-kernel@I-love.SAKURA.ne.jp>, "colyli@suse.de" <colyli@suse.de>, NingTing Cheng <chengnt@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>


> On Fri 04-05-18 14:52:09, Huaisheng Ye wrote:
> > realtotalpages is calculated by taking off absent_pages from
> > spanned_pages in every zone.
> > Debug message of calculate_node_totalpages shall accurately
> > indicate that it is real totalpages to avoid ambiguity.
>=20
> Is the printk actually useful? Why don't we simply remove it? You can
> get the information from /proc/zoneinfo so why to litter the dmesg
> output?

Indeed, we can get the amount of pfns as spanned, present and managed
from /proc/zoneinfo after memory initialization has been finished.

But this printk is a relatively meaningful reference within dmesg log.
Especially for people who doesn't have much experience, or someone
has a plan to modify boundary of zones within free_area_init_*.

Sincerely,
Huaisheng Ye
Linux kernel | Lenovo
>=20
> > Signed-off-by: Huaisheng Ye <yehs1@lenovo.com>
> > ---
> >  mm/page_alloc.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 1b39db4..9d57db2 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -5967,7 +5967,7 @@ static void __meminit
> calculate_node_totalpages(struct pglist_data *pgdat,
> >
> >  	pgdat->node_spanned_pages =3D totalpages;
> >  	pgdat->node_present_pages =3D realtotalpages;
> > -	printk(KERN_DEBUG "On node %d totalpages: %lu\n", pgdat->node_id,
> > +	printk(KERN_DEBUG "On node %d realtotalpages: %lu\n",
> pgdat->node_id,
> >  							realtotalpages);
> >  }
> >
> > --
> > 1.8.3.1
