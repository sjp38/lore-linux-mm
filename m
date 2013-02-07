Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 78FAE6B000C
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 20:17:15 -0500 (EST)
Message-ID: <51130088.4010706@oracle.com>
Date: Wed, 06 Feb 2013 20:16:56 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm: use long type for page counts in mm_populate()
 and get_user_pages()
References: <1359591980-29542-1-git-send-email-walken@google.com> <1359591980-29542-2-git-send-email-walken@google.com> <5112F7AF.6010307@oracle.com> <20130206171047.d27b5772.akpm@linux-foundation.org>
In-Reply-To: <20130206171047.d27b5772.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michel Lespinasse <walken@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/06/2013 08:10 PM, Andrew Morton wrote:
> On Wed, 06 Feb 2013 19:39:11 -0500
> Sasha Levin <sasha.levin@oracle.com> wrote:
> 
>> We're now hitting the VM_BUG_ON() which was added in the last hunk of the
>> patch:
> 
> hm, why was that added.
> 
> Michel, I seem to have confused myself over this series.  I saw a
> report this morning which led me to drop
> mm-accelerate-munlock-treatment-of-thp-pages.patch but now I can't find
> that report and I'm wondering if I should have dropped
> mm-accelerate-mm_populate-treatment-of-thp-pages.patch instead.
> 
> Given that and Sasha's new report I think I'll drop
> 
> mm-use-long-type-for-page-counts-in-mm_populate-and-get_user_pages.patch
> mm-use-long-type-for-page-counts-in-mm_populate-and-get_user_pages-fix.patch
> mm-use-long-type-for-page-counts-in-mm_populate-and-get_user_pages-fix-fix.patch
> mm-accelerate-mm_populate-treatment-of-thp-pages.patch
> mm-accelerate-munlock-treatment-of-thp-pages.patch
> 
> and let's start again?

I've sent a report regarding mm-accelerate-munlock-treatment-of-thp-pages.patch
couple of hours ago (https://lkml.org/lkml/2013/2/6/699). Reverting that patch
fixed the issue reported, so I think you've dropped the right one.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
