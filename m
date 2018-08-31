Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 602B06B55AF
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 03:10:56 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id j132-v6so2282269lfg.17
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 00:10:56 -0700 (PDT)
Received: from smtp2.it.da.ut.ee (smtp2.it.da.ut.ee. [2001:bb8:2002:500::47])
        by mx.google.com with ESMTP id m9-v6si7148452ljh.94.2018.08.31.00.10.54
        for <linux-mm@kvack.org>;
        Fri, 31 Aug 2018 00:10:54 -0700 (PDT)
Date: Fri, 31 Aug 2018 10:10:52 +0300 (EEST)
From: Meelis Roos <mroos@linux.ee>
Subject: Re: 32-bit PTI with THP = userspace corruption
In-Reply-To: <20180830205527.dmemjwxfbwvkdzk2@suse.de>
Message-ID: <alpine.LRH.2.21.1808311005080.31140@math.ut.ee>
References: <alpine.LRH.2.21.1808301639570.15669@math.ut.ee> <20180830205527.dmemjwxfbwvkdzk2@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <jroedel@suse.de>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

> > I am seeing userland corruption and application crashes on multiple 
> > 32-bit machines with 4.19-rc1+git. The machines vary: PII, PIII, P4. 
> > They are all Intel. AMD Duron/Athlon/AthlonMP have been fine in my tests 
> > so far (may be configuration dependent).
> 
> Thanks for the report! I'll try to reproduce the problem tomorrow and
> investigate it. Can you please check if any of the kernel configurations
> that show the bug has CONFIG_X86_PAE set? If not, can you please test
> if enabling this option still triggers the problem?

PAE was not visible itself, but when I changed HIGHMEM_4G to 
HIGHMEM_64G, X86_PAE was also selected and the resutling kernel works.

Also, I verified that the olid proliants with 6G RAM already have 
HIGHMEM_64G set and they do not exhibit the problem either.

-- 
Meelis Roos (mroos@linux.ee)
