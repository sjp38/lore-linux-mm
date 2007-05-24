Date: Thu, 24 May 2007 11:58:37 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/2] limit print_fatal_signal() rate
Message-ID: <20070524095837.GA15689@elte.hu>
References: <E1Hp5PV-0001Bn-00@calista.eckenfels.net> <464ED258.2010903@users.sourceforge.net> <20070520203123.5cde3224.akpm@linux-foundation.org> <20070524075835.GC21138@elte.hu> <465551DC.4060603@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <465551DC.4060603@users.sourceforge.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Righi <righiandr@users.sourceforge.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Bernd Eckenfels <ecki@lina.inka.de>, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Andrea Righi <righiandr@users.sourceforge.net> wrote:

> Actually it seems that SIGKILLs are not printed. In 
> get_signal_to_deliver() we have:
> 
> [snip]
> @@ -1843,6 +1879,8 @@ relock:
>  		 * Anything else is fatal, maybe with a core dump.
>  		 */
>  		current->flags |= PF_SIGNALED;
> +		if ((signr != SIGKILL) && print_fatal_signals)
> +			print_fatal_signal(regs, signr);

yeah. Either i implemented that and forgot, or someone else implemented 
it. :)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
