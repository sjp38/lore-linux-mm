Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id DABAB6B006C
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 16:50:09 -0400 (EDT)
Received: by dakp5 with SMTP id p5so5547123dak.14
        for <linux-mm@kvack.org>; Sun, 10 Jun 2012 13:50:09 -0700 (PDT)
Date: Sun, 10 Jun 2012 13:50:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/buddy: cleanup on should_fail_alloc_page
In-Reply-To: <1339253516-8760-1-git-send-email-shangw@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.00.1206101349160.25986@chino.kir.corp.google.com>
References: <1339253516-8760-1-git-send-email-shangw@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, akpm@linux-foundation.org

On Sat, 9 Jun 2012, Gavin Shan wrote:

> In the core function __alloc_pages_nodemask() of buddy allocator, it's
> possible for the memory allocation to fail. That's probablly caused
> by error injection with expection. In that case, it depends on the
> check of error injection covered by function should_fail(). Currently,
> function should_fail() has "bool" for its return value, so it's reasonable
> to change the return value of function should_fail_alloc_page() into
> "bool" as well.
> 

I think we can remove the first three sentences of this.

> The patch does cleanup on function should_fail_alloc_page() to "bool".
> 
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
