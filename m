Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1B24C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 16:12:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7526820652
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 16:12:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="ZRcrCjA5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7526820652
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 104C76B0003; Thu,  2 May 2019 12:12:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B6666B0006; Thu,  2 May 2019 12:12:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F0EEB6B0007; Thu,  2 May 2019 12:12:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A1ABB6B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 12:12:27 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g36so1310520edg.8
        for <linux-mm@kvack.org>; Thu, 02 May 2019 09:12:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=PmuDEks26u7TosMg6YO9rFojJhi017p7aPym+WIjY/s=;
        b=czvzO9juTKb+9QBpifQihd4FP90jkr1T8faJssA+o3z3SdwWNggY/kEIOp/G+6bzJJ
         EsvYs1W0GGqoSquGuzPC2d0hQFmfFXih6EHnHeLamSdmrr2uWGMgi5IY0n9KNXgizv0l
         ANUcjZzEpLr3+CeagRk7wUPNe8OAk7W0qHybILL61ZBhOcIuYbq0VJ46F2nyuh4+CdS9
         FvxEljGGu00jOKkW/TcGNggGlJFYVx+IRHpzn3gTDBYySi22HHZlHOtnpUUOsb1Sarqb
         Eu4vHRu2C3M76GQb48NyHo/ZaAhZhkcMN9P7AP9S5iofT1okWROaM+/k+lv9oruBdP0m
         z2vw==
X-Gm-Message-State: APjAAAV2DVAHJb0QbeYyyb3SnaCCL8NBz5NqtzG030UQ9OB0hIzpkKLj
	p83lBtSCs8+Vm+IHl3DH3QIa3MGIYXnllYNRXVlRwWYkbUtq554rRc5hvoCuTru7uzBUzsYH88L
	RdvL9MzZL5GJLMg2Uba7VJMzMypwlJh35sjPUG+ylOsiZ73emLKnOZy++ddpVAihfQA==
X-Received: by 2002:a50:a58c:: with SMTP id a12mr3067615edc.213.1556813547228;
        Thu, 02 May 2019 09:12:27 -0700 (PDT)
X-Received: by 2002:a50:a58c:: with SMTP id a12mr3067546edc.213.1556813546090;
        Thu, 02 May 2019 09:12:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556813546; cv=none;
        d=google.com; s=arc-20160816;
        b=rdBC2+CTNkWPwpzfl8ixi6k540GYt6ZP4eaHOX41D+kjFzSuvxMwSSuGJEetkuSPKu
         jd85d097AFJ3lYtefW3YpfCnRB5/QKEsueix7AlO9foahaDUmacdytLod57YsFvdDAyQ
         FRk4uL3gBhth+lwfpbpBWsyWzGpRAYSepsz/kNS/jb/8tozhDsK17w/vnKpq2dvmmc6N
         YeM0nhh//UC5cVNoe7TUnRd0PFlpAPAs9pDz6vcVc3v+feujXH7qQnTFDAzWSZndvB+0
         AYmFwfuu4bBz5iPr4Uv4ItId8GpsAoq6IrmzAwoKs5AsYkqJ9DZrhptXz9mC8pDF/qWm
         6Jvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=PmuDEks26u7TosMg6YO9rFojJhi017p7aPym+WIjY/s=;
        b=TE3x6Rr+zy2qDFO08JCVYyWRpBUzKSFa3vl0uhRy5FcBiDvfI6OQPKc827yGOOck3e
         latBnusrDVvk+T9mYh12EzovAICv9n1xsO6gqhZ/lGxdfHiVXOl+aq4EKwQ5cPqdpCRu
         tpaZSIL/ljAjfKNvO+0IoFVPm5up7DpAD60XLlF1LhZHWt9uTOjEWHClJQC96mih32u8
         yN7o4edu02wIgiTzmiNNk3yJqtZvqgOA1hoYig9AFw5c5zm76/t2YKCavdsEjXlTgW7H
         t+DAvxl5ajWyMiMGdz5i+KB4Zmf6cqYxratJLM3X8jse+y09GSvb3QhpeqjuDw9T9rtn
         6Ibw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=ZRcrCjA5;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 12sor9490063ejy.58.2019.05.02.09.12.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 May 2019 09:12:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=ZRcrCjA5;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=PmuDEks26u7TosMg6YO9rFojJhi017p7aPym+WIjY/s=;
        b=ZRcrCjA5yDrtzuhuaxGA218aPuy8sioowVXNbMz96fmtX1Q3YhAiRGlzgamPi0mAvB
         nixiSO3SdAXaNwXkkyRiwjWAOPYOnlW3ZaGc3IMwRN6X6T0kJBBIeKpYX6/gW3tvhj2v
         tvfJ/mI0Ws/aUUfRVyG59bggwQfeK8Xo8ncypTOvY/rJGjB4xOUAk10lU9CKRYTM6Nss
         qYhP5n+dg2IjGEpOo0V8UzIRXLskytJ1Quc1RDZAozElxiQIMW+tW/Jmc5ffpKQiTnp1
         eTJ5SHTsoZHRFQxKrcXR5/EFeOHgq/xPq8bvxS678Opw86soN2msVgRGObpkLlonfB/7
         eVZg==
