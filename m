Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id l0QMmpL0005669
	for <linux-mm@kvack.org>; Fri, 26 Jan 2007 22:48:51 GMT
Received: from ug-out-1314.google.com (ugeo2.prod.google.com [10.66.166.2])
	by spaceape11.eur.corp.google.com with ESMTP id l0QMkFxs000741
	for <linux-mm@kvack.org>; Fri, 26 Jan 2007 22:48:44 GMT
Received: by ug-out-1314.google.com with SMTP id o2so771261uge
        for <linux-mm@kvack.org>; Fri, 26 Jan 2007 14:48:44 -0800 (PST)
Message-ID: <b040c32a0701261448k122f5cc7q5368b3b16ee1dc1f@mail.gmail.com>
Date: Fri, 26 Jan 2007 14:48:44 -0800
From: "Ken Chen" <kenchen@google.com>
Subject: Re: [PATCH] Don't allow the stack to grow into hugetlb reserved regions
In-Reply-To: <Pine.LNX.4.64.0701262025590.22196@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070125214052.22841.33449.stgit@localhost.localdomain>
	 <Pine.LNX.4.64.0701262025590.22196@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Adam Litke <agl@us.ibm.com>, Andrew Morton <akpm@osdl.org>, William Irwin <wli@holomorphy.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 1/26/07, Hugh Dickins <hugh@veritas.com> wrote:
> Less trivial (and I wonder whether you've come to this from an ia64
> or a powerpc direction): I notice that ia64 has more stringent REGION
> checks in its ia64_do_page_fault, before calling expand_stack or
> expand_upwards.  So on that path, the usual path, I think your
> new check in acct_stack_growth is unnecessary on ia64;

I think you are correct. This appears to affect powerpc only. On ia64,
hugetlb lives in a completely different region and they can never step
into normal stack address space. And for x86, there isn't a thing called
"reserved address space" for hugetlb mapping.

        - Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
