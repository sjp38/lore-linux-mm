Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1AD186B007B
	for <linux-mm@kvack.org>; Fri, 29 Jan 2010 00:45:36 -0500 (EST)
Message-ID: <4B6275C7.2040807@zytor.com>
Date: Thu, 28 Jan 2010 21:44:39 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] x86: get rid of the insane TIF_ABI_PENDING bit
References: <4B627236.1040508@zytor.com> <1264743694-4586-1-git-send-email-hpa@zytor.com> <1264743694-4586-2-git-send-email-hpa@zytor.com>
In-Reply-To: <1264743694-4586-2-git-send-email-hpa@zytor.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, security@kernel.org, tony.luck@intel.com, jmorris@namei.org, mikew@google.com, md@google.com, linux-mm@kvack.org, mingo@redhat.com, tglx@linutronix.de, minipli@googlemail.com, roland@redhat.com
List-ID: <linux-mm.kvack.org>

On 01/28/2010 09:41 PM, H. Peter Anvin wrote:
>  
>  #ifdef CONFIG_X86_64
> -	if (test_tsk_thread_flag(tsk, TIF_ABI_PENDING)) {
> -		clear_tsk_thread_flag(tsk, TIF_ABI_PENDING);
> -		if (test_tsk_thread_flag(tsk, TIF_IA32)) {
> -			clear_tsk_thread_flag(tsk, TIF_IA32);
> -		} else {
> -			set_tsk_thread_flag(tsk, TIF_IA32);
> -			current_thread_info()->status |= TS_COMPAT;
> -		}
> -	}
> +	/* Set up the first "return" to user space */
> +	if (test_tsk_thread_flag(tsk, TIF_IA32))
> +		current_thread_info()->status |= TS_COMPAT;
>  #endif
>  

This chunk should of course have been completely removed... let me do
that and re-test.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
