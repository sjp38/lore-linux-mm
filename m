Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 70E5C6B0002
	for <linux-mm@kvack.org>; Sat,  9 Feb 2013 05:48:00 -0500 (EST)
Date: Sat, 9 Feb 2013 11:47:52 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 1/2] add helper for highmem checks
Message-ID: <20130209104751.GC17728@pd.tnic>
References: <20130208202813.62965F25@kernel.stglabs.ibm.com>
 <20130209094121.GB17728@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20130209094121.GB17728@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hpa@zytor.com, mingo@kernel.org, tglx@linutronix.de

On Sat, Feb 09, 2013 at 10:41:21AM +0100, Borislav Petkov wrote:
> > +static inline bool phys_addr_is_highmem(phys_addr_t addr)
> > +{
> > +	return addr > last_lowmem_paddr();
> 
> I think you mean last_lowmem_phys_addr() here:
> 
> include/linux/mm.h: In function a??phys_addr_is_highmema??:
> include/linux/mm.h:1764:2: error: implicit declaration of function a??last_lowmem_paddra?? [-Werror=implicit-function-declaration]
> cc1: some warnings being treated as errors
> make[1]: *** [arch/x86/kernel/asm-offsets.s] Error 1
> 
> Changed.

With this change, they definitely fix something because I even get X on
the box started. Previously, it would spit out the warning and wouldn't
start X with the login window. And my suspicion is that wdm (WINGs
display manager) I'm using, does /dev/mem accesses when it starts and it
obviously failed. Now not so much :-)

Tested-by: Borislav Petkov <bp@suse.de>

Thanks.

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
