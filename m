Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 664256B000C
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 10:10:59 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 136-v6so13219842itw.5
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 07:10:59 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id n129-v6si8926494iof.54.2018.07.30.07.10.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 07:10:58 -0700 (PDT)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6UE8pjR181213
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 14:10:57 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2kgh4pvk71-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 14:10:57 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w6UEAtZj009169
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 14:10:55 GMT
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w6UEAtf7015008
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 14:10:55 GMT
Received: by mail-oi0-f50.google.com with SMTP id b15-v6so21442995oib.10
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 07:10:54 -0700 (PDT)
MIME-Version: 1.0
References: <20180730133718.28683-1-osalvador@techadventures.net>
In-Reply-To: <20180730133718.28683-1-osalvador@techadventures.net>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Mon, 30 Jul 2018 10:10:18 -0400
Message-ID: <CAGM2reYo+3ONoLQqD8tQMMKuQ5ZPJf6CjpcahHeMtNQ-B1FuRA@mail.gmail.com>
Subject: Re: [PATCH] mm: Remove zone_id() and make use of zone_idx() in is_dev_zone()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, rientjes@google.com, kemi.wang@intel.com, jia.he@hxt-semitech.com, =?UTF-8?B?UGV0ciBUZXNhxZnDrWs=?= <ptesarik@suse.com>, aryabinin@virtuozzo.com, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, dan.j.williams@intel.com, osalvador@suse.de

On Mon, Jul 30, 2018 at 9:37 AM <osalvador@techadventures.net> wrote:
>
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

Thank you:
Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>
