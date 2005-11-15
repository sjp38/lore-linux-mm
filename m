Received: by zproxy.gmail.com with SMTP id n1so1530194nzf
        for <linux-mm@kvack.org>; Tue, 15 Nov 2005 00:34:16 -0800 (PST)
Message-ID: <aec7e5c30511150034t5ff9e362jb3261e2e23479b31@mail.gmail.com>
Date: Tue, 15 Nov 2005 17:34:16 +0900
From: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [PATCH 01/05] NUMA: Generic code
In-Reply-To: <200511110516.37980.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20051110090920.8083.54147.sendpatchset@cherry.local>
	 <20051110090925.8083.45887.sendpatchset@cherry.local>
	 <200511110516.37980.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Magnus Damm <magnus@valinux.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On 11/11/05, Andi Kleen <ak@suse.de> wrote:
> On Thursday 10 November 2005 10:08, Magnus Damm wrote:
> > Generic CONFIG_NUMA_EMU code.
> >
> > This patch adds generic NUMA emulation code to the kernel. The code
> > provides the architectures with functions that calculate the size of
> > emulated nodes, together with configuration stuff such as Kconfig and
> > kernel command line code.
>
> IMHO making it generic and bloated like this is total overkill
> for this simple debugginghack. I think it is better to keep
> it simple and hiden it in a architecture specific dark corners, not expose it
> like this.

My plan with breaking out the NUMA emulation code was to merge my i386
stuff with the x86_64 code, but as you say - it might be overkill.

What do you think about the fact that real NUMA nodes now can be
divided into several smaller nodes?

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
