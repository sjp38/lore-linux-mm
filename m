Date: Thu, 27 Oct 2005 13:44:29 -0500
From: Dean Roe <roe@sgi.com>
Subject: Re: [ PATCH ] - Avoid slow TLB purges on SGI Altix systems
Message-ID: <20051027184429.GA13190@sgi.com>
References: <B8E391BBE9FE384DAA4C5C003888BE6F04CC08DF@scsmsx401.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F04CC08DF@scsmsx401.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Dean Roe <roe@sgi.com>, linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 27, 2005 at 11:41:13AM -0700, Luck, Tony wrote:
> >flush_tlb_range() only calls platform_global_tlb_purge() for CONFIG_SMP,
> >so there's no point in having that code in ia64_global_tlb_purge().
> 
> So you have dropped the "mm->context = 0;" for the UP case (and replaced
> it with a series of ia64_ptcl() calls).
> 
> To maintain the old behaivour you need to have:
> 
> #ifndef SMP
> 	if (mm != current->active_mm) {
> 		mm->context = 0;
> 		return;
> 	}
> #endif
> 
> in the start of flush_tlb_range().
> 
> 
> -Tony
> 

Sorry, now I see.  Fixed patch coming soon.

Thanks,
Dean

-- 
Dean Roe
Silicon Graphics, Inc.
roe@sgi.com
(651) 683-5203

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
