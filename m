Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9979A6B0007
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 07:56:49 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id x16-v6so9045347qto.20
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 04:56:49 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id t63-v6si8497285qkc.196.2018.06.29.04.56.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 04:56:48 -0700 (PDT)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w5TBn9dB188108
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 11:56:47 GMT
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2120.oracle.com with ESMTP id 2jum0ae43x-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 11:56:47 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w5TBukT4030149
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 11:56:46 GMT
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w5TBujoq007056
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 11:56:46 GMT
Received: by mail-ot0-f179.google.com with SMTP id l15-v6so9634411oth.6
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 04:56:45 -0700 (PDT)
MIME-Version: 1.0
References: <20180628173010.23849-1-pasha.tatashin@oracle.com>
 <20180628173010.23849-2-pasha.tatashin@oracle.com> <20180629100413.GA21540@techadventures.net>
 <20180629104457.GA23043@techadventures.net>
In-Reply-To: <20180629104457.GA23043@techadventures.net>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 29 Jun 2018 07:56:09 -0400
Message-ID: <CAGM2reb=K4D7ZbACvEk1qZBq-dHB9erWxpz3Cmn+Wf+siUFULA@mail.gmail.com>
Subject: Re: [PATCH v1 1/2] mm/sparse: add sparse_init_nid()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org

> Scratch that.
> I forgot that incrementing the pointer will add up the right bytes.

Hi Oscar,

Thank you for looking at this patch. I will correct sprase/sparse
typos in the next revision. But, will wait for more comments before
sending a new version.

Pavel
