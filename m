Received: by zproxy.gmail.com with SMTP id l8so1782749nzf
        for <linux-mm@kvack.org>; Tue, 15 Nov 2005 21:22:31 -0800 (PST)
Message-ID: <aec7e5c30511152122w70703fbfl98bd377fb6fb9af4@mail.gmail.com>
Date: Wed, 16 Nov 2005 14:22:31 +0900
From: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [PATCH 01/05] NUMA: Generic code
In-Reply-To: <200511151515.05201.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20051110090920.8083.54147.sendpatchset@cherry.local>
	 <200511110516.37980.ak@suse.de>
	 <aec7e5c30511150034t5ff9e362jb3261e2e23479b31@mail.gmail.com>
	 <200511151515.05201.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Magnus Damm <magnus@valinux.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On 11/15/05, Andi Kleen <ak@suse.de> wrote:
> On Tuesday 15 November 2005 09:34, Magnus Damm wrote:
>
> >
> > My plan with breaking out the NUMA emulation code was to merge my i386
> > stuff with the x86_64 code, but as you say - it might be overkill.
> >
> > What do you think about the fact that real NUMA nodes now can be
> > divided into several smaller nodes?
>
> Is it really needed? I never needed it.  Normally numa emulation
> is just for basic numa testing, and for that just an independent
> split is good enough.

For testing, your NUMA emulation code is perfect IMO. But for memory
resource control your NUMA emulation code may be too simple.

With my patch, CONFIG_NUMA_EMU provides a way to partition a machine
into several smaller nodes, regardless if the machine is using NUMA or
not.

This NUMA emulation code together with CPUSETS could be seen as a
simple alternative to the memory resource control provided by CKRM.

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
