Message-ID: <419B2CFC.7040006@tebibyte.org>
Date: Wed, 17 Nov 2004 11:50:36 +0100
From: Chris Ross <chris@tebibyte.org>
MIME-Version: 1.0
Subject: Re: [PATCH] fix spurious OOM kills
References: <4193E056.6070100@tebibyte.org> <4194EA45.90800@tebibyte.org> <20041113233740.GA4121@x30.random> <20041114094417.GC29267@logos.cnet> <20041114170339.GB13733@dualathlon.random> <20041114202155.GB2764@logos.cnet> <419A2B3A.80702@tebibyte.org> <419B14F9.7080204@tebibyte.org> <20041117012346.5bfdf7bc.akpm@osdl.org> <20041117060648.GA19107@logos.cnet> <20041117060852.GB19107@logos.cnet>
In-Reply-To: <20041117060852.GB19107@logos.cnet>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Andrew Morton <akpm@osdl.org>, andrea@novell.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, piggin@cyberone.com.au, riel@redhat.com, mmokrejs@ribosome.natur.cuni.cz, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti escreveu:
> On Wed, Nov 17, 2004 at 04:06:48AM -0200, Marcelo Tosatti wrote:
> Before the swap token patches went in you remember spurious OOM reports  
> or things were working fine then?

The oom killer problems arose before and independently of the 
token-based-thrashing patches. I know this because I took a special 
interest in the tbtc patches too (which is why my test machine came to 
have 64MB RAM but 1GB swap).

Regards,
Chris R.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
