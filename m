Message-ID: <44A01BBB.3070903@yahoo.com.au>
Date: Tue, 27 Jun 2006 03:39:07 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [rfc][patch] fixes for several oom killer problems
References: <20060626162038.GB7573@wotan.suse.de>
In-Reply-To: <20060626162038.GB7573@wotan.suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, "David S. Peterson" <dsp@llnl.gov>, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Hi,
> 
> We have reports of OOM killer panicing the system even if there are
> tasks currently exiting and/or plenty able to be freed.
> 

BTW, I should credit Jan Beulich with spotting some of the issues
and helping to debug the problem.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