X-Google-Smtp-Source: APXvYqwyYTUtFEmJ3Pk1Kxl+N/9cXpVtziHTpF16SYo8jOemVRi2MW8HQ4q0f3So4cyRee2cDlyFYKUmjwTvJxrP1fU=
X-Received: by 2002:a17:906:4988:: with SMTP id p8mr2289364eju.220.1556813545671;
 Thu, 02 May 2019 09:12:25 -0700 (PDT)
MIME-Version: 1.0
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155552635098.2015392.5460028594173939000.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155552635098.2015392.5460028594173939000.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Thu, 2 May 2019 12:12:14 -0400
Message-ID: <CA+CK2bAfnCVYz956jPTNQ+AqHJs7uY1ZqWfL8fSUFWQOdKxHcg@mail.gmail.com>
Subject: Re: [PATCH v6 03/12] mm/sparsemem: Add helpers track active portions
 of a section at boot
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Logan Gunthorpe <logang@deltatee.com>, linux-mm <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, LKML <linux-kernel@vger.kernel.org>, 
	David Hildenbrand <david@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 2:53 PM Dan Williams <dan.j.williams@intel.com> wrote:
>
> Prepare for hot{plug,remove} of sub-ranges of a section by tracking a
> section active bitmask, each bit representing 2MB (SECTION_SIZE (128M) /
> map_active bitmask length (64)). If it turns out that 2MB is too large
> of an active tracking granularity it is trivial to increase the size of
> the map_active bitmap.

Please mention that 2M on Intel, and 16M on Arm64.

