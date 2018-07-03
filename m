Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id D71D46B02B4
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 23:03:43 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id u23-v6so424286iol.22
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 20:03:43 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id x9-v6si55775jae.78.2018.07.02.20.03.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 20:03:42 -0700 (PDT)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w632xa2l140441
	for <linux-mm@kvack.org>; Tue, 3 Jul 2018 03:03:42 GMT
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2120.oracle.com with ESMTP id 2jx2gpxnde-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 03 Jul 2018 03:03:41 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w6333cXe011951
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 3 Jul 2018 03:03:38 GMT
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w6333bto014619
	for <linux-mm@kvack.org>; Tue, 3 Jul 2018 03:03:38 GMT
Received: by mail-oi0-f41.google.com with SMTP id m2-v6so874168oim.12
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 20:03:37 -0700 (PDT)
MIME-Version: 1.0
References: <1530239363-2356-1-git-send-email-hejianet@gmail.com>
 <1530239363-2356-3-git-send-email-hejianet@gmail.com> <CAGM2reYn3ZbdjhcZze8Zt1eLNSdWghy0KwEXfd5xW+1Ba_SMbw@mail.gmail.com>
 <bfe24a3b-c982-9532-c05b-f42ebb77bbba@gmail.com>
In-Reply-To: <bfe24a3b-c982-9532-c05b-f42ebb77bbba@gmail.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Mon, 2 Jul 2018 23:03:01 -0400
Message-ID: <CAGM2rebfdacH5imNtU+6bEOCGLhgpp=Kc9o9ooJx-os6keNkDw@mail.gmail.com>
Subject: Re: [PATCH v9 2/6] mm: page_alloc: remain memblock_next_valid_pfn()
 on arm/arm64
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: linux@armlinux.org.uk, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, will.deacon@arm.com, mark.rutland@arm.com, hpa@zytor.com, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, neelx@redhat.com, erosca@de.adit-jv.com, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, james.morse@arm.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>, steve.capper@arm.com, tglx@linutronix.de, mingo@redhat.com, gregkh@linuxfoundation.org, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Johannes Weiner <hannes@cmpxchg.org>, kemi.wang@intel.com, =?UTF-8?B?UGV0ciBUZXNhxZnDrWs=?= <ptesarik@suse.com>, yasu.isimatu@gmail.com, aryabinin@virtuozzo.com, nborisov@suse.com, Wei Yang <richard.weiyang@gmail.com>, jia.he@hxt-semitech.com

Can you put it into memblock.c

> Do you think it looks ok if I add the inline prefix?

I would say no, this function is a too complex, and is not in some
critical path to be always inlined.

 I would put it into memblock.c, and have #ifdef
CONFIG_HAVE_MEMBLOCK_PFN_VALID around it.

Thank you,
Pavel
