Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4612DC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 19:17:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F19EB20652
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 19:17:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="eE3BRqKI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F19EB20652
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8685B8E0009; Mon, 25 Feb 2019 14:17:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8164B8E0004; Mon, 25 Feb 2019 14:17:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6DEB48E0009; Mon, 25 Feb 2019 14:17:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 272228E0004
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 14:17:18 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id q21so8440999pfi.17
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 11:17:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=hUkZS3RN5nGm+9djQiBmGffJnFbcZdls1iUZK4YyJo8=;
        b=YfxeDAMij8h0hjxLoLOolQgxqeSBgdpRrfPufZ3vfzgLXoNi6wPYANpZm4vdqtX2gH
         9GgwM9K6hi2AIwhjWX7G2M3wbldY9yDWAjCqWIak3a3zRMPus94roa6zlUZzR+6+R4Lh
         hTMObOO10JTBhC5xb7+IkjElu6nlKps6ygGQ6fOS4kvQ487TcXaMeb4NI4D2oa7zTFL9
         vdyKEwlGkNUy65rFIXePsU+uPnAhAzNoRs+1gbn6barhmploQd+UOCLcUFsWtkemtcgw
         leI+GlTkgYW5o+Q9V6eQ+XfmzGYhHErF/NFd+WanUfZ7/jGTOcl+MYNdONWcQqHUxui2
         PnnQ==
X-Gm-Message-State: AHQUAuZXRtJdDaJufnDseJbU0u29/y6Tma0Y6P6DjLIp7USOGm66Mb4j
	H63oQM6eESDOVo68XGmqJpipMtfx7szzJqv6SqCHSdL0lETKFQI+g9vBXm/A58oIwJDdEL6Q7O+
	WK1uYsyJ3D/0+4H+3k5hHmMUyk5gW+VVO8VjRIQKHDfwMBsXqPG40Lmb4R1yJvAKkQqaOW8akep
	6gu73eVjdtthQJVjDf4/yg+CLkZYn4ij0OhH/XMcPQEf0YKUcNCDUrbNy3P+TBMG0XkMUkU4xyn
	5BwkHEq0BMIQvgxnBKWNj+FZblP1fwFvqNObqXsXKLe6YK8ZJj1CAHmX1lTTmNtHCGuBY/BrhxY
	WmAWeFtXwUzlhYY4P4djRk8Y3i4vitBIkPvqORwe37fCEsc8sLdTnsL1YQHpLCpBzJOYAIWgko9
	+
X-Received: by 2002:a62:3890:: with SMTP id f138mr11793589pfa.148.1551122237799;
        Mon, 25 Feb 2019 11:17:17 -0800 (PST)
X-Received: by 2002:a62:3890:: with SMTP id f138mr11793519pfa.148.1551122236681;
        Mon, 25 Feb 2019 11:17:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551122236; cv=none;
        d=google.com; s=arc-20160816;
        b=Et3/CxQs5pzqxOMJge6/k1VU8NBMgM2xLga8maUrxYR3Tme0qwaqA7j7I5jRxeQgfb
         C6PeKSV8bfJCmYCVNrFVs9m0HoY79Aw4cSuuyUEEbX3BVjLL/Ktnx+wNioa6BNhcATRT
         wRahJR9ni9caxey83yefvAo8tB1CbXsyd9/Iszv+Zw5kdNAKtq5kN4NmBdnxJ1I9/Zp/
         /vAX8FK92mJos8qTN11hg7zqMipi0eJJob87qQyDwwa1aeUWYYpkvWid8MOXbVfeRraK
         MVbmtKS9o9xBTLwLw2xNtHJ7M844uGLVQg4J4RlDhfB0C6WyXaMDRP52fxQU+a25u8nV
         s/Kg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=hUkZS3RN5nGm+9djQiBmGffJnFbcZdls1iUZK4YyJo8=;
        b=CSoJipz7qwjlagkgrb0cXuhmGAnGsYm9yPnc0956Xoeq3P/jyQeAt+qwoKQWOMVv5G
         /pni4xdgocu7f3c70tiwGVUeG/2ptCAr8dMkWHS7xpM59MAhaUd42Y66xcyCEE5kBvcu
         66PjyuneAPTIcaaDAgPyT7s+0/6cRmeyIp0XpIeIypEMnHXxkQePO/sMc0fzK+nHhl7r
         qzPCAnvSFWDP41rWTlxmmLfiPlxfrPxkCameYHK+heCvIP1pJMdqI/dyTGQqoRXCgAZP
         iRWNLHLu7/BiHbTjVJueyiC6bBCguXgDmmW1yLKwmbzzHgLP7o0Hj+C6zHTij61NN7+j
         E8zg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=eE3BRqKI;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i184sor15657216pge.78.2019.02.25.11.17.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 11:17:16 -0800 (PST)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=eE3BRqKI;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=hUkZS3RN5nGm+9djQiBmGffJnFbcZdls1iUZK4YyJo8=;
        b=eE3BRqKI/JwJqMizD82Jl4ElWBMD5woz1Yu6j5SuMPFmYPPUWNOBLjMT7FdYTMDaXL
         tDQq5/NEzuFr/h6zFkrYK9tVmzGkXPrQmRsk+eUbKsz2kmWVyeAJAefuHtB55lfhyZ3x
         TTtsIdEiIiAgmVoAw39No7jdWQF0uAhO8HNys3fQ08xK5948nf0l3SNNq0sEWhDW0shS
         YpoAotlkRoa7XZLU6HrFkNRZvv0KHpYg4tkMm1RuUziMuPVgu8vtLgucOHyPXr4s3plj
         EcbEP0rRaTl/cZwApk/lButnXP9o7n0jRuOvCt7SHRgduIAXCsplvUp0IMitn64R8PC2
         sWKw==
