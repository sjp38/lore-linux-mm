Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2EA666B5330
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 16:55:32 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c25-v6so3909811edb.12
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 13:55:32 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w45-v6si1215061edw.39.2018.08.30.13.55.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 13:55:30 -0700 (PDT)
Date: Thu, 30 Aug 2018 22:55:27 +0200
From: Joerg Roedel <jroedel@suse.de>
Subject: Re: 32-bit PTI with THP = userspace corruption
Message-ID: <20180830205527.dmemjwxfbwvkdzk2@suse.de>
References: <alpine.LRH.2.21.1808301639570.15669@math.ut.ee>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.21.1808301639570.15669@math.ut.ee>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Meelis Roos <mroos@linux.ee>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

Hi Meelis,

On Thu, Aug 30, 2018 at 09:09:19PM +0300, Meelis Roos wrote:
> I am seeing userland corruption and application crashes on multiple 
> 32-bit machines with 4.19-rc1+git. The machines vary: PII, PIII, P4. 
> They are all Intel. AMD Duron/Athlon/AthlonMP have been fine in my tests 
> so far (may be configuration dependent).

Thanks for the report! I'll try to reproduce the problem tomorrow and
investigate it. Can you please check if any of the kernel configurations
that show the bug has CONFIG_X86_PAE set? If not, can you please test
if enabling this option still triggers the problem?

Thanks,

	Joerg
