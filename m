Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 2BDC7900020
	for <linux-mm@kvack.org>; Tue, 10 Mar 2015 15:26:14 -0400 (EDT)
Received: by wesw62 with SMTP id w62so4123236wes.8
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 12:26:13 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id li5si2039143wjb.191.2015.03.10.12.26.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Mar 2015 12:26:12 -0700 (PDT)
Message-ID: <1426015564.2055.2.camel@stgolabs.net>
Subject: Re: [patch v3] mm, hugetlb: abort __get_user_pages if current has
 been oom killed
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Tue, 10 Mar 2015 12:26:04 -0700
In-Reply-To: <alpine.DEB.2.10.1503091307130.10307@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1503081611290.15536@chino.kir.corp.google.com>
	 <20150309043051.GA13380@node.dhcp.inet.fi>
	 <alpine.DEB.2.10.1503090041120.21058@chino.kir.corp.google.com>
	 <xr93r3synzqu.fsf@gthelen.mtv.corp.google.com>
	 <alpine.DEB.2.10.1503091307130.10307@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill
 A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2015-03-09 at 13:07 -0700, David Rientjes wrote:
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

Makes sense.

Acked-by: Davidlohr Bueso <dave@stgolabs.net>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
