Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 186556B0006
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 13:23:33 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id y130-v6so3024633qka.1
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 10:23:33 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id x33-v6si835284qtd.174.2018.07.03.10.23.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 10:23:31 -0700 (PDT)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w63HNUNC184987
	for <linux-mm@kvack.org>; Tue, 3 Jul 2018 17:23:30 GMT
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2120.oracle.com with ESMTP id 2jx2gq1fq1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 03 Jul 2018 17:23:30 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w63HNTGr030902
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 3 Jul 2018 17:23:29 GMT
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w63HNSIX016612
	for <linux-mm@kvack.org>; Tue, 3 Jul 2018 17:23:29 GMT
Received: by mail-oi0-f44.google.com with SMTP id m2-v6so5346999oim.12
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 10:23:28 -0700 (PDT)
MIME-Version: 1.0
References: <1530637506-1256-1-git-send-email-rppt@linux.vnet.ibm.com>
In-Reply-To: <1530637506-1256-1-git-send-email-rppt@linux.vnet.ibm.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Tue, 3 Jul 2018 13:22:52 -0400
Message-ID: <CAGM2reZ1RWcUT67cTGcyB6UzUftyMyG7GTfp=XjNo5CN2=c_bg@mail.gmail.com>
Subject: Re: [PATCH] mm/memblock: replace u64 with phys_addr_t where appropriate
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rppt@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, mhocko@kernel.org, willy@infradead.org

On Tue, Jul 3, 2018 at 1:05 PM Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
>
> Most functions in memblock already use phys_addr_t to represent a physical
> address with __memblock_free_late() being an exception.
>
> This patch replaces u64 with phys_addr_t in __memblock_free_late() and
> switches several format strings from %llx to %pa to avoid casting from
> phys_addr_t to u64.
>
> CC: Michal Hocko <mhocko@kernel.org>
> CC: Matthew Wilcox <willy@infradead.org>
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

Looks good.

Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>

One minor thing that I would like to change in memblock.c is the
useage phys_addr_t for size. I understand the reasoning behind this
choice, but could we do something like:

typedef phys_addr_t phys_size_t;
It would be similar to resource_size_t. I just think the code and
function prototypes would look better with proper typing.

Thank you,
Pavel
