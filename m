Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 7B3C44403D8
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 10:38:11 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id n128so70016310pfn.3
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 07:38:11 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id tc5si24542780pab.176.2016.02.05.07.38.10
        for <linux-mm@kvack.org>;
        Fri, 05 Feb 2016 07:38:10 -0800 (PST)
Subject: Re: [PATCH RFC 1/1] numa: fix /proc/<pid>/numa_maps for THP
References: <1454686440-31218-1-git-send-email-gerald.schaefer@de.ibm.com>
 <1454686440-31218-2-git-send-email-gerald.schaefer@de.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <56B4C1E1.6060408@intel.com>
Date: Fri, 5 Feb 2016 07:38:09 -0800
MIME-Version: 1.0
In-Reply-To: <1454686440-31218-2-git-send-email-gerald.schaefer@de.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michael Holzheu <holzheu@linux.vnet.ibm.com>

On 02/05/2016 07:34 AM, Gerald Schaefer wrote:
> +static struct page *can_gather_numa_stats_pmd(pmd_t pmd,
> +					      struct vm_area_struct *vma,
> +					      unsigned long addr)
> +{

Is there a way to do this without making a copy of most of
can_gather_numa_stats()?  Seems like the kind of thing where the pmd
version will bitrot.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
