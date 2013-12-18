Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id D16556B0031
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 17:08:33 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id md12so251233pbc.19
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 14:08:33 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id fu1si1025153pbc.134.2013.12.18.14.08.31
        for <linux-mm@kvack.org>;
        Wed, 18 Dec 2013 14:08:32 -0800 (PST)
Date: Wed, 18 Dec 2013 14:08:30 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm,numa,THP: initialize hstate for THP page size
Message-Id: <20131218140830.924fa0a3bab0d497db5e256c@linux-foundation.org>
In-Reply-To: <20131218170314.1e57bea7@cuia.bos.redhat.com>
References: <20131218170314.1e57bea7@cuia.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, Chao Yang <chayang@redhat.com>, linux-mm@kvack.org, aarcange@redhat.com, mgorman@suse.de, Veaceslav Falico <vfalico@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Michel Lespinasse <walken@google.com>, Michal Hocko <mhocko@suse.cz>

On Wed, 18 Dec 2013 17:03:14 -0500 Rik van Riel <riel@redhat.com> wrote:

> When hugetlbfs is started with a non-default page size, it is
> possible that no hstate is initialized for the page sized used
> by transparent huge pages.
> 
> This causes copy_huge_page to crash on a null pointer. Make
> sure we always have an hpage initialized for the page sized
> used by THP.
> 

A bit more context is needed here please - so that people can decide
which kernel version(s) need patching.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
