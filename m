Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 7EF266B0082
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 04:20:14 -0400 (EDT)
Received: by mail-lb0-f170.google.com with SMTP id r10so6561987lbi.29
        for <linux-mm@kvack.org>; Wed, 14 Aug 2013 01:20:12 -0700 (PDT)
Date: Wed, 14 Aug 2013 12:20:00 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH -mm] mm: Unify pte_to_pgoff and pgoff_to_pte helpers
Message-ID: <20130814082000.GN2869@moon>
References: <20130814070059.GJ2869@moon>
 <520B303D.2090206@zytor.com>
 <20130814072453.GK2869@moon>
 <520B3240.6030208@zytor.com>
 <20130814003336.0fb2a275.akpm@linux-foundation.org>
 <20130814074333.GM2869@moon>
 <20130814010856.0098398b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130814010856.0098398b.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>, Pavel Emelyanov <xemul@parallels.com>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Peter Zijlstra <peterz@infradead.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>

On Wed, Aug 14, 2013 at 01:08:56AM -0700, Andrew Morton wrote:
> > 
> > > Can it be written in C with types and proper variable names and such
> > > radical stuff?
> > 
> > Could you elaborate? You mean inline helper or macro with type checks?
> 
> /*
>  * description goes here
>  */
> static inline pteval_t pte_bfop(pteval_t val, int rightshift, ...)
> {
> 	...
> }
> 
> So much better!  We really should only implement code in a macro if it
> *has* to be done as a macro and I don't think that's the case here?

Well, I'll have to check if it really doesn't generate additional
instructions in generated code, since it's hotpath. I'll ping back
once things are done.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
