Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAFA5C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 06:21:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B71F2173C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 06:21:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="UvtjQlyB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B71F2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F51A8E0003; Tue, 26 Feb 2019 01:21:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A2438E0002; Tue, 26 Feb 2019 01:21:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 191BA8E0003; Tue, 26 Feb 2019 01:21:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id C7F0E8E0002
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 01:21:13 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id e2so9071829pln.12
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 22:21:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=ZC0yZ2p1o7PK0cgDcV+7uVagcrLRoIilQ0DOICYuriA=;
        b=Nfg5UpRum2VSU+ZXQXE3B0dg9f5uBA5jFpddSdqEncc2pmNsWmTn3cKt425NTQAvMI
         FaLBKnq3BNWLLWbVTN4ZMuffS2CqVY/immX2VBehe49fRxFe088QEx750dXqbKVz/wq7
         9/KzMRchz4S08aGN37ziYkmoUwIlhTqdoIWm8BdWJL91KpfYRMmgJr+Ow8mwlezfhSB+
         CZxI7eZSx505QSgY8TVndCYx7qIHvb96CcjwYPVcQvKRsPrKtL3Mn8HZgNcky7PzkytZ
         rFQGNu8myqJSATAR87WfGeV3Nw1xkuMyp0aN/29agwQfSjvhz/AlEzG0LTc2nyFArZrC
         tYEg==
X-Gm-Message-State: AHQUAuZ9tBk6jomTFxGTRA7XIsQ39+F5wQnkx3WIqeaQH6hZGAgK5yfX
	h2EjlDzV1yBcN12s9UViKkh2p65XPRCTQbz4zV2HPwPFJ7lJlh+KRPVyGtWpVXXtwLCSYuCaLre
	FjrK5s/pZY5+eWcngkisQ1zd+mxWuy7oIsvZM+1UJPa0QqpgQkQlinuyDeRBZtouj7jINcmRbXn
	j6lATDR2R2t22g2O34OAjaxcXnB3GuSjYe5VU50Vi5+ursul8gCz6Q5WuFd2uzxkWvQMSvywh4Q
	BBjDOknX0y3kva0u/RXp6hSZ/z08FUZXnpcUhYdzye+nb+EXxYtsSRA+YAploCUwYTU7nXCr8gS
	TNxN4ekXh1Uq8netemAc96FCjaQFkLFuEsSXOKD05V//T/DVEvFAar6KAKd0Xt27yKDmu3x8SgA
	+
X-Received: by 2002:a17:902:112c:: with SMTP id d41mr24600187pla.177.1551162073499;
        Mon, 25 Feb 2019 22:21:13 -0800 (PST)
