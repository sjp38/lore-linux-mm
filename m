Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3153BC00319
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 17:21:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC5BE2083E
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 17:21:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC5BE2083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A0C5E8E0098; Thu, 21 Feb 2019 12:21:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BBA48E0094; Thu, 21 Feb 2019 12:21:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 85D6D8E0098; Thu, 21 Feb 2019 12:21:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 57E238E0094
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 12:21:51 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id s65so5767832qke.16
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 09:21:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=0moq+XKICKm8hsjptuPeSWP5N31hUE6YTU9vK+JWGG8=;
        b=gI515ih6jJ5l5uToc7fwbDmwUqwqb8GXBUyuvCSGlkNVFBRbKpSByK009pDR4OUSw4
         aTLxSHlY8ijLKyyETeROcbU8VlYq2NDZNM1bMNtToZjmM/uBt61wsdT6zn0wMG3VBIFa
         NvMBwDg88F7nvyPF8QUFMTJCgXDNYP8eGxmJIPbAjbaUlG1FhQrqNqZJUvoRep0s57Fh
         cZ1rj47wESndvvliNdy9zNgUfNRE7sNtf1fmBpgl8bTukoK+ElXZqDDGF3XP+Td6VRFY
         vkpFXMzQODhERJI63GQlEjOhRafk8Sa41ZWjo8DCagvhU7PwxB4i9Zbr+B2ciuSMRrYt
         g4Hw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAualPsoq9jM6tRFJDvZQAROh7NGdhnq52B5Fv86SI6ZPiNDrpJd/
	nNELVfCktNFYAtv0LLl7+lmYRz33d8tudujZ2+R7Gdf8prVXEgMoCSI0Qbx3ccXzRrhDJypxPQf
	4OT1tB4nZ5BJoULcZ6MNOguvFyg/uYZjMXGN4XBg6Ij03c6htndik1/zQgzNnF5ZUqg==
X-Received: by 2002:a0c:d791:: with SMTP id z17mr30241034qvi.149.1550769711126;
        Thu, 21 Feb 2019 09:21:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib8NjnbpmuWIWwyo4lzOkOrEz56ofhT44DyKfYMKrOfSrJ2lsirq4HKHfVeAjWdh67bmpVN
X-Received: by 2002:a0c:d791:: with SMTP id z17mr30240987qvi.149.1550769710476;
        Thu, 21 Feb 2019 09:21:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550769710; cv=none;
        d=google.com; s=arc-20160816;
        b=qAJoDJBRJHyW0MBHqfEM2ftBlyfb+ZIBEW6AF0cCiO8+lE5wbKd0iRc+6qVlowUB3A
         hJdcTm++9xMv9lr/lbcTRfE88no6GsOfyrHGA1/+PE/Kf2TzZNMI6Ju7jKfhytxVPQhg
         Xy1b6JWnzN33bXYgQttZPQNRfRmQfcSg4A61Z8ZZUVb//CPj/JxlNuACRssBlV6ZWj2/
         BXJ0JLoL9Lagi5NHe+g5dLRJYmb+wExE7rQ0QdOxNbUZ0B3PuZhwgCbvnxVY69ngYdVr
         63TgIflIBJChLebk7Gif6eR0kVwUSvUmx9d5UUAcsJ4DxMqkATgJl+gQqBTMdE0tMdql
         reXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=0moq+XKICKm8hsjptuPeSWP5N31hUE6YTU9vK+JWGG8=;
        b=lduCt/oAQTkpWlvuIk3qNh6387b8/58wW2p7l8TBGpqzZyjRm/tcncIpftYtx5UGHj
         HEhHn696YzLUo9/1JcLOI7ChX1s/14XCtCzM5yxVMBg+oEBWsz8rU7roXk8740iDIk/a
         cbm+7yz7sE3myI3zWaQcV1DZPr04WCuCM/i9M37I9J8KzFegaK50JJ/zNHKIhgVt1Ml1
         lRXXnxlz1GaySYrmMWqZNKwevf3OxYFqgDMOjSzhfYZFRImX/RB5AI3h1WzVkOBKqPAJ
         FSca4YMv9rTb72mtiaibceVE32CVtijGByNLy+xe58oDYpN5bi6GT6BUyYzorvAIYGCK
         BeQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m21si8561883qtq.125.2019.02.21.09.21.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 09:21:50 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8F853C04BD53;
	Thu, 21 Feb 2019 17:21:49 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A9B035D9D4;
	Thu, 21 Feb 2019 17:21:43 +0000 (UTC)
Date: Thu, 21 Feb 2019 12:21:41 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 09/26] userfaultfd: wp: userfaultfd_pte/huge_pmd_wp()
 helpers
Message-ID: <20190221172141.GI2813@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-10-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190212025632.28946-10-peterx@redhat.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Thu, 21 Feb 2019 17:21:49 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:15AM +0800, Peter Xu wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Implement helpers methods to invoke userfaultfd wp faults more
> selectively: not only when a wp fault triggers on a vma with
> vma->vm_flags VM_UFFD_WP set, but only if the _PAGE_UFFD_WP bit is set
> in the pagetable too.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Peter Xu <peterx@redhat.com>

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  include/linux/userfaultfd_k.h | 27 +++++++++++++++++++++++++++
>  1 file changed, 27 insertions(+)
> 
> diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
> index 38f748e7186e..c6590c58ce28 100644
> --- a/include/linux/userfaultfd_k.h
> +++ b/include/linux/userfaultfd_k.h
> @@ -14,6 +14,8 @@
>  #include <linux/userfaultfd.h> /* linux/include/uapi/linux/userfaultfd.h */
>  
>  #include <linux/fcntl.h>
> +#include <linux/mm.h>
> +#include <asm-generic/pgtable_uffd.h>
>  
>  /*
>   * CAREFUL: Check include/uapi/asm-generic/fcntl.h when defining
> @@ -55,6 +57,18 @@ static inline bool userfaultfd_wp(struct vm_area_struct *vma)
>  	return vma->vm_flags & VM_UFFD_WP;
>  }
>  
> +static inline bool userfaultfd_pte_wp(struct vm_area_struct *vma,
> +				      pte_t pte)
> +{
> +	return userfaultfd_wp(vma) && pte_uffd_wp(pte);
> +}
> +
> +static inline bool userfaultfd_huge_pmd_wp(struct vm_area_struct *vma,
> +					   pmd_t pmd)
> +{
> +	return userfaultfd_wp(vma) && pmd_uffd_wp(pmd);
> +}
> +
>  static inline bool userfaultfd_armed(struct vm_area_struct *vma)
>  {
>  	return vma->vm_flags & (VM_UFFD_MISSING | VM_UFFD_WP);
> @@ -104,6 +118,19 @@ static inline bool userfaultfd_wp(struct vm_area_struct *vma)
>  	return false;
>  }
>  
> +static inline bool userfaultfd_pte_wp(struct vm_area_struct *vma,
> +				      pte_t pte)
> +{
> +	return false;
> +}
> +
> +static inline bool userfaultfd_huge_pmd_wp(struct vm_area_struct *vma,
> +					   pmd_t pmd)
> +{
> +	return false;
> +}
> +
> +
>  static inline bool userfaultfd_armed(struct vm_area_struct *vma)
>  {
>  	return false;
> -- 
> 2.17.1
> 

