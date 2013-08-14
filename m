Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 364306B0081
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 04:11:21 -0400 (EDT)
Date: Wed, 14 Aug 2013 01:08:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm] mm: Unify pte_to_pgoff and pgoff_to_pte helpers
Message-Id: <20130814010856.0098398b.akpm@linux-foundation.org>
In-Reply-To: <20130814074333.GM2869@moon>
References: <20130814070059.GJ2869@moon>
	<520B303D.2090206@zytor.com>
	<20130814072453.GK2869@moon>
	<520B3240.6030208@zytor.com>
	<20130814003336.0fb2a275.akpm@linux-foundation.org>
	<20130814074333.GM2869@moon>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>, Pavel Emelyanov <xemul@parallels.com>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Peter Zijlstra <peterz@infradead.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>

On Wed, 14 Aug 2013 11:43:33 +0400 Cyrill Gorcunov <gorcunov@gmail.com> wrote:

> On Wed, Aug 14, 2013 at 12:33:36AM -0700, Andrew Morton wrote:
> > > > B_it_F_ield_OP_eration, Peter I don't mind to use any other
> > > > name, this was just short enough to type.
> > > > 
> > > 
> > > I think it would be useful to have a comment what it means and what
> > > v,r,m,l represent.
> 
> Sure, maybe simply better names as value, rshift, mask, lshift would
> look more understandable. I'll try to use width for mask as well
> (which reminds me BFEXT helpers Andrew mentioned in this thread).
> 
> > Can it be written in C with types and proper variable names and such
> > radical stuff?
> 
> Could you elaborate? You mean inline helper or macro with type checks?

/*
 * description goes here
 */
static inline pteval_t pte_bfop(pteval_t val, int rightshift, ...)
{
	...
}

So much better!  We really should only implement code in a macro if it
*has* to be done as a macro and I don't think that's the case here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
