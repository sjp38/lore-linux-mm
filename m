Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id A1BC96B0031
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 00:00:00 -0500 (EST)
Received: by mail-ob0-f179.google.com with SMTP id wm4so658319obc.24
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 21:00:00 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id ds9si1907811obc.73.2013.12.18.20.59.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 20:59:59 -0800 (PST)
Message-ID: <52B27D48.9030703@oracle.com>
Date: Wed, 18 Dec 2013 23:59:52 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/rmap: fix BUG at rmap_walk
References: <1387424720-22826-1-git-send-email-liwanp@linux.vnet.ibm.com> <CAA_GA1dA0Yohqx9=HRUJWWcbwp==n3uY5auuB-LRMHWtKJ3QBQ@mail.gmail.com> <20131219042902.GA27512@hacker.(null)>
In-Reply-To: <20131219042902.GA27512@hacker.(null)>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Bob Liu <lliubbo@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On 12/18/2013 11:29 PM, Wanpeng Li wrote:
>> PageLocked is not required by page_referenced_anon() and there is not
>> >any assertion before, commit 37f093cdf introduced this extra BUG_ON()
> There are two callsites shrink_active_list and page_check_references()
> of page_referenced(). shrink_active_list and its callee won't lock anonymous
> page, however, page_check_references() is called with anonymous page
> lock held in shrink_page_list. So page_check_references case need
> specail handling.

This explanation seems to be based on current observed behaviour.

I think it would be easier if you could point out the actual code in each
function that requires a page to be locked, once we have that we don't have
to care about what the callers currently do.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
