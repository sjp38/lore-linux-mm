Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 38CB06B026D
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 11:56:39 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 7-v6so2146595itv.5
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 08:56:39 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id s63-v6si1225665itg.1.2018.06.29.08.56.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 08:56:38 -0700 (PDT)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w5TFrbOG183546
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 15:56:37 GMT
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2120.oracle.com with ESMTP id 2jum0af23y-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 15:56:37 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w5TFuakG024121
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 15:56:36 GMT
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w5TFuZd5025378
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 15:56:36 GMT
Received: by mail-oi0-f50.google.com with SMTP id k81-v6so8877280oib.4
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 08:56:35 -0700 (PDT)
MIME-Version: 1.0
References: <20180628173010.23849-1-pasha.tatashin@oracle.com>
 <20180628173010.23849-3-pasha.tatashin@oracle.com> <20180629144059.GB23545@techadventures.net>
In-Reply-To: <20180629144059.GB23545@techadventures.net>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 29 Jun 2018 11:55:59 -0400
Message-ID: <CAGM2reZV7tG0FEZV94_-6EXxBEwXkZSuoSn93M=8s4VmRNDCPA@mail.gmail.com>
Subject: Re: [PATCH v1 2/2] mm/sparse: start using sparse_init_nid(), and
 remove old code
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, bhe@redhat.com, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org

> besides this first for_each_present_section_nr(), what about writing a static inline
> function that returns next_present_section_nr(-1) ?
>
> Something like:
>
> static inline int first_present_section_nr(void)
> {
>         return next_present_section_nr(-1);
> }

Good idea, will add it, thank you.

Pavel