X-Google-Smtp-Source: AHgI3Ia8ne5XrNgg+aplWvFyN0xHFDzMTxc8Xw54IB0TI0soJBIDrNUwyxPUyAOSzqrjAjvzY9WcVQ==
X-Received: by 2002:a63:788a:: with SMTP id t132mr20819792pgc.0.1551122236139;
        Mon, 25 Feb 2019 11:17:16 -0800 (PST)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id i13sm9791483pfo.106.2019.02.25.11.17.14
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 25 Feb 2019 11:17:15 -0800 (PST)
Date: Mon, 25 Feb 2019 11:17:14 -0800 (PST)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Mike Kravetz <mike.kravetz@oracle.com>
cc: Jing Xiangfeng <jingxiangfeng@huawei.com>, mhocko@kernel.org, 
    akpm@linux-foundation.org, hughd@google.com, linux-mm@kvack.org, 
    n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, 
    kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v4] mm/hugetlb: Fix unsigned overflow in
 __nr_hugepages_store_common()
In-Reply-To: <13400ee2-3d3b-e5d6-2d78-a770820417de@oracle.com>
Message-ID: <alpine.DEB.2.21.1902251116180.167839@chino.kir.corp.google.com>
References: <1550885529-125561-1-git-send-email-jingxiangfeng@huawei.com> <388cbbf5-7086-1d04-4c49-049021504b9d@oracle.com> <alpine.DEB.2.21.1902241913000.34632@chino.kir.corp.google.com> <8c167be7-06fa-a8c0-8ee7-0bfad41eaba2@oracle.com>
 <13400ee2-3d3b-e5d6-2d78-a770820417de@oracle.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Feb 2019, Mike Kravetz wrote:

> Ok, what about just moving the calculation/check inside the lock as in the
> untested patch below?
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  mm/hugetlb.c | 34 ++++++++++++++++++++++++++--------
>  1 file changed, 26 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 1c5219193b9e..5afa77dc7bc8 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2274,7 +2274,7 @@ static int adjust_pool_surplus(struct hstate *h,
> nodemask_t *nodes_allowed,
>  }
> 
>  #define persistent_huge_pages(h) (h->nr_huge_pages - h->surplus_huge_pages)
> -static int set_max_huge_pages(struct hstate *h, unsigned long count,
> +static int set_max_huge_pages(struct hstate *h, unsigned long count, int nid,
>  						nodemask_t *nodes_allowed)
>  {
>  	unsigned long min_count, ret;
> @@ -2289,6 +2289,23 @@ static int set_max_huge_pages(struct hstate *h, unsigned
> long count,
>  		goto decrease_pool;
>  	}
> 
> +	spin_lock(&hugetlb_lock);
> +
> +	/*
> +	 * Check for a node specific request.  Adjust global count, but
> +	 * restrict alloc/free to the specified node.
> +	 */
> +	if (nid != NUMA_NO_NODE) {
> +		unsigned long old_count = count;
> +		count += h->nr_huge_pages - h->nr_huge_pages_node[nid];
> +		/*
> +		 * If user specified count causes overflow, set to
> +		 * largest possible value.
> +		 */
> +		if (count < old_count)
> +			count = ULONG_MAX;
> +	}
> +
>  	/*
>  	 * Increase the pool size
>  	 * First take pages out of surplus state.  Then make up the
> @@ -2300,7 +2317,6 @@ static int set_max_huge_pages(struct hstate *h, unsigned
> long count,
>  	 * pool might be one hugepage larger than it needs to be, but
>  	 * within all the constraints specified by the sysctls.
>  	 */
> -	spin_lock(&hugetlb_lock);
>  	while (h->surplus_huge_pages && count > persistent_huge_pages(h)) {
>  		if (!adjust_pool_surplus(h, nodes_allowed, -1))
>  			break;
> @@ -2421,16 +2437,18 @@ static ssize_t __nr_hugepages_store_common(bool
> obey_mempolicy,
>  			nodes_allowed = &node_states[N_MEMORY];
>  		}
>  	} else if (nodes_allowed) {
> +		/* Node specific request */
> +		init_nodemask_of_node(nodes_allowed, nid);
> +	} else {
>  		/*
> -		 * per node hstate attribute: adjust count to global,
> -		 * but restrict alloc/free to the specified node.
> +		 * Node specific request, but we could not allocate
> +		 * node mask.  Pass in ALL nodes, and clear nid.
>  		 */
> -		count += h->nr_huge_pages - h->nr_huge_pages_node[nid];
> -		init_nodemask_of_node(nodes_allowed, nid);
> -	} else
> +		nid = NUMA_NO_NODE;
>  		nodes_allowed = &node_states[N_MEMORY];
> +	}
> 
> -	err = set_max_huge_pages(h, count, nodes_allowed);
> +	err = set_max_huge_pages(h, count, nid, nodes_allowed);
>  	if (err)
>  		goto out;
> 

Looks good; Jing, could you test that this fixes your case?

