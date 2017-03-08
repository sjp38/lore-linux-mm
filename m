Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5C08C831ED
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 10:38:41 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id h188so11827219wma.4
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 07:38:41 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u199si352376wmu.140.2017.03.08.07.38.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Mar 2017 07:38:40 -0800 (PST)
Date: Wed, 8 Mar 2017 16:38:38 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/7] 5-level paging: prepare generic code
Message-ID: <20170308153837.GA27822@dhcp22.suse.cz>
References: <20170306204514.1852-1-kirill.shutemov@linux.intel.com>
 <20170308142501.GB11034@dhcp22.suse.cz>
 <20170308150742.aaqfknxhurvvrvsl@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170308150742.aaqfknxhurvvrvsl@black.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 08-03-17 18:07:42, Kirill A. Shutemov wrote:
> On Wed, Mar 08, 2017 at 03:25:01PM +0100, Michal Hocko wrote:
> > Btw. my build test machinery has reported this:
> > microblaze/allnoconfig
> 
> Thanks.
> 
> Fixup is below. I guess it should be folded into 4/7.

yes, this has passed the testing

> 
> diff --git a/arch/microblaze/include/asm/page.h b/arch/microblaze/include/asm/page.h
> index fd850879854d..d506bb0893f9 100644
> --- a/arch/microblaze/include/asm/page.h
> +++ b/arch/microblaze/include/asm/page.h
> @@ -95,7 +95,8 @@ typedef struct { unsigned long pgd; } pgd_t;
>  #   else /* CONFIG_MMU */
>  typedef struct { unsigned long	ste[64]; }	pmd_t;
>  typedef struct { pmd_t		pue[1]; }	pud_t;
> -typedef struct { pud_t		pge[1]; }	pgd_t;
> +typedef struct { pud_t		p4e[1]; }	p4d_t;
> +typedef struct { p4d_t		pge[1]; }	pgd_t;
>  #   endif /* CONFIG_MMU */
>  
>  # define pte_val(x)	((x).pte)
> -- 
>  Kirill A. Shutemov

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
