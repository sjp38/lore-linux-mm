Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 02B176B000D
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 23:20:02 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id m2-v6so4059898qti.2
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 20:20:01 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id u190-v6si5436294qkf.195.2018.06.27.20.20.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 20:20:01 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w5S3J9qh163141
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 03:20:00 GMT
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp2120.oracle.com with ESMTP id 2jukhsg6td-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 03:20:00 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w5S3Jxm7020307
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 03:19:59 GMT
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w5S3Jxdh018886
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 03:19:59 GMT
Received: by mail-oi0-f41.google.com with SMTP id r16-v6so3326140oie.3
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 20:19:58 -0700 (PDT)
MIME-Version: 1.0
References: <20180627013116.12411-1-bhe@redhat.com> <20180627013116.12411-5-bhe@redhat.com>
In-Reply-To: <20180627013116.12411-5-bhe@redhat.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Wed, 27 Jun 2018 23:19:22 -0400
Message-ID: <CAGM2reaWkmCF_DWY1jETsC=NOPC7TGFq3VX06YrTDLAp+X2+AQ@mail.gmail.com>
Subject: Re: [PATCH v5 4/4] mm/sparse: Optimize memmap allocation during sparse_init()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bhe@redhat.com
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, dave.hansen@intel.com, pagupta@redhat.com, Linux Memory Management List <linux-mm@kvack.org>, kirill.shutemov@linux.intel.com

> Signed-off-by: Baoquan He <bhe@redhat.com>
>
> Signed-off-by: Baoquan He <bhe@redhat.com>

Please remove duplicated signed-off

>                 if (!usemap) {
>                         ms->section_mem_map = 0;
> +                       nr_consumed_maps++;

Currently, we do not set ms->section_mem_map to 0 when fail to
allocate usemap, only when fail to allocate mmap we set
section_mem_map to 0. I think this is an existing bug.

Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>