X-Received: by 2002:a17:902:112c:: with SMTP id d41mr24600131pla.177.1551162072552;
        Mon, 25 Feb 2019 22:21:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551162072; cv=none;
        d=google.com; s=arc-20160816;
        b=DsMwlRZ5pMwCH3y4z2ujcBHvlgkJzG+yuLMcXhehdm9r3qofqpWtqQmxLD2xQ21n96
         B14xRK1dxlnfYCv5KWOgRypJ+lCDouIXawNLE4+WFhmpLXpxYFwTc3G+jzjrEQnVT6cn
         t2Yg+NmfuLRgzIr9trHWMTdVvu2cyy1y/evhJxdKWKnqh2W0NYxjhlbVRExpmXjhIEsZ
         TiuBCxQ9bkWZKP4EvL5ZTQZwo8Z4IN8VHj0Sb8yxjMbKLpj+twut9eYjZxSbis9w0/O7
         2v6BaNJ5Odd4nRbtD4QA39xBE6s/0GezYC1+BYd8F0SzKfBujhTrUhSM+0sY7EqpnuWl
         0ujw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=ZC0yZ2p1o7PK0cgDcV+7uVagcrLRoIilQ0DOICYuriA=;
        b=WE/lMKO+r7bqWWnaqctJ9Kno9zqexyN4EI6b3gO3zCa/pwLe2OGZaWzXA25fIaeI2J
         ZCYj5L4SHsr5Pi1/quOuRBi1mXCwuiUU+ud6MOKa03P27SwL9IFIzfWw89zKhAldAAN3
         Puc8MG5Ysjlq8EnKbPwWxBFNUZiap3uEWX7vdKrTsTVEsXB+BtwGCEpESxAqrBXRYLse
         aFSkWwsg0GvwO/pV/jnNcjzgSc5EYX00042xW45qg6wASRVOtyohHAhCVIGJOHLcntLo
         yQuZt6lvYWjHlpH6GRhqkj0ZB3dmxpQ/0a0qS8+R5Y8KMRK1QpW5YMG7AM/FUKHQnWBn
         SBFg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=UvtjQlyB;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j62sor16680037pgd.27.2019.02.25.22.21.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 22:21:12 -0800 (PST)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=UvtjQlyB;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=ZC0yZ2p1o7PK0cgDcV+7uVagcrLRoIilQ0DOICYuriA=;
        b=UvtjQlyBI8sGvZ+mtUypgYWfiM98aNOpcvsZ8mtinlWzpV/NlGaoXWyn/WjvxAfA59
         zAdDo0sD97UFxswOh43IvwfhYQP7qjifbFevHav7hjl2P87uTmlzYq5IhoAgEkb6VY39
         dCWy6S5SW0aQviJWTfnukBXNmPr4fdfAY7NkghkxKNoRM5jVvvR160FhAglpE2Yv68BF
         fWZ4JdnaGo/0YqSZ580IGTSzTe8ohUF0SBvfMTnRTwNdYoBruo5CtHXbefzYckQ7spAP
         71St2dWIfiR99SCOdKu2K3GtaacTrAC/DefyOE8C8wh3LT86GGN2quiQcug5cJfphyD9
         AxRA==
X-Google-Smtp-Source: AHgI3IZhbJhlwudXVxVukpMgxn+FsTefaDGt47Wq8ZxiVq90yeWCKdR/Yp4JOJS211sGlFN/LNUTrw==
X-Received: by 2002:a63:e206:: with SMTP id q6mr2648856pgh.87.1551162072022;
        Mon, 25 Feb 2019 22:21:12 -0800 (PST)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id b26sm14893340pfo.33.2019.02.25.22.21.10
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 25 Feb 2019 22:21:10 -0800 (PST)
Date: Mon, 25 Feb 2019 22:21:10 -0800 (PST)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Jing Xiangfeng <jingxiangfeng@huawei.com>
cc: Mike Kravetz <mike.kravetz@oracle.com>, mhocko@kernel.org, 
    Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, 
    linux-mm@kvack.org, n-horiguchi@ah.jp.nec.com, 
    Andrea Arcangeli <aarcange@redhat.com>, kirill.shutemov@linux.intel.com, 
    linux-kernel@vger.kernel.org
Subject: Re: [PATCH v4] mm/hugetlb: Fix unsigned overflow in
 __nr_hugepages_store_common()
In-Reply-To: <5C74A2DA.1030304@huawei.com>
Message-ID: <alpine.DEB.2.21.1902252220310.40851@chino.kir.corp.google.com>
References: <1550885529-125561-1-git-send-email-jingxiangfeng@huawei.com> <388cbbf5-7086-1d04-4c49-049021504b9d@oracle.com> <alpine.DEB.2.21.1902241913000.34632@chino.kir.corp.google.com> <8c167be7-06fa-a8c0-8ee7-0bfad41eaba2@oracle.com>
 <13400ee2-3d3b-e5d6-2d78-a770820417de@oracle.com> <alpine.DEB.2.21.1902251116180.167839@chino.kir.corp.google.com> <5C74A2DA.1030304@huawei.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 26 Feb 2019, Jing Xiangfeng wrote:

