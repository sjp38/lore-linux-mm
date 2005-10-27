Date: Thu, 27 Oct 2005 13:31:04 -0500
From: Dean Roe <roe@sgi.com>
Subject: Re: [ PATCH ] - Avoid slow TLB purges on SGI Altix systems
Message-ID: <20051027183104.GA12888@sgi.com>
References: <B8E391BBE9FE384DAA4C5C003888BE6F04C8CF40@scsmsx401.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F04C8CF40@scsmsx401.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Dean Roe <roe@sgi.com>, linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 27, 2005 at 09:01:53AM -0700, Luck, Tony wrote:
> -	if (mm != current->active_mm) {
> -		/* this does happen, but perhaps it's not worth optimizing for? */
> -#ifdef CONFIG_SMP
> -		flush_tlb_all();
> -#else
> -		mm->context = 0;
> -#endif
> -		return;
> -	}
> 
> Your patch moves this secion of code up to ia64_global_tlb_purge(),
> but the new code that is added there doesn't include the UP case
> where mm->context is set to zero.
> 
> -Tony
> 

flush_tlb_range() only calls platform_global_tlb_purge() for CONFIG_SMP,
so there's no point in having that code in ia64_global_tlb_purge().

Dean

-- 
Dean Roe
Silicon Graphics, Inc.
roe@sgi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
