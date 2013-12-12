Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 49C8F6B0031
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 19:24:35 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id ma3so10946912pbc.40
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 16:24:34 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ty3si14963381pbc.17.2013.12.11.16.24.33
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 16:24:33 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20131211163809.GA26342@redhat.com>
References: <20131206210254.GA7962@redhat.com>
 <52A8877A.10209@suse.cz>
 <20131211163809.GA26342@redhat.com>
Subject: Re: oops in pgtable_trans_huge_withdraw
Content-Transfer-Encoding: 7bit
Message-Id: <20131212002422.98262E0090@blue.fi.intel.com>
Date: Thu, 12 Dec 2013 02:24:22 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, akpm@linux-foundation.org
Cc: Vlastimil Babka <vbabka@suse.cz>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, Sasha Levin <sasha.levin@oracle.com>

Dave Jones wrote:
> On Wed, Dec 11, 2013 at 04:40:42PM +0100, Vlastimil Babka wrote:
>  > On 12/06/2013 10:02 PM, Dave Jones wrote:
>  > > I've spent a few days enhancing trinity's use of mmap's, trying to make it
>  > > reproduce https://lkml.org/lkml/2013/12/4/499
>  > 
>  > FYI, I managed to reproduce that using trinity today,
>  > trinity was from git at commit e8912cc which is from Dec 09 so I guess 
>  > your enhancements were already there?
> 
> yep, everything I had pending is in HEAD now.
> 
>  > kernel was linux-next-20131209
>  > I was running trinity -c mmap -c munmap -c mremap -c remap_file_pages -c 
>  > mlock -c munlock
>  
> A shorthand for all those -c's is '-G vm'. (Though there might be a couple
> extra syscalls in the list too, madvise, mprotect etc).
> 
>  > Now I'm running with Kirill's patch, will post results later.
>  
> Seemed to fix it for me, I've not reproduced that particular bug since applying it.
> Kirill, is that on its way to Linus soon ?

It's in -mm tree for a week already.

Andrew, could you push it to Linus? More people steps on the bug.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
