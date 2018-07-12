Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id CF7926B000C
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 13:45:39 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id e21-v6so1212935itc.5
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 10:45:39 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id 130-v6si3548586itm.89.2018.07.12.10.45.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 10:45:39 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6CHhgdm069650
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 17:45:38 GMT
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp2120.oracle.com with ESMTP id 2k2p7e4tpf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 17:45:37 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w6CHjbwx017592
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 17:45:37 GMT
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w6CHja6C007147
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 17:45:37 GMT
Received: by mail-oi0-f54.google.com with SMTP id q11-v6so31775191oic.12
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 10:45:36 -0700 (PDT)
MIME-Version: 1.0
References: <1531416305.6480.24.camel@abdul.in.ibm.com>
In-Reply-To: <1531416305.6480.24.camel@abdul.in.ibm.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Thu, 12 Jul 2018 13:44:59 -0400
Message-ID: <CAGM2rebtisZda0kqhg0u92fTDxC+=zMNNgKFBLH38osphk0fdA@mail.gmail.com>
Subject: Re: [next-20180711][Oops] linux-next kernel boot is broken on powerpc
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: abdhalee@linux.vnet.ibm.com
Cc: linuxppc-dev@lists.ozlabs.org, linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, mpe@ellerman.id.au, sachinp@linux.vnet.ibm.com, venkatb3@in.ibm.com, manvanth@linux.vnet.ibm.com, sim@linux.vnet.ibm.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, aneesh.kumar@linux.vnet.ibm.com

> Related commit could be one of below ? I see lots of patches related to mm and could not bisect
>
> 5479976fda7d3ab23ba0a4eb4d60b296eb88b866 mm: page_alloc: restore memblock_next_valid_pfn() on arm/arm64
> 41619b27b5696e7e5ef76d9c692dd7342c1ad7eb mm-drop-vm_bug_on-from-__get_free_pages-fix
> 531bbe6bd2721f4b66cdb0f5cf5ac14612fa1419 mm: drop VM_BUG_ON from __get_free_pages
> 479350dd1a35f8bfb2534697e5ca68ee8a6e8dea mm, page_alloc: actually ignore mempolicies for high priority allocations
> 088018f6fe571444caaeb16e84c9f24f22dfc8b0 mm: skip invalid pages block at a time in zero_resv_unresv()

Looks like:
0ba29a108979 mm/sparse: Remove CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER

This patch is going to be reverted from linux-next. Abdul, please
verify that issue is gone once  you revert this patch.

Thank you,
Pavel
