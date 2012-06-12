Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 69FC76B005C
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 12:31:54 -0400 (EDT)
Received: by ggm4 with SMTP id 4so4636254ggm.14
        for <linux-mm@kvack.org>; Tue, 12 Jun 2012 09:31:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120612142012.GB20467@suse.de>
References: <1339406250-10169-1-git-send-email-kosaki.motohiro@gmail.com>
 <1339406250-10169-6-git-send-email-kosaki.motohiro@gmail.com> <20120612142012.GB20467@suse.de>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Tue, 12 Jun 2012 12:31:29 -0400
Message-ID: <CAHGf_=omc4g_JHu+mr-HKmoH=juhcXKgPGOKamAOrJCWkbdEMQ@mail.gmail.com>
Subject: Re: [PATCH 5/6] mempolicy: fix a memory corruption by refcount
 imbalance in alloc_pages_vma()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@google.com>, Dave Jones <davej@redhat.com>, Christoph Lameter <cl@linux.com>, stable@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Miao Xie <miaox@cn.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

> Why does dequeue_huge_page_vma() not need to be changed as well? It's
> currently using mpol_cond_put() but if there is a goto retry_cpuset then
> will it have not take an additional reference count and leak?

dequeue_huge_page_vma() also uses get_vma_policy() and mpol_cond_put()
pair. thus we don't need special concern.


> Would it be more straight forward to put the mpol_cond_put() and __mpol_put()
> calls after the "goto retry_cpuset" checks instead?

I hope to keep symmetric. Sane design prevent a lot of unintentional breakage.
Frankly says, now all caller assume the symmetric. It's natural.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
