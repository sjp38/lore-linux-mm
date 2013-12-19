Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0FB776B0031
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 11:00:48 -0500 (EST)
Received: by mail-ig0-f173.google.com with SMTP id uq10so12354387igb.0
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 08:00:47 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id mg9si4383961icc.63.2013.12.19.08.00.45
        for <linux-mm@kvack.org>;
        Thu, 19 Dec 2013 08:00:47 -0800 (PST)
Message-ID: <52B30E48.9070505@redhat.com>
Date: Thu, 19 Dec 2013 10:18:32 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm,numa,THP: initialize hstate for THP page size
References: <20131218170314.1e57bea7@cuia.bos.redhat.com> <20131218140830.924fa0a3bab0d497db5e256c@linux-foundation.org> <52B21FC7.7070905@redhat.com> <20131219102231.GE10855@dhcp22.suse.cz>
In-Reply-To: <20131219102231.GE10855@dhcp22.suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Chao Yang <chayang@redhat.com>, linux-mm@kvack.org, aarcange@redhat.com, mgorman@suse.de, Veaceslav Falico <vfalico@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Michel Lespinasse <walken@google.com>

On 12/19/2013 05:22 AM, Michal Hocko wrote:
> [Adding Dave and Mel]

> copy_huge_page as hugetlb specific thing. It relies on hstate which is
> obviously not existing for THP pages. So why do we use it for thp pages
> in the first place?
> 
> Mel, your "mm: numa: Add THP migration for the NUMA working set scanning
> fault case." has added check for PageTransHuge in migrate_page_copy so
> it uses the shared copy_huge_page now. Dave has already tried to fix it
> by https://lkml.org/lkml/2013/10/28/592 but this one has been dropped
> later with "to-be-updated".
> 
> Dave do you have an alternative for your patch?

Gah, never mind me.  This oops happened on a slightly older tree,
that did not have Dave's patch yet...

Andrew, you can drop the patch. Sorry for the noise.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
