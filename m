Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8F0056B0003
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 08:37:52 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id d11-v6so13848378iok.21
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 05:37:52 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id b1-v6si12230539jak.136.2018.07.13.05.37.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 05:37:51 -0700 (PDT)
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6DCYKQf047390
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 12:37:50 GMT
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp2130.oracle.com with ESMTP id 2k2p767n92-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 12:37:50 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w6DCbm0I030242
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 12:37:48 GMT
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w6DCbjdZ004104
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 12:37:48 GMT
Received: by mail-oi0-f52.google.com with SMTP id l10-v6so15223241oii.0
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 05:37:45 -0700 (PDT)
MIME-Version: 1.0
References: <20180712203730.8703-1-pasha.tatashin@oracle.com>
 <20180712203730.8703-5-pasha.tatashin@oracle.com> <20180713120340.GA16552@techadventures.net>
In-Reply-To: <20180713120340.GA16552@techadventures.net>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 13 Jul 2018 08:37:09 -0400
Message-ID: <CAGM2reaE8hX=5x9bqp1-8+4Ax7UFTgHACoXiq4QvDc=-H8=0Bw@mail.gmail.com>
Subject: Re: [PATCH v5 4/5] mm/sparse: add new sparse_init_nid() and sparse_init()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, bhe@redhat.com, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

> > Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
>
> Looks good to me, and it will make the code much shorter/easier.
>
> Reviewed-by: Oscar Salvador <osalvador@suse.de>
>

Thank you!

Pave
