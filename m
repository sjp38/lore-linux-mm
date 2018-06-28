Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id E467B6B0003
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 23:11:20 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id p12-v6so3168723iog.21
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 20:11:20 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id u202-v6si4089030ita.116.2018.06.27.20.11.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 20:11:19 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w5S38h0T120094
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 03:11:19 GMT
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp2120.oracle.com with ESMTP id 2jukhsfq3b-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 03:11:19 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w5S3BIbD009721
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 03:11:18 GMT
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w5S3BHTX016970
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 03:11:18 GMT
Received: by mail-oi0-f52.google.com with SMTP id e8-v6so3820359oii.2
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 20:11:17 -0700 (PDT)
MIME-Version: 1.0
References: <20180627013116.12411-1-bhe@redhat.com> <20180627013116.12411-2-bhe@redhat.com>
In-Reply-To: <20180627013116.12411-2-bhe@redhat.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Wed, 27 Jun 2018 23:10:41 -0400
Message-ID: <CAGM2reYbGaiMA3fPdSFkcr8PegXY8WqdbCrHmC54rHy22mucYw@mail.gmail.com>
Subject: Re: [PATCH v5 1/4] mm/sparse: Add a static variable nr_present_sections
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bhe@redhat.com
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, dave.hansen@intel.com, pagupta@redhat.com, Linux Memory Management List <linux-mm@kvack.org>, kirill.shutemov@linux.intel.com

Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>
On Tue, Jun 26, 2018 at 9:31 PM Baoquan He <bhe@redhat.com> wrote:
>
> It's used to record how many memory sections are marked as present
> during system boot up, and will be used in the later patch.
>
> Signed-off-by: Baoquan He <bhe@redhat.com>
> ---
>  mm/sparse.c | 7 +++++++
>  1 file changed, 7 insertions(+)
>
> diff --git a/mm/sparse.c b/mm/sparse.c
> index f13f2723950a..6314303130b0 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -200,6 +200,12 @@ static inline int next_present_section_nr(int section_nr)
>               (section_nr <= __highest_present_section_nr));    \
>              section_nr = next_present_section_nr(section_nr))
>
> +/*
> + * Record how many memory sections are marked as present
> + * during system bootup.
> + */
> +static int __initdata nr_present_sections;
> +
>  /* Record a memory area against a node. */
>  void __init memory_present(int nid, unsigned long start, unsigned long end)
>  {
> @@ -229,6 +235,7 @@ void __init memory_present(int nid, unsigned long start, unsigned long end)
>                         ms->section_mem_map = sparse_encode_early_nid(nid) |
>                                                         SECTION_IS_ONLINE;
>                         section_mark_present(ms);
> +                       nr_present_sections++;
>                 }
>         }
>  }
> --
> 2.13.6
>
