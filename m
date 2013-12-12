Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 4DBC16B0039
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 08:45:30 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id v10so527409pde.14
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 05:45:29 -0800 (PST)
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
        by mx.google.com with ESMTPS id g6si16636554pbd.54.2013.12.12.05.45.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Dec 2013 05:45:29 -0800 (PST)
Received: by mail-pb0-f51.google.com with SMTP id up15so538211pbc.38
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 05:45:28 -0800 (PST)
Message-ID: <52A9BDF4.2040101@linaro.org>
Date: Thu, 12 Dec 2013 21:45:24 +0800
From: Alex Shi <alex.shi@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] x86: mm: Change tlb_flushall_shift for IvyBridge
References: <1386849309-22584-1-git-send-email-mgorman@suse.de> <1386849309-22584-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1386849309-22584-3-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/12/2013 07:55 PM, Mel Gorman wrote:
> There was a large performance regression that was bisected to commit 611ae8e3
> (x86/tlb: enable tlb flush range support for x86). This patch simply changes
> the default balance point between a local and global flush for IvyBridge.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

agree to be more conservative.

Reviewed-by: Alex Shi <alex.shi@linro.org>
> ---
>  arch/x86/kernel/cpu/intel.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
> index dc1ec0d..2d93753 100644
> --- a/arch/x86/kernel/cpu/intel.c
> +++ b/arch/x86/kernel/cpu/intel.c
> @@ -627,7 +627,7 @@ static void intel_tlb_flushall_shift_set(struct cpuinfo_x86 *c)
>  		tlb_flushall_shift = 5;
>  		break;
>  	case 0x63a: /* Ivybridge */
> -		tlb_flushall_shift = 1;
> +		tlb_flushall_shift = 2;
>  		break;
>  	default:
>  		tlb_flushall_shift = 6;
> 


-- 
Thanks
    Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
