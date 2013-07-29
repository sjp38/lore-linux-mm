Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 3F9376B0034
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 10:14:21 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id w10so2020213lbi.7
        for <linux-mm@kvack.org>; Mon, 29 Jul 2013 07:14:19 -0700 (PDT)
Date: Mon, 29 Jul 2013 18:14:17 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: Save soft-dirty bits on file pages
Message-ID: <20130729141417.GM2524@moon>
References: <20130726201807.GJ8661@moon>
 <51F67777.6060609@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51F67777.6060609@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On Mon, Jul 29, 2013 at 06:08:55PM +0400, Pavel Emelyanov wrote:
> >  
> > -	if (!pte_none(*pte))
> > +	ptfile = pgoff_to_pte(pgoff);
> > +
> > +	if (!pte_none(*pte)) {
> > +#ifdef CONFIG_MEM_SOFT_DIRTY
> > +		if (pte_present(*pte) &&
> > +		    pte_soft_dirty(*pte))
> 
> I think there's no need in wrapping every such if () inside #ifdef CONFIG_...,
> since the pte_soft_dirty() routine itself would be 0 for non-soft-dirty case
> and compiler would optimize this code out.

If only I'm not missing something obvious, this code compiles not only on x86,
CONFIG_MEM_SOFT_DIRTY depends on x86 (otherwise I'll have to implement
pte_soft_dirty for all archs).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
