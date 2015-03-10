Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id DBB79900018
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 20:47:13 -0400 (EDT)
Received: by igbhl2 with SMTP id hl2so24382009igb.0
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 17:47:13 -0700 (PDT)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com. [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id b12si924780igv.25.2015.03.09.17.47.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Mar 2015 17:47:13 -0700 (PDT)
Received: by igkb16 with SMTP id b16so26486974igk.1
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 17:47:13 -0700 (PDT)
References: <alpine.DEB.2.10.1503081611290.15536@chino.kir.corp.google.com> <20150309043051.GA13380@node.dhcp.inet.fi> <alpine.DEB.2.10.1503090041120.21058@chino.kir.corp.google.com> <xr93r3synzqu.fsf@gthelen.mtv.corp.google.com> <alpine.DEB.2.10.1503091307130.10307@chino.kir.corp.google.com>
From: Greg Thelen <gthelen@google.com>
Subject: Re: [patch v3] mm, hugetlb: abort __get_user_pages if current has been oom killed
In-reply-to: <alpine.DEB.2.10.1503091307130.10307@chino.kir.corp.google.com>
Date: Mon, 09 Mar 2015 17:47:08 -0700
Message-ID: <xr93pp8hof03.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


On Mon, Mar 09 2015, David Rientjes wrote:

> If __get_user_pages() is faulting a significant number of hugetlb pages,
> usually as the result of mmap(MAP_LOCKED), it can potentially allocate a
> very large amount of memory.
>
> If the process has been oom killed, this will cause a lot of memory to
> potentially deplete memory reserves.
>
> In the same way that commit 4779280d1ea4 ("mm: make get_user_pages() 
> interruptible") aborted for pending SIGKILLs when faulting non-hugetlb
> memory, based on the premise of commit 462e00cc7151 ("oom: stop
> allocating user memory if TIF_MEMDIE is set"), hugetlb page faults now
> terminate when the process has been oom killed.
>
> Cc: Greg Thelen <gthelen@google.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Davidlohr Bueso <dave@stgolabs.net>
> Acked-by: "Kirill A. Shutemov" <kirill@shutemov.name>
> Signed-off-by: David Rientjes <rientjes@google.com>

Looks good.

Acked-by: "Greg Thelen" <gthelen@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
