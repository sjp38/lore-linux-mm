Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 775076B0269
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 15:00:16 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id k22-v6so7724158iob.3
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 12:00:16 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id m186-v6si1376804itd.127.2018.06.29.12.00.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 12:00:15 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w5TIwvaU153594
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 19:00:14 GMT
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp2120.oracle.com with ESMTP id 2jukhsqs3t-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 19:00:14 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w5TJ0CmX019382
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 19:00:13 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w5TJ0COX003527
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 19:00:12 GMT
Received: by mail-oi0-f54.google.com with SMTP id y207-v6so9333328oie.13
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 12:00:12 -0700 (PDT)
MIME-Version: 1.0
References: <20180627013116.12411-1-bhe@redhat.com> <20180627013116.12411-5-bhe@redhat.com>
 <cb67381c-078c-62e6-e4c0-9ecf3de9e84d@intel.com> <CAGM2rebsL_fS8XKRvN34NWiFN3Hh63ZOD8jDj8qeSOUPXcZ2fA@mail.gmail.com>
 <88f16247-aea2-f429-600e-4b54555eb736@intel.com> <b8d5b9cb-ca09-4bcc-0a31-3db1232fe787@oracle.com>
 <7ad120fb-377b-6963-62cb-a1a5eaa6cad4@intel.com>
In-Reply-To: <7ad120fb-377b-6963-62cb-a1a5eaa6cad4@intel.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 29 Jun 2018 14:59:35 -0400
Message-ID: <CAGM2rebmK30_jDyXa60uRC1q1wTAbJkxv3CDaao4JUMOrMTx4A@mail.gmail.com>
Subject: Re: [PATCH v5 4/4] mm/sparse: Optimize memmap allocation during sparse_init()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@intel.com
Cc: bhe@redhat.com, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, pagupta@redhat.com, Linux Memory Management List <linux-mm@kvack.org>, kirill.shutemov@linux.intel.com

> > This is done so nr_consumed_maps does not get out of sync with the
> > current pnum. pnum does not equal to nr_consumed_maps, as there are
> > may be holes in pnums, but there is one-to-one correlation.
> Can this be made more clear in the code?

Absolutely. I've done it here:
http://lkml.kernel.org/r/20180628173010.23849-1-pasha.tatashin@oracle.com

Pavel
