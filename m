Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2A6F96B54FB
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 00:12:49 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id h89-v6so2250505lfb.10
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 21:12:49 -0700 (PDT)
Received: from smtp2.it.da.ut.ee (smtp2.it.da.ut.ee. [2001:bb8:2002:500::47])
        by mx.google.com with ESMTP id r103-v6si9415468lfi.99.2018.08.30.21.12.46
        for <linux-mm@kvack.org>;
        Thu, 30 Aug 2018 21:12:47 -0700 (PDT)
Date: Fri, 31 Aug 2018 07:12:44 +0300 (EEST)
From: Meelis Roos <mroos@linux.ee>
Subject: Re: 32-bit PTI with THP = userspace corruption
In-Reply-To: <20180830205527.dmemjwxfbwvkdzk2@suse.de>
Message-ID: <alpine.LRH.2.21.1808310711380.17865@math.ut.ee>
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

Will check, but out of my memery there were 2 G3 HP Proliants that did 
not fit into the pattern (problem did not appear). I have more than 4G 
RAM in those and HIGHMEM_4G there, maybe that's it?

-- 
Meelis Roos (mroos@linux.ee)
