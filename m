Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id B375F6B0033
	for <linux-mm@kvack.org>; Tue, 13 Aug 2013 11:37:06 -0400 (EDT)
Received: by mail-la0-f45.google.com with SMTP id fj20so5955124lab.32
        for <linux-mm@kvack.org>; Tue, 13 Aug 2013 08:37:04 -0700 (PDT)
Date: Tue, 13 Aug 2013 19:37:03 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [patch 2/2] [PATCH] mm: Save soft-dirty bits on file pages
Message-ID: <20130813153703.GE2869@moon>
References: <20130730204154.407090410@gmail.com>
 <20130730204654.966378702@gmail.com>
 <20130807132812.60ad4bfe85127794094d385e@linux-foundation.org>
 <20130808145120.GA1775@moon>
 <20130812145720.3b722b066fe1bd77291331e5@linux-foundation.org>
 <CALCETrUXOoKrOAXhvd=GcK3YpBNWr2rk2ArBBgekXDv9yj7sNg@mail.gmail.com>
 <20130813050213.GA2869@moon>
 <520A4D5F.6020401@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <520A4D5F.6020401@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xemul@parallels.com, mpm@selenic.com, xiaoguangrong@linux.vnet.ibm.com, mtosatti@redhat.com, kosaki.motohiro@gmail.com, sfr@canb.auug.org.au, peterz@infradead.org, aneesh.kumar@linux.vnet.ibm.com, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Aug 13, 2013 at 08:14:39AM -0700, H. Peter Anvin wrote:
> On 08/12/2013 10:02 PM, Cyrill Gorcunov wrote:
> > 
> > There is a case when you don't need a mask completely. And because this
> > pte conversion is on hot path and time critical I kept generated code
> > as it was (even if that lead to slightly less clear source code).
> > 
> 
> Does it actually matter, generated-code-wise, or is the compiler smart
> enough to figure it out?  The reason I'm asking is because it makes the

gcc-4.7.2 is smart enough to suppress useless masking (ie ((1u << 31) - 1))
completely but I don't know if this can be assumed for all gcc series.

> code much harder to follow.

I see. OK, I'll try to prepare more readable macro helpers.

> 
> The other thing is can we please pretty please call it something other
> than "frob"?

Sure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
