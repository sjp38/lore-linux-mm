Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 0E6FB6B004D
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 08:02:35 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so1918884eek.14
        for <linux-mm@kvack.org>; Mon, 03 Dec 2012 05:02:33 -0800 (PST)
Message-ID: <50BCA2E4.8050600@suse.cz>
Date: Mon, 03 Dec 2012 14:02:28 +0100
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] kernel BUG at mm/huge_memory.c:212!
References: <50B52E17.8020205@suse.cz> <1354287821-5925-1-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1354287821-5925-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>, Bob Liu <lliubbo@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

On 11/30/2012 04:03 PM, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> Hi Jiri,
> 
> Sorry for late answer. It took time to reproduce and debug the issue.
> 
> Could you test two patches below by thread. I expect it to fix both
> issues: put_huge_zero_page() and Bad rss-counter state.

Hi, yes, since applying the patches on the last Thu, it didn't recur.

> Kirill A. Shutemov (2):
>   thp: fix anononymous page accounting in fallback path for COW of HZP
>   thp: avoid race on multiple parallel page faults to the same page
> 
>  mm/huge_memory.c | 30 +++++++++++++++++++++++++-----
>  1 file changed, 25 insertions(+), 5 deletions(-)

thanks,
-- 
js
suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
