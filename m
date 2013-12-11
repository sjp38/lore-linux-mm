Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f45.google.com (mail-qe0-f45.google.com [209.85.128.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0F3CE6B0031
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 11:38:24 -0500 (EST)
Received: by mail-qe0-f45.google.com with SMTP id 6so5435382qea.4
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 08:38:23 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id p10si7034867qce.40.2013.12.11.08.38.21
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 08:38:22 -0800 (PST)
Date: Wed, 11 Dec 2013 11:38:09 -0500
From: Dave Jones <davej@redhat.com>
Subject: Re: oops in pgtable_trans_huge_withdraw
Message-ID: <20131211163809.GA26342@redhat.com>
References: <20131206210254.GA7962@redhat.com>
 <52A8877A.10209@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52A8877A.10209@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, Sasha Levin <sasha.levin@oracle.com>

On Wed, Dec 11, 2013 at 04:40:42PM +0100, Vlastimil Babka wrote:
 > On 12/06/2013 10:02 PM, Dave Jones wrote:
 > > I've spent a few days enhancing trinity's use of mmap's, trying to make it
 > > reproduce https://lkml.org/lkml/2013/12/4/499
 > 
 > FYI, I managed to reproduce that using trinity today,
 > trinity was from git at commit e8912cc which is from Dec 09 so I guess 
 > your enhancements were already there?

yep, everything I had pending is in HEAD now.

 > kernel was linux-next-20131209
 > I was running trinity -c mmap -c munmap -c mremap -c remap_file_pages -c 
 > mlock -c munlock
 
A shorthand for all those -c's is '-G vm'. (Though there might be a couple
extra syscalls in the list too, madvise, mprotect etc).

 > Now I'm running with Kirill's patch, will post results later.
 
Seemed to fix it for me, I've not reproduced that particular bug since applying it.
Kirill, is that on its way to Linus soon ?

thanks,

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
