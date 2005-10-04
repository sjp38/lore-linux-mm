Date: Tue, 04 Oct 2005 16:52:16 +0900 (JST)
Message-Id: <20051004.165216.94769788.taka@valinux.co.jp>
Subject: Re: [PATCH 07/07] i386: numa emulation on pc
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20050930073308.10631.24247.sendpatchset@cherry.local>
References: <20050930073232.10631.63786.sendpatchset@cherry.local>
	<20050930073308.10631.24247.sendpatchset@cherry.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: magnus@valinux.co.jp
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

> This patch adds NUMA emulation for i386 on top of the fixes for sparsemem and
> discontigmem. NUMA emulation already exists for x86_64, and this patch adds
> the same feature using the same config option CONFIG_NUMA_EMU. The kernel
> command line option used is also the same as for x86_64.

It seems like you've forgot to bind cpus with emulated nodes as linux for
x86_64 does. I don't think it's your intention.


Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
