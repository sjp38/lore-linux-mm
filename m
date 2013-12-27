Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f47.google.com (mail-qe0-f47.google.com [209.85.128.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8A58B6B0031
	for <linux-mm@kvack.org>; Fri, 27 Dec 2013 15:14:50 -0500 (EST)
Received: by mail-qe0-f47.google.com with SMTP id t7so9400936qeb.20
        for <linux-mm@kvack.org>; Fri, 27 Dec 2013 12:14:50 -0800 (PST)
Received: from blu0-omc4-s36.blu0.hotmail.com (blu0-omc4-s36.blu0.hotmail.com. [65.55.111.175])
        by mx.google.com with ESMTP id nh12si29682335qeb.42.2013.12.27.12.14.49
        for <linux-mm@kvack.org>;
        Fri, 27 Dec 2013 12:14:49 -0800 (PST)
Message-ID: <BLU0-SMTP67B57AF06A5AC44236538A97CD0@phx.gbl>
From: John David Anglin <dave.anglin@bell.net>
In-Reply-To: <BLU0-SMTP15241D603FEB77037F6D1E97CD0@phx.gbl>
Content-Type: text/plain; charset="US-ASCII"; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0 (Apple Message framework v936)
Subject: Re: [PATCH] remap_file_pages needs to check for cache coherency
Date: Fri, 27 Dec 2013 15:14:39 -0500
References: <20131227180018.GC4945@linux.intel.com> <BLU0-SMTP17D26551261DF285A7E6F497CD0@phx.gbl> <20131227193330.GE4945@linux.intel.com> <BLU0-SMTP15241D603FEB77037F6D1E97CD0@phx.gbl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John David Anglin <dave.anglin@bell.net>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, linux-parisc@vger.kernel.org, linux-mips@linux-mips.org

On 27-Dec-13, at 2:47 PM, John David Anglin wrote:

> It's worth looking at.  The value is supposed to be returned by the  
> PDC_CACHE PDC
> call but I know my rp3440 returns a value of 0 indicating that the  
> aliasing boundary
> is unknown and may be greater than 16MB.

c3750 data cache has an aliasing boundary of 4 MB, so I think we are  
stuck with large
SHMLBA.

Dave
--
John David Anglin	dave.anglin@bell.net



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
