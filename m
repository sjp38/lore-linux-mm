Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E74C4C48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 17:51:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B8B4420663
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 17:51:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8B4420663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48A786B0005; Tue, 25 Jun 2019 13:51:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 414C38E0003; Tue, 25 Jun 2019 13:51:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B58B8E0002; Tue, 25 Jun 2019 13:51:48 -0400 (EDT)
X-Delivered-To: Linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E8BB66B0005
	for <Linux-mm@kvack.org>; Tue, 25 Jun 2019 13:51:47 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id bb9so9615407plb.2
        for <Linux-mm@kvack.org>; Tue, 25 Jun 2019 10:51:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kaLNaUo6tcJf7rplltT6xf4Vw8rz3i4+nICfl8MQX1E=;
        b=p0qFhlj3NxQOFRnEoLPIEJluwij85v2M+c80Rtc0tgpjE+Q8NhJFq8B/SZuwRiaTho
         bzPQbXbFf9x+rAvGvSi4ILh519MFII99xuRpA6hckRCRpeMEODoBAQ2Ylo3lDaIX4+4A
         Mp+pDXvZrTyQysfhqbgxsqFQYYV4Crw8y6NbfClqopq6xgc1k6/hd9sRv+QKrUy4LG9Q
         K5Gp86W1WYC9TtHtseyrUECsbWWoEST5acxNTW8wX/qyp625vKGT0XG1N6UyWkFwmCA0
         zU7ZolWVlyxygjac4Mk5AyOf84BBzxbKs31UiyWsfgzvCZ/pvkhAYidomUk7mKErMnhp
         bVag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXO3O8sGgjBkr+DlLFdw7PUHA44AClW68lEsKR5ceG7SfN9ERRf
	6l05NihXe73ZHxUqBBCeMKt0rbU7c8rYD1VS2oqJS63RGhWGSf40qQ0QDVIbeL/CkWAb2WOEehU
	09GeIUlnhLu8Eql3T3o/C+iRJMxmOF20i1y8QAJ3vokBu70YUWdiDZ7KCJqM6AiGWXQ==
X-Received: by 2002:a17:902:8489:: with SMTP id c9mr25433529plo.327.1561485107607;
        Tue, 25 Jun 2019 10:51:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz0QdYF/KUHClFhsxT1pqo3Fb1lbyx1YmPK3owSYUOYTH2jeYIT5PbkMCqrtSSUHTElPx8g
X-Received: by 2002:a17:902:8489:: with SMTP id c9mr25433463plo.327.1561485106871;
        Tue, 25 Jun 2019 10:51:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561485106; cv=none;
        d=google.com; s=arc-20160816;
        b=sGEpMWe3mERTzWOnTaHA7FcpwOJKciUh2sCZR2vSGZUSRUaZ+t2fFSh79bN0S2VzbI
         Se/qnF0WoO0usT8xwbbt+WGPQQUpCm3cuVYrI9n4hywa/pRW8r5WcRhizpd1FUE81jns
         Ppw4QZgS6wEZ6ru3YoR+idVw9DTAq3k+0h09LJtU2AZI4BJWZcTP1rwK/lbXnp7q8aVQ
         A/Brhv4zgcl+D2EaD6Gzu1lJGw4qKAZ/9XnO2YdXpAMMFmmp2Utd61e0WTeXp7+dcWHH
         LZWYjt6dEc+H/beWn5/dvwNIw0NYPrN0nxYs7MsQlNKzopsUdPHlFpNoFIsNCL5WHoAb
         kd6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=kaLNaUo6tcJf7rplltT6xf4Vw8rz3i4+nICfl8MQX1E=;
        b=lbbYPGFtAUBxuqFTkTZPi7x+/aKOaDISs0sjJ62CAZfw1cG/Ad/T3EaZjK6Srf9ItM
         FQHdw7uXZAhxQSeMzAaCocB+LdDZbWVSY8GgehuH/B5dpEhaMnn1Ce/ZxBFMVub6S0wd
         1o015PuEBAzWcYHIUN2eov0oFcZM7W2xTx+9ZSXYPvgrwyOKql9dJVSy+EtCMgFrasS7
         iY3glrOgqwgwrZNQ8FK/CneZ+5giUps+BN/W70yGAizJMEsGEktQPQjXGF7r4IakTBrY
         e0yRNZK1yRZJPPTHWs7udZoYRo93IG8onv7bAk64OyU8x7B/6KgRj0gt9skhm3SrXZrX
         ahCg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id c12si804799pll.138.2019.06.25.10.51.46
        for <Linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 10:51:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Jun 2019 10:51:46 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,416,1557212400"; 
   d="scan'208";a="313156218"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga004.jf.intel.com with ESMTP; 25 Jun 2019 10:51:44 -0700
Date: Tue, 25 Jun 2019 10:51:45 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: Linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	John Hubbard <jhubbard@nvidia.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Christoph Hellwig <hch@lst.de>, Keith Busch <keith.busch@intel.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Linux-kernel@vger.kernel.org
Subject: Re: [PATCHv3] mm/gup: speed up check_and_migrate_cma_pages() on huge
 page
Message-ID: <20190625175144.GA13219@iweiny-DESK2.sc.intel.com>
References: <1561471999-6688-1-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1561471999-6688-1-git-send-email-kernelfans@gmail.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 25, 2019 at 10:13:19PM +0800, Pingfan Liu wrote:
> Both hugetlb and thp locate on the same migration type of pageblock, since
> they are allocated from a free_list[]. Based on this fact, it is enough to
> check on a single subpage to decide the migration type of the whole huge
> page. By this way, it saves (2M/4K - 1) times loop for pmd_huge on x86,
> similar on other archs.
> 
> Furthermore, when executing isolate_huge_page(), it avoid taking global
> hugetlb_lock many times, and meanless remove/add to the local link list
> cma_page_list.
> 
> Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: Mike Rapoport <rppt@linux.ibm.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Keith Busch <keith.busch@intel.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: Linux-kernel@vger.kernel.org
> ---
> v2 -> v3: fix page order to size convertion
> 
>  mm/gup.c | 19 ++++++++++++-------
>  1 file changed, 12 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index ddde097..03cc1f4 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1342,19 +1342,22 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
>  	LIST_HEAD(cma_page_list);
>  
>  check_again:
> -	for (i = 0; i < nr_pages; i++) {
> +	for (i = 0; i < nr_pages;) {
> +
> +		struct page *head = compound_head(pages[i]);
> +		long step = 1;
> +
> +		if (PageCompound(head))
> +			step = 1 << compound_order(head) - (pages[i] - head);

Check your precedence here.

	step = (1 << compound_order(head)) - (pages[i] - head);

Ira

>  		/*
>  		 * If we get a page from the CMA zone, since we are going to
>  		 * be pinning these entries, we might as well move them out
>  		 * of the CMA zone if possible.
>  		 */
> -		if (is_migrate_cma_page(pages[i])) {
> -
> -			struct page *head = compound_head(pages[i]);
> -
> -			if (PageHuge(head)) {
> +		if (is_migrate_cma_page(head)) {
> +			if (PageHuge(head))
>  				isolate_huge_page(head, &cma_page_list);
> -			} else {
> +			else {
>  				if (!PageLRU(head) && drain_allow) {
>  					lru_add_drain_all();
>  					drain_allow = false;
> @@ -1369,6 +1372,8 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
>  				}
>  			}
>  		}
> +
> +		i += step;
>  	}
>  
>  	if (!list_empty(&cma_page_list)) {
> -- 
> 2.7.5
> 

