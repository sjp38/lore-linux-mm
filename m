Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id D823D6B026B
	for <linux-mm@kvack.org>; Sun,  1 Jul 2018 23:05:42 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 12-v6so16374678qtq.8
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 20:05:42 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id g17-v6si893115qtb.402.2018.07.01.20.05.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jul 2018 20:05:41 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6234O2T145425
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 03:05:41 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2120.oracle.com with ESMTP id 2jx1tntmmy-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 02 Jul 2018 03:05:41 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w6235eLp032438
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 03:05:40 GMT
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w6235dUw000856
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 03:05:40 GMT
Received: by mail-oi0-f45.google.com with SMTP id s198-v6so9822948oih.11
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 20:05:39 -0700 (PDT)
MIME-Version: 1.0
References: <20180702020417.21281-1-pasha.tatashin@oracle.com>
 <20180702020417.21281-2-pasha.tatashin@oracle.com> <20180702025632.GO3223@MiWiFi-R3L-srv>
In-Reply-To: <20180702025632.GO3223@MiWiFi-R3L-srv>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Sun, 1 Jul 2018 23:05:03 -0400
Message-ID: <CAGM2reZhB_J4WECCDcnTSuFrN1mdCshWhmiXNnZ1=Wuyxxjb7w@mail.gmail.com>
Subject: Re: [PATCH v3 1/2] mm/sparse: add sparse_init_nid()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bhe@redhat.com
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net

> > +     if (!usemap) {
> > +             pr_err("%s: usemap allocation failed", __func__);
>
> Wondering if we can provide more useful information for better debugging
> if failed. E.g here tell on what nid the usemap allocation failed.
>
> > +                                                pnum, nid);
> > +             if (!map) {
> > +                     pr_err("%s: memory map backing failed. Some memory will not be available.",
> > +                            __func__);
> And here tell nid and the memory section nr failed.

Sure, I will wait for more comments, if any, and add more info to the
error messages in the next revision.

Thank you,
Pavel
