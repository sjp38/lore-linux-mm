Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-15.8 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EAACC76191
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 20:17:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4781722BF5
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 20:17:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="LK/US9Wb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4781722BF5
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC6C06B0005; Fri, 26 Jul 2019 16:17:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E77628E0003; Fri, 26 Jul 2019 16:17:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D66038E0002; Fri, 26 Jul 2019 16:17:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9E5216B0005
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 16:17:16 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 6so33921175pfi.6
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 13:17:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=j/IRcBqVskGgCakuPtG7Hutcm/XW9ghuXgQa4VWoPlM=;
        b=Y9ynCn8RVjmiTL/oL8glShQRbd+Kc/K+hV2GmhbGxOU+X+2Ywr7ddi/V1MI4tKDSWk
         KnhI9x3/abX65lxuAvAbFYRv90n0BKuIFmLTgt3ec72w7dEK1EtkvGz+0wi3alLzGpwJ
         SFXmxUl4mAMmF0OPwQ8kcWl9lbhSRFXlNl+GJTZdyvVkAXatiUDz9GCisPpd6SQ/M/GN
         +RGNPf8Yep6goneRa7IlCMbWoDRu2LlH2KVbkn/B8B1W/Hn2H85YGbEPO/2wD3YoKw8w
         G8Q+puaxAcrMBS1ZEp2BoVWjV/rHBblKkSNRUk/1HcD8+ZmT1hDG2wovzPqh+ortxEVd
         tsJw==
X-Gm-Message-State: APjAAAVJXI35DZ2GwIk2CL6HN+91Ui2INYGggQ/RfKjEXLfomif15Otf
	BOQlVZewkIKWAvujZtuoEpEXRS7/BGeLuGRj1y/EmMpk3y3NZqXJO77KeK5yG3nVuGUqSWR2FsH
	3umZywsxMS4LoYPJ+r9bwtUItqJ7NC0lfaC+8Phcas6ygAUdLQWiju9eFAc47zP5oZA==
X-Received: by 2002:a63:eb06:: with SMTP id t6mr87622013pgh.107.1564172236164;
        Fri, 26 Jul 2019 13:17:16 -0700 (PDT)