> On 2019/2/26 3:17, David Rientjes wrote:
> > On Mon, 25 Feb 2019, Mike Kravetz wrote:
> > 
> >> Ok, what about just moving the calculation/check inside the lock as in the
> >> untested patch below?
> >>
> >> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> >> ---
> >>  mm/hugetlb.c | 34 ++++++++++++++++++++++++++--------
> >>  1 file changed, 26 insertions(+), 8 deletions(-)
> >>
> >> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> >> index 1c5219193b9e..5afa77dc7bc8 100644
> >> --- a/mm/hugetlb.c
> >> +++ b/mm/hugetlb.c
> >> @@ -2274,7 +2274,7 @@ static int adjust_pool_surplus(struct hstate *h,
> >> nodemask_t *nodes_allowed,
> >>  }
> >>
> >>  #define persistent_huge_pages(h) (h->nr_huge_pages - h->surplus_huge_pages)
> >> -static int set_max_huge_pages(struct hstate *h, unsigned long count,
> >> +static int set_max_huge_pages(struct hstate *h, unsigned long count, int nid,
> >>  						nodemask_t *nodes_allowed)
> >>  {
> >>  	unsigned long min_count, ret;
> >> @@ -2289,6 +2289,23 @@ static int set_max_huge_pages(struct hstate *h, unsigned
> >> long count,
> >>  		goto decrease_pool;
> >>  	}
> >>
> >> +	spin_lock(&hugetlb_lock);
> >> +
> >> +	/*
> >> +	 * Check for a node specific request.  Adjust global count, but
> >> +	 * restrict alloc/free to the specified node.
> >> +	 */
> >> +	if (nid != NUMA_NO_NODE) {
> >> +		unsigned long old_count = count;
> >> +		count += h->nr_huge_pages - h->nr_huge_pages_node[nid];
> >> +		/*
> >> +		 * If user specified count causes overflow, set to
> >> +		 * largest possible value.
> >> +		 */
> >> +		if (count < old_count)
> >> +			count = ULONG_MAX;
> >> +	}
> >> +
> >>  	/*
> >>  	 * Increase the pool size
> >>  	 * First take pages out of surplus state.  Then make up the
> >> @@ -2300,7 +2317,6 @@ static int set_max_huge_pages(struct hstate *h, unsigned
> >> long count,
> >>  	 * pool might be one hugepage larger than it needs to be, but
> >>  	 * within all the constraints specified by the sysctls.
> >>  	 */
> >> -	spin_lock(&hugetlb_lock);
> >>  	while (h->surplus_huge_pages && count > persistent_huge_pages(h)) {
> >>  		if (!adjust_pool_surplus(h, nodes_allowed, -1))
> >>  			break;
> >> @@ -2421,16 +2437,18 @@ static ssize_t __nr_hugepages_store_common(bool
> >> obey_mempolicy,
> >>  			nodes_allowed = &node_states[N_MEMORY];
> >>  		}
> >>  	} else if (nodes_allowed) {
> >> +		/* Node specific request */
> >> +		init_nodemask_of_node(nodes_allowed, nid);
> >> +	} else {
> >>  		/*
> >> -		 * per node hstate attribute: adjust count to global,
> >> -		 * but restrict alloc/free to the specified node.
> >> +		 * Node specific request, but we could not allocate
> >> +		 * node mask.  Pass in ALL nodes, and clear nid.
> >>  		 */
> >> -		count += h->nr_huge_pages - h->nr_huge_pages_node[nid];
> >> -		init_nodemask_of_node(nodes_allowed, nid);
> >> -	} else
> >> +		nid = NUMA_NO_NODE;
> >>  		nodes_allowed = &node_states[N_MEMORY];
> >> +	}
> >>
> >> -	err = set_max_huge_pages(h, count, nodes_allowed);
> >> +	err = set_max_huge_pages(h, count, nid, nodes_allowed);
> >>  	if (err)
> >>  		goto out;
> >>
> > 
> > Looks good; Jing, could you test that this fixes your case?
> 
> Yes, I have tested this patch, it can also fix my case.

Great!

Reported-by: Jing Xiangfeng <jingxiangfeng@huawei.com>
Tested-by: Jing Xiangfeng <jingxiangfeng@huawei.com>
Acked-by: David Rientjes <rientjes@google.com>

