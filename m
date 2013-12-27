Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6E9056B0031
	for <linux-mm@kvack.org>; Fri, 27 Dec 2013 14:47:52 -0500 (EST)
Received: by mail-qc0-f176.google.com with SMTP id i8so8940756qcq.7
        for <linux-mm@kvack.org>; Fri, 27 Dec 2013 11:47:52 -0800 (PST)
Received: from blu0-omc4-s5.blu0.hotmail.com (blu0-omc4-s5.blu0.hotmail.com. [65.55.111.144])
        by mx.google.com with ESMTP id l2si1610191qaf.38.2013.12.27.11.47.51
        for <linux-mm@kvack.org>;
        Fri, 27 Dec 2013 11:47:51 -0800 (PST)
Message-ID: <BLU0-SMTP15241D603FEB77037F6D1E97CD0@phx.gbl>
From: John David Anglin <dave.anglin@bell.net>
In-Reply-To: <20131227193330.GE4945@linux.intel.com>
Subject: Re: [PATCH] remap_file_pages needs to check for cache coherency
References: <20131227180018.GC4945@linux.intel.com> <BLU0-SMTP17D26551261DF285A7E6F497CD0@phx.gbl> <20131227193330.GE4945@linux.intel.com>
Content-Type: text/plain; charset="US-ASCII"; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0 (Apple Message framework v936)
Date: Fri, 27 Dec 2013 14:47:32 -0500
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: linux-mm@kvack.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, linux-parisc@vger.kernel.org, linux-mips@linux-mips.org

On 27-Dec-13, at 2:33 PM, Matthew Wilcox wrote:

> Have you considered measuring SHMLBA on different CPU models and
> reducing it at boot time?  I know that 4MB is the architectural  
> guarantee
> (actually, I seem to remember that 16MB was the architectural  
> guarantee,
> but jsm found some CPU architects who said it would enver exceed 4MB).
> I bet some CPUs have considerably lower cache coherency limits.


It's worth looking at.  The value is supposed to be returned by the  
PDC_CACHE PDC
call but I know my rp3440 returns a value of 0 indicating that the  
aliasing boundary
is unknown and may be greater than 16MB.

Dave
--
John David Anglin	dave.anglin@bell.net



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
