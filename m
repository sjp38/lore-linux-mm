Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2572B6B000A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 08:16:42 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id n21-v6so4164074iob.19
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 05:16:42 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id q25-v6si9346920ith.2.2018.06.28.05.16.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jun 2018 05:16:41 -0700 (PDT)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w5SCFJma158571
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 12:16:40 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2130.oracle.com with ESMTP id 2jum5820gy-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 12:16:40 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w5SCGd6l007637
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 12:16:39 GMT
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w5SCGc4s032565
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 12:16:39 GMT
Received: by mail-ot0-f179.google.com with SMTP id n24-v6so5858729otl.9
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 05:16:16 -0700 (PDT)
MIME-Version: 1.0
References: <20180628062857.29658-1-bhe@redhat.com> <20180628062857.29658-6-bhe@redhat.com>
In-Reply-To: <20180628062857.29658-6-bhe@redhat.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Thu, 28 Jun 2018 08:15:17 -0400
Message-ID: <CAGM2reb1=f6mhfuLSWGo2BSSdpherEsRB9-u87b2Q5eT11tJUg@mail.gmail.com>
Subject: Re: [PATCH v6 5/5] mm/sparse: Remove CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bhe@redhat.com
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, dave.hansen@intel.com, pagupta@redhat.com, osalvador@techadventures.net, Linux Memory Management List <linux-mm@kvack.org>, kirill.shutemov@linux.intel.com

On Thu, Jun 28, 2018 at 2:29 AM Baoquan He <bhe@redhat.com> wrote:
>
> Pavel pointed out that the behaviour of allocating memmap together
> for one node should be defaulted for all ARCH-es. It won't break
> anything because it will drop to the fallback action to allocate
> imemmap for each section at one time if failed on large chunk of
> memory.
>
> So remove CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER and clean up the
> related codes.
>
> Signed-off-by: Baoquan He <bhe@redhat.com>
> Cc: Pavel Tatashin <pasha.tatashin@oracle.com>

Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>
