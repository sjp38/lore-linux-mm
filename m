Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E17FE6B0083
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 10:32:35 -0500 (EST)
Subject: Re: [PATCH v2 04/12] Add "handle page fault" PV helper.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1258985167-29178-5-git-send-email-gleb@redhat.com>
References: <1258985167-29178-1-git-send-email-gleb@redhat.com>
	 <1258985167-29178-5-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 23 Nov 2009 16:32:30 +0100
Message-ID: <1258990350.4531.589.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Mon, 2009-11-23 at 16:05 +0200, Gleb Natapov wrote:

> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> index f4cee90..14707dc 100644
> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -952,6 +952,9 @@ do_page_fault(struct pt_regs *regs, unsigned long error_code)
>  	int write;
>  	int fault;
>  
> +	if (arch_handle_page_fault(regs, error_code))
> +		return;
> +
>  	tsk = current;
>  	mm = tsk->mm;
>  

That's a bit daft, the pagefault handler is already arch specific, so
you're placing an arch_ hook into arch code, that doesn't make sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
