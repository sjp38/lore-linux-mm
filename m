Subject: Re: 2.5.44-mm2 CONFIG_SHAREPTE necessary for starting KDE 3.0.3
From: Robert Love <rml@tech9.net>
In-Reply-To: <1035307236.13083.183.camel@spc9.esa.lanl.gov>
References: <1035306108.13078.178.camel@spc9.esa.lanl.gov>
	<1035307236.13083.183.camel@spc9.esa.lanl.gov>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 22 Oct 2002 14:10:33 -0400
Message-Id: <1035310234.1044.1480.camel@phantasy>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steven Cole <scole@lanl.gov>
Cc: Steven Cole <elenstev@mesatop.com>, Andrew Morton <akpm@zip.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2002-10-22 at 13:20, Steven Cole wrote:

> After reading my own mail, I realized that I should have checked to see
> if disabling PREEMPT did any good in this case. 
> 
> I just booted 2.5.44-mm2 without PREEMPT and without SHAREPTE, and KDE
> 3.0.3 was able to start up OK.

Let me clarify, because this is odd...

	CONFIG_PREEMPT + CONFIG_SHAREPTE => OK

	CONFIG_PREEMPT + !CONFIG_SHAREPTE => KDE crashes

	!CONFIG_PREEMPT + !CONFIG_SHAREPTE => OK

Right?

Sounds like a timing issue to me.  Any other errors?  It is possible to
get a trace?

This sounds familiar, so do not think too hard without double
checking... someone else reported failure with KDE.

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
