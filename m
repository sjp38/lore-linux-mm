Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6C08C6B0032
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 07:24:39 -0400 (EDT)
Received: by wggz12 with SMTP id z12so7936872wgg.0
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 04:24:38 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id n10si34862674wjb.126.2015.03.09.04.24.37
        for <linux-mm@kvack.org>;
        Mon, 09 Mar 2015 04:24:37 -0700 (PDT)
Date: Mon, 9 Mar 2015 13:24:29 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [patch v2] mm, hugetlb: abort __get_user_pages if current has
 been oom killed
Message-ID: <20150309112429.GA14936@node.dhcp.inet.fi>
References: <alpine.DEB.2.10.1503081611290.15536@chino.kir.corp.google.com>
 <20150309043051.GA13380@node.dhcp.inet.fi>
 <alpine.DEB.2.10.1503090041120.21058@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1503090041120.21058@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 09, 2015 at 12:42:15AM -0700, David Rientjes wrote:
> If __get_user_pages() is faulting a significant number of hugetlb pages,
> usually as the result of mmap(MAP_LOCKED), it can potentially allocate a
> very large amount of memory.
> 
> If the process has been oom killed, this will cause a lot of memory to
> be overcharged to its memcg since it has access to memory reserves or
> could potentially deplete all system memory reserves.
> 
> In the same way that commit 4779280d1ea4 ("mm: make get_user_pages() 
> interruptible") aborted for pending SIGKILLs when faulting non-hugetlb
> memory, based on the premise of commit 462e00cc7151 ("oom: stop
> allocating user memory if TIF_MEMDIE is set"), hugetlb page faults now
> terminate when the process has been oom killed.
> 
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Davidlohr Bueso <dave@stgolabs.net>
> Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Kirill A. Shutemo <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
