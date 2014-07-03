Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f182.google.com (mail-yk0-f182.google.com [209.85.160.182])
	by kanga.kvack.org (Postfix) with ESMTP id 9EAEA6B0035
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 22:05:02 -0400 (EDT)
Received: by mail-yk0-f182.google.com with SMTP id 19so6917080ykq.13
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 19:05:02 -0700 (PDT)
Received: from g6t1525.atlanta.hp.com (g6t1525.atlanta.hp.com. [15.193.200.68])
        by mx.google.com with ESMTPS id y21si27606898yhj.67.2014.07.02.19.05.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 02 Jul 2014 19:05:01 -0700 (PDT)
Message-ID: <1404353082.23839.0.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [patch] mm, hugetlb: generalize writes to nr_hugepages
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Wed, 02 Jul 2014 19:04:42 -0700
In-Reply-To: <alpine.DEB.2.02.1406301655480.27587@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1406301655480.27587@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Luiz Capitulino <lcapitulino@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2014-06-30 at 16:57 -0700, David Rientjes wrote:
> Three different interfaces alter the maximum number of hugepages for an
> hstate:
> 
>  - /proc/sys/vm/nr_hugepages for global number of hugepages of the default
>    hstate,
> 
>  - /sys/kernel/mm/hugepages/hugepages-X/nr_hugepages for global number of
>    hugepages for a specific hstate, and
> 
>  - /sys/kernel/mm/hugepages/hugepages-X/nr_hugepages/mempolicy for number of
>    hugepages for a specific hstate over the set of allowed nodes.
> 
> Generalize the code so that a single function handles all of these writes 
> instead of duplicating the code in two different functions.
> 
> This decreases the number of lines of code, but also reduces the size of
> .text by about half a percent since set_max_huge_pages() can be inlined.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Davidlohr Bueso <davidlohr@hp.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
