Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 608B56B0071
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 18:43:26 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so1692474pbb.14
        for <linux-mm@kvack.org>; Wed, 24 Oct 2012 15:43:25 -0700 (PDT)
Date: Wed, 24 Oct 2012 15:43:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] thp: clean up __collapse_huge_page_isolate
In-Reply-To: <1350975002-5927-1-git-send-email-lliubbo@gmail.com>
Message-ID: <alpine.DEB.2.00.1210241543090.3524@chino.kir.corp.google.com>
References: <1350975002-5927-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, aarcange@redhat.com, hughd@google.com, xiaoguangrong@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org

On Tue, 23 Oct 2012, Bob Liu wrote:

> There are duplicated place using release_pte_pages().
> And release_all_pte_pages() can also be removed.
> 
> v2: mv label out of condition.
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
