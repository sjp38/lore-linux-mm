Subject: Re: 2.6.0-test6-mm2
From: Robert Love <rml@tech9.net>
In-Reply-To: <20031002022341.797361bc.akpm@osdl.org>
References: <20031002022341.797361bc.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1065102332.10743.31.camel@localhost>
Mime-Version: 1.0
Date: Thu, 02 Oct 2003 09:45:32 -0400
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2003-10-02 at 05:23, Andrew Morton wrote:

> +show_task-on-runqueue.patch
> 
>  Teach sysrq-T to displayu which tasks actually have the CPU

This patch does:

	if (p->array)
		printk("has_cpu ");

does that work?  I think the existence of p->array is the same as it
being runnable.  It doesn't say whether or not it is actually running.

	Robert Love


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
