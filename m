Date: Thu, 18 Nov 2004 16:08:24 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] fix spurious OOM kills
Message-Id: <20041118160824.3bfc961c.akpm@osdl.org>
In-Reply-To: <419D383D.4000901@ribosome.natur.cuni.cz>
References: <20041111112922.GA15948@logos.cnet>
	<4193E056.6070100@tebibyte.org>
	<4194EA45.90800@tebibyte.org>
	<20041113233740.GA4121@x30.random>
	<20041114094417.GC29267@logos.cnet>
	<20041114170339.GB13733@dualathlon.random>
	<20041114202155.GB2764@logos.cnet>
	<419A2B3A.80702@tebibyte.org>
	<419B14F9.7080204@tebibyte.org>
	<20041117012346.5bfdf7bc.akpm@osdl.org>
	<419CD8C1.4030506@ribosome.natur.cuni.cz>
	<20041118131655.6782108e.akpm@osdl.org>
	<419D25B5.1060504@ribosome.natur.cuni.cz>
	<419D2987.8010305@cyberone.com.au>
	<419D383D.4000901@ribosome.natur.cuni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin =?ISO-8859-1?B?TU9LUkVKX18=?= <mmokrejs@ribosome.natur.cuni.cz>
Cc: piggin@cyberone.com.au, chris@tebibyte.org, marcelo.tosatti@cyclades.com, andrea@novell.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

Martin MOKREJ__ <mmokrejs@ribosome.natur.cuni.cz> wrote:
>
>   Anyway, plain 2.6.7 kills only the application asking for
>  so much memory and logs via syslog:
>  Out of Memory: Killed process 58888 (RNAsubopt)
> 
>    It's a lot better compared to what we have in 2.6.10-rc2,
>  from my user's view.

We haven't made any changes to the oom-killer algorithm since July 2003. 
Weird.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
