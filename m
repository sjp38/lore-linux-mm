Date: Tue, 24 Apr 2007 14:04:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] Handle kernelcore= boot parameter in common code to
 avoid boot problem on IA64
Message-Id: <20070424140421.5c1e6457.akpm@linux-foundation.org>
In-Reply-To: <20070424180052.22005.61762.sendpatchset@skynet.skynet.ie>
References: <20070424180032.22005.82088.sendpatchset@skynet.skynet.ie>
	<20070424180052.22005.61762.sendpatchset@skynet.skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, apw@shadowen.org, y-goto@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Tue, 24 Apr 2007 19:00:52 +0100 (IST) Mel Gorman <mel@csn.ul.ie> wrote:

> 
> When "kernelcore" boot option is specified, kernel can't boot up on ia64
> because of an infinite loop.  In addition, the parsing code can be handled
> in an architecture-independent manner.
> 
> This patch patches uses common code to handle the kernelcore= parameter.
> It is only available to architectures that support arch-independent
> zone-sizing (i.e. define CONFIG_ARCH_POPULATES_NODE_MAP). Other architectures
> will ignore the boot parameter.
> 
> This effectively removes the following arch-specific patches;
> 
> ia64-specify-amount-of-kernel-memory-at-boot-time.patch
> ppc-and-powerpc-specify-amount-of-kernel-memory-at-boot-time.patch
> x86_64-specify-amount-of-kernel-memory-at-boot-time.patch
> x86-specify-amount-of-kernel-memory-at-boot-time.patch
> 

hm, OK.  That makes a bit of a mess of the patch series but we can live
with that.

> 
> Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
> Acked-by: Mel Gorman <mel@csn.ul.ie>
> Acked-by: Andy Whitcroft <apw@shadowen.org>

Patch protocol: Yasunori Gogo wrote the patch, so there should have been a
From:him at the very top of the changelog.  And you were in the patch
delivery path so you should have used Signed-off-by: rather than Acked-by:.
I made those two changes.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