>
> The implications of a partially populated section is that pfn_valid()
> needs to go beyond a valid_section() check and read the sub-section
> active ranges from the bitmask.
>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  include/linux/mmzone.h |   29 ++++++++++++++++++++++++++++-
>  mm/page_alloc.c        |    4 +++-
>  mm/sparse.c            |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 79 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 6726fc175b51..cffde898e345 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -1175,6 +1175,8 @@ struct mem_section_usage {
>         unsigned long pageblock_flags[0];
>  };
>
> +void section_active_init(unsigned long pfn, unsigned long nr_pages);
> +
>  struct page;
>  struct page_ext;
>  struct mem_section {
> @@ -1312,12 +1314,36 @@ static inline struct mem_section *__pfn_to_section(unsigned long pfn)
>
>  extern int __highest_present_section_nr;
>
> +static inline int section_active_index(phys_addr_t phys)
> +{
> +       return (phys & ~(PA_SECTION_MASK)) / SECTION_ACTIVE_SIZE;

How about also defining SECTION_ACTIVE_SHIFT like this:

/* BITS_PER_LONG = 2^6 */
#define BITS_PER_LONG_SHIFT 6
#define SECTION_ACTIVE_SHIFT (SECTION_SIZE_BITS - BITS_PER_LONG_SHIFT)
#define SECTION_ACTIVE_SIZE (1 << SECTION_ACTIVE_SHIFT)

The return above would become:
return (phys & ~(PA_SECTION_MASK)) >> SECTION_ACTIVE_SHIFT;

> +}
> +
> +#ifdef CONFIG_SPARSEMEM_VMEMMAP
> +static inline int pfn_section_valid(struct mem_section *ms, unsigned long pfn)
> +{
> +       int idx = section_active_index(PFN_PHYS(pfn));
> +
> +       return !!(ms->usage->map_active & (1UL << idx));
> +}
> +#else
> +static inline int pfn_section_valid(struct mem_section *ms, unsigned long pfn)
> +{
> +       return 1;
> +}
> +#endif
> +
>  #ifndef CONFIG_HAVE_ARCH_PFN_VALID
>  static inline int pfn_valid(unsigned long pfn)
>  {
> +       struct mem_section *ms;
> +
>         if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
>                 return 0;
> -       return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
> +       ms = __nr_to_section(pfn_to_section_nr(pfn));
> +       if (!valid_section(ms))
> +               return 0;
> +       return pfn_section_valid(ms, pfn);
>  }
>  #endif
>
> @@ -1349,6 +1375,7 @@ void sparse_init(void);
>  #define sparse_init()  do {} while (0)
>  #define sparse_index_init(_sec, _nid)  do {} while (0)
>  #define pfn_present pfn_valid
> +#define section_active_init(_pfn, _nr_pages) do {} while (0)
>  #endif /* CONFIG_SPARSEMEM */
>
>  /*
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f671401a7c0b..c9ad28a78018 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7273,10 +7273,12 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
>
>         /* Print out the early node map */
>         pr_info("Early memory node ranges\n");
> -       for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid)
> +       for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid) {
>                 pr_info("  node %3d: [mem %#018Lx-%#018Lx]\n", nid,
>                         (u64)start_pfn << PAGE_SHIFT,
>                         ((u64)end_pfn << PAGE_SHIFT) - 1);
> +               section_active_init(start_pfn, end_pfn - start_pfn);
> +       }
>
>         /* Initialise every node */
>         mminit_verify_pageflags_layout();
> diff --git a/mm/sparse.c b/mm/sparse.c
> index f87de7ad32c8..5ef2f884c4e1 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -210,6 +210,54 @@ static inline unsigned long first_present_section_nr(void)
>         return next_present_section_nr(-1);
>  }
>
> +static unsigned long section_active_mask(unsigned long pfn,
> +               unsigned long nr_pages)
> +{
> +       int idx_start, idx_size;
> +       phys_addr_t start, size;
> +
> +       if (!nr_pages)
> +               return 0;
> +
> +       start = PFN_PHYS(pfn);
> +       size = PFN_PHYS(min(nr_pages, PAGES_PER_SECTION
> +                               - (pfn & ~PAGE_SECTION_MASK)));
> +       size = ALIGN(size, SECTION_ACTIVE_SIZE);
> +
> +       idx_start = section_active_index(start);
> +       idx_size = section_active_index(size);
> +
> +       if (idx_size == 0)
> +               return -1;
> +       return ((1UL << idx_size) - 1) << idx_start;
> +}
> +
> +void section_active_init(unsigned long pfn, unsigned long nr_pages)
> +{
> +       int end_sec = pfn_to_section_nr(pfn + nr_pages - 1);
> +       int i, start_sec = pfn_to_section_nr(pfn);
> +
> +       if (!nr_pages)
> +               return;
> +
> +       for (i = start_sec; i <= end_sec; i++) {
> +               struct mem_section *ms;
> +               unsigned long mask;
> +               unsigned long pfns;
> +
> +               pfns = min(nr_pages, PAGES_PER_SECTION
> +                               - (pfn & ~PAGE_SECTION_MASK));
> +               mask = section_active_mask(pfn, pfns);
> +
> +               ms = __nr_to_section(i);
> +               pr_debug("%s: sec: %d mask: %#018lx\n", __func__, i, mask);
> +               ms->usage->map_active = mask;
> +
> +               pfn += pfns;
> +               nr_pages -= pfns;
> +       }
> +}

For some reasons the above code is confusing to me. It seems all the
code supposed to do is set all map_active to -1, and trim the first
and last sections (can be the same section of course). So, I would
replace the above two functions with one function like this:

void section_active_init(unsigned long pfn, unsigned long nr_pages)
{
        int end_sec = pfn_to_section_nr(pfn + nr_pages - 1);
        int i, idx, start_sec = pfn_to_section_nr(pfn);
        struct mem_section *ms;

        if (!nr_pages)
                return;

        for (i = start_sec; i <= end_sec; i++) {
                ms = __nr_to_section(i);
                ms->usage->map_active = ~0ul;
        }

        /* Might need to trim active pfns from the beginning and end */
        idx = section_active_index(PFN_PHYS(pfn));
        ms = __nr_to_section(start_sec);
        ms->usage->map_active &= (~0ul << idx);

        idx = section_active_index(PFN_PHYS(pfn + nr_pages -1));
        ms = __nr_to_section(end_sec);
        ms->usage->map_active &= (~0ul >> (BITS_PER_LONG - idx - 1));
}

