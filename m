Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 0A6A36B007D
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 03:43:36 -0400 (EDT)
Received: by mail-lb0-f177.google.com with SMTP id n6so2329218lbi.36
        for <linux-mm@kvack.org>; Wed, 14 Aug 2013 00:43:35 -0700 (PDT)
Date: Wed, 14 Aug 2013 11:43:33 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH -mm] mm: Unify pte_to_pgoff and pgoff_to_pte helpers
Message-ID: <20130814074333.GM2869@moon>
References: <20130814070059.GJ2869@moon>
 <520B303D.2090206@zytor.com>
 <20130814072453.GK2869@moon>
 <520B3240.6030208@zytor.com>
 <20130814003336.0fb2a275.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130814003336.0fb2a275.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>, Pavel Emelyanov <xemul@parallels.com>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Peter Zijlstra <peterz@infradead.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>

On Wed, Aug 14, 2013 at 12:33:36AM -0700, Andrew Morton wrote:
> > > B_it_F_ield_OP_eration, Peter I don't mind to use any other
> > > name, this was just short enough to type.
> > > 
> > 
> > I think it would be useful to have a comment what it means and what
> > v,r,m,l represent.

Sure, maybe simply better names as value, rshift, mask, lshift would
look more understandable. I'll try to use width for mask as well
(which reminds me BFEXT helpers Andrew mentioned in this thread).

> Can it be written in C with types and proper variable names and such
> radical stuff?

Could you elaborate? You mean inline helper or macro with type checks?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
