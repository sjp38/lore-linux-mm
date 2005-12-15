Date: Wed, 14 Dec 2005 18:56:58 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.15-rc5-mm2 can't boot on ia64 due to changing
 on_each_cpu().
Message-Id: <20051214185658.7a60aa07.akpm@osdl.org>
In-Reply-To: <20051215103344.241C.Y-GOTO@jp.fujitsu.com>
References: <20051215103344.241C.Y-GOTO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mm@kvack.org, bcrl@kvack.org, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

Yasunori Goto <y-goto@jp.fujitsu.com> wrote:
>
> When I removed following patch which is in 2.6.15-rc5-mm2,
>  which changes on_each_cpu() from static inline function to macro,
>  then there was no warning, and kernel could boot up.
>  So, I guess that gcc was not able to solve a bit messy cast
>  for calling function "local_flush_tlb_all()" due to its change.

Thanks.  I'll drop it.

I built and booted that kernel on my Tiger.  Odd.  I suspect there's
something very non-aggressive about my .config - this sort of thing has
happened before.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
