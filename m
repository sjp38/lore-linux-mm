Date: Wed, 17 Nov 2004 05:09:35 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] fix spurious OOM kills
Message-ID: <20041117070935.GF19107@logos.cnet>
References: <20041113233740.GA4121@x30.random> <20041114094417.GC29267@logos.cnet> <20041114170339.GB13733@dualathlon.random> <20041114202155.GB2764@logos.cnet> <419A2B3A.80702@tebibyte.org> <419B14F9.7080204@tebibyte.org> <20041117012346.5bfdf7bc.akpm@osdl.org> <20041117060648.GA19107@logos.cnet> <20041117060852.GB19107@logos.cnet> <419B2CFC.7040006@tebibyte.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <419B2CFC.7040006@tebibyte.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Ross <chris@tebibyte.org>
Cc: Andrew Morton <akpm@osdl.org>, andrea@novell.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, piggin@cyberone.com.au, riel@redhat.com, mmokrejs@ribosome.natur.cuni.cz, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

On Wed, Nov 17, 2004 at 11:50:36AM +0100, Chris Ross wrote:
> 
> Marcelo Tosatti escreveu:
> >On Wed, Nov 17, 2004 at 04:06:48AM -0200, Marcelo Tosatti wrote:
> >Before the swap token patches went in you remember spurious OOM reports  
> >or things were working fine then?
> 
> The oom killer problems arose before and independently of the 
> token-based-thrashing patches. I know this because I took a special 
> interest in the tbtc patches too (which is why my test machine came to 
> have 64MB RAM but 1GB swap).

So even when reaping referenced pages on zero priority scanning 
the OOM killer might be triggered in extreme cases. And as the 
number of tasks increases the chances things go wrong increase.

Please test Andrew's patch, its hopefully good enough for most 
scenarios. Extreme cases are probably still be problematic.

What are the "tbtc" patches ? 

Your testing is of huge value Chris. Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
