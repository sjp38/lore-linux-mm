Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 823BA6B0083
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 17:47:54 -0400 (EDT)
Received: by qgdz107 with SMTP id z107so32129446qgd.3
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 14:47:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i90si19539222qge.83.2015.03.09.14.47.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Mar 2015 14:47:53 -0700 (PDT)
Message-ID: <54FE084A.3060601@redhat.com>
Date: Mon, 09 Mar 2015 16:53:30 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch v3] mm, hugetlb: abort __get_user_pages if current has
 been oom killed
References: <alpine.DEB.2.10.1503081611290.15536@chino.kir.corp.google.com> <20150309043051.GA13380@node.dhcp.inet.fi> <alpine.DEB.2.10.1503090041120.21058@chino.kir.corp.google.com> <xr93r3synzqu.fsf@gthelen.mtv.corp.google.com> <alpine.DEB.2.10.1503091307130.10307@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1503091307130.10307@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Thelen <gthelen@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/09/2015 04:07 PM, David Rientjes wrote:
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

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