X-Received: by 2002:a63:eb06:: with SMTP id t6mr87621959pgh.107.1564172235399;
        Fri, 26 Jul 2019 13:17:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564172235; cv=none;
        d=google.com; s=arc-20160816;
        b=oNih92xOPqrxwlvO7rpRC+Wccb9BI7hs6lk2euv2jJGaEO89Xe3Xu08OBvm8Sl496f
         Yl/HmBFBy/7a4QqHn7V6ged3a635dnsXSIHKnKO8P9VeOpQRQxYLg4k0OqWXLl0rmztV
         gpBFm+RimoPL4ruFnfkP/4/ymoaemOtuVpZBa6/a81QQ2p1+b0inLJ3xAolr8S//cH7b
         tWxZ51dnou+X9z2BjmAZ7mtyVOYsRiMKPVBwAN+XP/s7g9loMxVD5zLZtaAKYwjHJNbs
         LNd+WFRh91WX8BzFOSfere2Nrd/lWGMCWX+ryIUFfzNZPqMyMQ5dX4+BaI3Bw2kKWdU3
         FLHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=j/IRcBqVskGgCakuPtG7Hutcm/XW9ghuXgQa4VWoPlM=;
        b=Z9HjHDXplN2kcn5HrNXh5sPTHwIUCnZdv7Cw39zIq3svz+7IBhyz6qtgLtrx+Pmcvu
         84FpwORskKCEDo2imJnPEVG2B8e6IJo7y7Es2JiQqU5BJwDFBLfEkn/5jF3ZCZpXuYO/
         W22A9tGNftq8NbOj0AriIy7lRf3gF1eoKNWgvLQ/+f/ssN0GaVCydRUOep4xozVvqxXf
         XDI20N/2USEmXMLnbEaC6PO123Fpc1s7KmMYW9MccoU4P8c/ZwM7nyDI2aTEgYVUS4wB
         +zCllCDCIOJxa2pwKflkWvWWtnd676g6pvO1lDEeXHeHi7e7SM99VRkfGqXknWgiu3gY
         pWLA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="LK/US9Wb";
       spf=pass (google.com: domain of sspatil@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sspatil@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q39sor65358865pjb.7.2019.07.26.13.17.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 13:17:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of sspatil@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="LK/US9Wb";
       spf=pass (google.com: domain of sspatil@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sspatil@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=j/IRcBqVskGgCakuPtG7Hutcm/XW9ghuXgQa4VWoPlM=;
        b=LK/US9WbkyS77sGoAMWZy8gc2tGLtDUIhGi4KMKrm9oXRfVinKUyR1ssB6V7E0lSPF
         t/FBIGuDdkXVBs+1IGdLW0u4vU7EhC8ye6/SumBvlCByTHKDzSPQANwc2+Cz5KG93322
         DxJth4doKg55yaBKLnxxhquhCyOPSzH0DfcrLstq3TIPdIfoqLAhdPV2sW/jW5uOEgZh
         9dNoVlQg4Fd0RgDO2d3e7R3Sc/NQM7WAwGpOyVBMibzfmrm1SxYT0p4MtOVewLloU9/U
         dg8autDLELzhHkbhQ0F+N69b27WnOJG4toZ032w1oSfL/RGxxCMWWcFDcxTzJ3oZGhWY
         RzmQ==
X-Google-Smtp-Source: APXvYqwxUiBPlc83U36uwiE/oXy5nDvLjq7p224Nm5j2u8JgOtNcB6axsTT2TqGR7rpxgANLPkrqZg==
X-Received: by 2002:a17:90a:220a:: with SMTP id c10mr101547847pje.33.1564172234495;
        Fri, 26 Jul 2019 13:17:14 -0700 (PDT)
Received: from sspatil-workstation.mtv.corp.google.com ([2620:15c:211:0:fb21:5c58:d6bc:4bef])
        by smtp.gmail.com with ESMTPSA id s185sm80459064pgs.67.2019.07.26.13.17.11
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 26 Jul 2019 13:17:12 -0700 (PDT)
Date: Fri, 26 Jul 2019 13:17:10 -0700
From: sspatil@google.com
To: joel@joelfernandes.org, linux-kernel@vger.kernel.org, adobriyan@gmail.com,
 akpm@linux-foundation.org, bgregg@netflix.com, chansen3@cisco.com,
 dancol@google.com, fmayer@google.com, joaodias@google.com, joelaf@google.com,
 corbet@lwn.net, keescook@chromium.org, kernel-team@android.com,
 linux-api@vger.kernel.org, linux-doc@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com,
 rppt@linux.ibm.com, minchan@kernel.org, namhyung@google.com, guro@fb.com,
 sfr@canb.auug.org.au, surenb@google.com, tkjos@google.com,
 vdavydov.dev@gmail.com, vbabka@suse.cz, wvw@google.com,
 sspatil+mutt@google.com
Cc: linux-kernel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Brendan Gregg <bgregg@netflix.com>,
 Christian Hansen <chansen3@cisco.com>, dancol@google.com,
 fmayer@google.com, joaodias@google.com, joelaf@google.com,
 Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
 kernel-team@android.com, linux-api@vger.kernel.org,
 linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>,
 Mike Rapoport <rppt@linux.ibm.com>, minchan@kernel.org,
 namhyung@google.com, Roman Gushchin <guro@fb.com>,
 Stephen Rothwell <sfr@canb.auug.org.au>, surenb@google.com,
 tkjos@google.com, Vladimir Davydov <vdavydov.dev@gmail.com>,
 Vlastimil Babka <vbabka@suse.cz>, wvw@google.com
Subject: Re: [PATCH v3 2/2] doc: Update documentation for page_idle virtual
 address indexing
Message-ID: <20190726201710.GA144547@google.com>
References: <20190726152319.134152-1-joel@joelfernandes.org>
 <20190726152319.134152-2-joel@joelfernandes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190726152319.134152-2-joel@joelfernandes.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Thanks Joel, just a couple of nits for the doc inline below. Other than that,

Reviewed-by: Sandeep Patil <sspatil@google.com>

I'll plan on making changes to Android to use this instead of the pagemap +
page_idle. I think it will also be considerably faster.

On Fri, Jul 26, 2019 at 11:23:19AM -0400, Joel Fernandes (Google) wrote:
> This patch updates the documentation with the new page_idle tracking
> feature which uses virtual address indexing.
> 
> Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
> ---
>  .../admin-guide/mm/idle_page_tracking.rst     | 43 ++++++++++++++++---
>  1 file changed, 36 insertions(+), 7 deletions(-)
> 
> diff --git a/Documentation/admin-guide/mm/idle_page_tracking.rst b/Documentation/admin-guide/mm/idle_page_tracking.rst
> index df9394fb39c2..1eeac78c94a7 100644
> --- a/Documentation/admin-guide/mm/idle_page_tracking.rst
> +++ b/Documentation/admin-guide/mm/idle_page_tracking.rst
> @@ -19,10 +19,14 @@ It is enabled by CONFIG_IDLE_PAGE_TRACKING=y.
>  
>  User API
>  ========
> +There are 2 ways to access the idle page tracking API. One uses physical
> +address indexing, another uses a simpler virtual address indexing scheme.
>  
> -The idle page tracking API is located at ``/sys/kernel/mm/page_idle``.
> -Currently, it consists of the only read-write file,
> -``/sys/kernel/mm/page_idle/bitmap``.
> +Physical address indexing
> +-------------------------
> +The idle page tracking API for physical address indexing using page frame
> +numbers (PFN) is located at ``/sys/kernel/mm/page_idle``.  Currently, it
> +consists of the only read-write file, ``/sys/kernel/mm/page_idle/bitmap``.
>  
>  The file implements a bitmap where each bit corresponds to a memory page. The
>  bitmap is represented by an array of 8-byte integers, and the page at PFN #i is
> @@ -74,6 +78,31 @@ See :ref:`Documentation/admin-guide/mm/pagemap.rst <pagemap>` for more
>  information about ``/proc/pid/pagemap``, ``/proc/kpageflags``, and
>  ``/proc/kpagecgroup``.
>  
> +Virtual address indexing
> +------------------------
> +The idle page tracking API for virtual address indexing using virtual page
> +frame numbers (VFN) is located at ``/proc/<pid>/page_idle``. It is a bitmap
> +that follows the same semantics as ``/sys/kernel/mm/page_idle/bitmap``
> +except that it uses virtual instead of physical frame numbers.
> +
> +This idle page tracking API does not need deal with PFN so it does not require

s/need//

> +prior lookups of ``pagemap`` in order to find if page is idle or not. This is

s/in order to find if page is idle or not//

> +an advantage on some systems where looking up PFN is considered a security
> +issue.  Also in some cases, this interface could be slightly more reliable to
> +use than physical address indexing, since in physical address indexing, address
> +space changes can occur between reading the ``pagemap`` and reading the
> +``bitmap``, while in virtual address indexing, the process's ``mmap_sem`` is
> +held for the duration of the access.
> +
> +To estimate the amount of pages that are not used by a workload one should:
> +
> + 1. Mark all the workload's pages as idle by setting corresponding bits in
> +    ``/proc/<pid>/page_idle``.
> +
> + 2. Wait until the workload accesses its working set.
> +
> + 3. Read ``/proc/<pid>/page_idle`` and count the number of bits set.
> +
>  .. _impl_details:
>  
>  Implementation Details
> @@ -99,10 +128,10 @@ When a dirty page is written to swap or disk as a result of memory reclaim or
>  exceeding the dirty memory limit, it is not marked referenced.
>  
>  The idle memory tracking feature adds a new page flag, the Idle flag. This flag
> -is set manually, by writing to ``/sys/kernel/mm/page_idle/bitmap`` (see the
> -:ref:`User API <user_api>`
> -section), and cleared automatically whenever a page is referenced as defined
> -above.
> +is set manually, by writing to ``/sys/kernel/mm/page_idle/bitmap`` for physical
> +addressing or by writing to ``/proc/<pid>/page_idle`` for virtual
> +addressing (see the :ref:`User API <user_api>` section), and cleared
> +automatically whenever a page is referenced as defined above.
>  
>  When a page is marked idle, the Accessed bit must be cleared in all PTEs it is
>  mapped to, otherwise we will not be able to detect accesses to the page coming
> -- 
> 2.22.0.709.g102302147b-goog
> 
> -- 
> To unsubscribe from this group and stop receiving emails from it, send an email to kernel-team+unsubscribe@android.com.
> 

