From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 01/05] NUMA: Generic code
Date: Fri, 11 Nov 2005 05:16:35 +0100
References: <20051110090920.8083.54147.sendpatchset@cherry.local> <20051110090925.8083.45887.sendpatchset@cherry.local>
In-Reply-To: <20051110090925.8083.45887.sendpatchset@cherry.local>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200511110516.37980.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus@valinux.co.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Thursday 10 November 2005 10:08, Magnus Damm wrote:
> Generic CONFIG_NUMA_EMU code.
>
> This patch adds generic NUMA emulation code to the kernel. The code
> provides the architectures with functions that calculate the size of
> emulated nodes, together with configuration stuff such as Kconfig and
> kernel command line code.

IMHO making it generic and bloated like this is total overkill
for this simple debugginghack. I think it is better to keep 
it simple and hiden it in a architecture specific dark corners, not expose it 
like this.

I think the patch shouldn't be applied.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
