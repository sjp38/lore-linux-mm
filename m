Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 49D2E6B0083
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 05:50:20 -0400 (EDT)
Received: by mail-ee0-f46.google.com with SMTP id c13so4720189eek.5
        for <linux-mm@kvack.org>; Wed, 14 Aug 2013 02:50:18 -0700 (PDT)
Date: Wed, 14 Aug 2013 11:50:14 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH -mm] mm: Unify pte_to_pgoff and pgoff_to_pte helpers
Message-ID: <20130814095014.GA10849@gmail.com>
References: <20130814070059.GJ2869@moon>
 <520B303D.2090206@zytor.com>
 <20130814072453.GK2869@moon>
 <520B3240.6030208@zytor.com>
 <20130814003336.0fb2a275.akpm@linux-foundation.org>
 <20130814074333.GM2869@moon>
 <20130814010856.0098398b.akpm@linux-foundation.org>
 <20130814082000.GN2869@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130814082000.GN2869@moon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>, Pavel Emelyanov <xemul@parallels.com>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Peter Zijlstra <peterz@infradead.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>


* Cyrill Gorcunov <gorcunov@gmail.com> wrote:

> On Wed, Aug 14, 2013 at 01:08:56AM -0700, Andrew Morton wrote:
> > > 
> > > > Can it be written in C with types and proper variable names and such
> > > > radical stuff?
> > > 
> > > Could you elaborate? You mean inline helper or macro with type checks?
> > 
> > /*
> >  * description goes here
> >  */
> > static inline pteval_t pte_bfop(pteval_t val, int rightshift, ...)
> > {
> > 	...
> > }
> > 
> > So much better!  We really should only implement code in a macro if it
> > *has* to be done as a macro and I don't think that's the case here?
> 
> Well, I'll have to check if it really doesn't generate additional 
> instructions in generated code, since it's hotpath. I'll ping back once 
> things are done.

An __always_inline should never do that.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
