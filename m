Subject: Re: [PATCH] fix spurious OOM kills
From: Thomas Gleixner <tglx@linutronix.de>
Reply-To: tglx@linutronix.de
In-Reply-To: <419FB4CD.7090601@ribosome.natur.cuni.cz>
References: <20041111112922.GA15948@logos.cnet>
	 <4193E056.6070100@tebibyte.org>	<4194EA45.90800@tebibyte.org>
	 <20041113233740.GA4121@x30.random>	<20041114094417.GC29267@logos.cnet>
	 <20041114170339.GB13733@dualathlon.random>
	 <20041114202155.GB2764@logos.cnet>	<419A2B3A.80702@tebibyte.org>
	 <419B14F9.7080204@tebibyte.org>	<20041117012346.5bfdf7bc.akpm@osdl.org>
	 <419CD8C1.4030506@ribosome.natur.cuni.cz>
	 <20041118131655.6782108e.akpm@osdl.org>
	 <419D25B5.1060504@ribosome.natur.cuni.cz>
	 <419D2987.8010305@cyberone.com.au>
	 <419D383D.4000901@ribosome.natur.cuni.cz>
	 <20041118160824.3bfc961c.akpm@osdl.org>
	 <419E821F.7010601@ribosome.natur.cuni.cz>
	 <1100946207.2635.202.camel@thomas> <419F2AB4.30401@ribosome.natur.cuni.cz>
	 <1100957349.2635.213.camel@thomas>
	 <419FB4CD.7090601@ribosome.natur.cuni.cz>
Content-Type: text/plain; charset=iso-8859-2
Date: Sun, 21 Nov 2004 12:53:19 +0100
Message-Id: <1101037999.23692.5.camel@thomas>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin =?iso-8859-2?Q?MOKREJ=A9?= <mmokrejs@ribosome.natur.cuni.cz>
Cc: Andrew Morton <akpm@osdl.org>, piggin@cyberone.com.au, chris@tebibyte.org, marcelo.tosatti@cyclades.com, andrea@novell.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sat, 2004-11-20 at 22:19 +0100, Martin MOKREJ(C) wrote:
> > It should only kill RNAsubopt and bash and touch nothing else.
> 
> Yes, that's true, this patch has helped. Actually the other xterm got
> closed, but that's because bash is the controlling application of it.
> I believe that's expected.
>
> I'd prefer to get only RNAsubopt killed. ;) 

Ok. To kill only RNAsubopt it might be neccecary to refine the criteria
in the whom to kill selection.

> And still, there weren't
> that many changes to memory management between 2.6.9-rc1 and 2.6.9-rc2. ;)
> I can test those VM changes separately, if someone would provide me with
> those changes split into 2 or 3 patchsets.

The oom trouble was definitly not invented there. The change between
2.6.9-rc1 and rc2 is justs triggering your special testcase. 

Other testcases show the problems with earlier 2.6 kernels too. 

tglx



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
