Date: Thu, 10 Jul 2003 02:48:41 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.74-mm3 - apm_save_cpus() Macro still bombs out
Message-ID: <20030710094841.GU15452@holomorphy.com>
References: <20030708223548.791247f5.akpm@osdl.org> <200307101122.59138.schlicht@uni-mannheim.de> <20030710092720.GT15452@holomorphy.com> <200307101142.37137.schlicht@uni-mannheim.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200307101142.37137.schlicht@uni-mannheim.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Thomas Schlichter <schlicht@uni-mannheim.de>
Cc: Piet Delaney <piet@www.piet.net>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 10 July 2003 11:27, William Lee Irwin III wrote:
>> Could you try the following?

On Thu, Jul 10, 2003 at 11:42:35AM +0200, Thomas Schlichter wrote:
> OK, I tried it. For me it compiles!
> But the size of the resulting objectfile's text section is about 64bytes 
> larger than with my patch. So it seems that gcc3.3 wasn't able to optimize 
> away all the unneeded stuff...
> And I don't think my patch is that ugly, but hey, it's your decision...

64B? Why do you care?


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
