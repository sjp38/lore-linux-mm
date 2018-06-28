Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E7C756B0007
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 07:24:12 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id q8-v6so4038265wmc.2
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 04:24:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 65-v6sor311953wma.3.2018.06.28.04.24.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Jun 2018 04:24:11 -0700 (PDT)
Date: Thu, 28 Jun 2018 13:24:09 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v6 1/5] mm/sparse: Add a static variable
 nr_present_sections
Message-ID: <20180628112409.GB12956@techadventures.net>
References: <20180628062857.29658-1-bhe@redhat.com>
 <20180628062857.29658-2-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180628062857.29658-2-bhe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dave.hansen@intel.com, pagupta@redhat.com, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com

On Thu, Jun 28, 2018 at 02:28:53PM +0800, Baoquan He wrote:
> It's used to record how many memory sections are marked as present
> during system boot up, and will be used in the later patch.
> 
> Signed-off-by: Baoquan He <bhe@redhat.com>
> Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

> ---
>  mm/sparse.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index f13f2723950a..6314303130b0 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -200,6 +200,12 @@ static inline int next_present_section_nr(int section_nr)
>  	      (section_nr <= __highest_present_section_nr));	\
>  	     section_nr = next_present_section_nr(section_nr))
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
>  			ms->section_mem_map = sparse_encode_early_nid(nid) |
>  							SECTION_IS_ONLINE;
>  			section_mark_present(ms);
> +			nr_present_sections++;
>  		}
>  	}
>  }
> -- 
> 2.13.6
> 

-- 
Oscar Salvador
SUSE L3
