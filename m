Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id B3C0D6B0279
	for <linux-mm@kvack.org>; Tue, 18 Jul 2017 11:16:15 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id b127so5336356lfb.3
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 08:16:15 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id a12si1240133lfh.115.2017.07.18.08.16.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jul 2017 08:16:14 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id p11so2172232lfd.1
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 08:16:14 -0700 (PDT)
Date: Tue, 18 Jul 2017 18:16:11 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 08/10] x86/mm: Replace compile-time checks for 5-level
 with runtime-time
Message-ID: <20170718151611.rnjdhbzaaf4c3357@node.shutemov.name>
References: <20170718141517.52202-1-kirill.shutemov@linux.intel.com>
 <20170718141517.52202-9-kirill.shutemov@linux.intel.com>
 <6841c4f3-6794-f0ac-9af9-0ceb56e49653@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6841c4f3-6794-f0ac-9af9-0ceb56e49653@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 18, 2017 at 04:24:06PM +0200, Juergen Gross wrote:
> On 18/07/17 16:15, Kirill A. Shutemov wrote:
> > diff --git a/arch/x86/xen/mmu_pv.c b/arch/x86/xen/mmu_pv.c
> > index cab28cf2cffb..b0530184c637 100644
> > --- a/arch/x86/xen/mmu_pv.c
> > +++ b/arch/x86/xen/mmu_pv.c
> > @@ -1209,7 +1209,7 @@ static void __init xen_cleanmfnmap(unsigned long vaddr)
> >  			continue;
> >  		xen_cleanmfnmap_p4d(p4d + i, unpin);
> >  	}
> > -	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
> > +	if (!p4d_folded) {
> >  		set_pgd(pgd, __pgd(0));
> >  		xen_cleanmfnmap_free_pgtbl(p4d, unpin);
> >  	}
> 
> Xen PV guests will never run with 5-level-paging enabled. So I guess you
> can drop the complete if (IS_ENABLED(CONFIG_X86_5LEVEL)) {} block.

Thanks.

I'll do a sparate cleanup patch for this.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
