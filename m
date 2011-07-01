Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 82DCD6B0082
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 19:15:27 -0400 (EDT)
Subject: Re: [PATCH 2/2] powerpc/mm: Fix memory_block_size_bytes() for
 non-pseries
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20110701121516.GD28008@elte.hu>
References: <1308013071.2874.785.camel@pasglop>
	 <20110701121516.GD28008@elte.hu>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 02 Jul 2011 09:15:12 +1000
Message-ID: <1309562112.14501.257.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

On Fri, 2011-07-01 at 14:15 +0200, Ingo Molnar wrote:

> > +/* WARNING: This is going to override the generic definition whenever
> > + * pseries is built-in regardless of what platform is active at boot
> > + * time. This is fine for now as this is the only "option" and it
> > + * should work everywhere. If not, we'll have to turn this into a
> > + * ppc_md. callback
> > + */
> 
> Just a small nit, please use the customary (multi-line) comment 
> style:
> 
>   /*
>    * Comment .....
>    * ...... goes here.
>    */
> 
> specified in Documentation/CodingStyle.

Ah ! Here goes my sneak attempts at violating coding style while nobody
notices :-)

No seriously, that sort of stuff shouldn't be such a hard rule... In
some cases the "official" way looks nicer, on some cases it's just a
waste of space, and I've grown to prefer my slightly more compact form,
at least depending on how the surrounding code looks like.

Since that's all powerpc arch code, I believe I'm entitled to that
little bit of flexibility in how the code looks like :-) It's not
like I'm GoingToPlayWithCaps() or switching to 3-char tabs :-)

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
