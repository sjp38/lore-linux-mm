Message-ID: <419D383D.4000901@ribosome.natur.cuni.cz>
Date: Fri, 19 Nov 2004 01:03:09 +0100
From: =?ISO-8859-2?Q?Martin_MOKREJ=A9?= <mmokrejs@ribosome.natur.cuni.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] fix spurious OOM kills
References: <20041111112922.GA15948@logos.cnet>	<4193E056.6070100@tebibyte.org>	<4194EA45.90800@tebibyte.org>	<20041113233740.GA4121@x30.random>	<20041114094417.GC29267@logos.cnet>	<20041114170339.GB13733@dualathlon.random>	<20041114202155.GB2764@logos.cnet>	<419A2B3A.80702@tebibyte.org>	<419B14F9.7080204@tebibyte.org>	<20041117012346.5bfdf7bc.akpm@osdl.org>	<419CD8C1.4030506@ribosome.natur.cuni.cz> <20041118131655.6782108e.akpm@osdl.org> <419D25B5.1060504@ribosome.natur.cuni.cz> <419D2987.8010305@cyberone.com.au>
In-Reply-To: <419D2987.8010305@cyberone.com.au>
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Andrew Morton <akpm@osdl.org>, chris@tebibyte.org, marcelo.tosatti@cyclades.com, andrea@novell.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

Hi,
  I just tested 2.6.7 and it works comparably to 2.4.28.
swpd value reported by vmstat is actually 1172736,
actually inspecting the previous results from 2.4.28
show also this number. But "swapon -s" reports 1172732.
I'm puzzled. vmstat comes from gentoo procps-3.2.3-r1.


  Anyway, plain 2.6.7 kills only the application asking for
so much memory and logs via syslog:
Out of Memory: Killed process 58888 (RNAsubopt)

  It's a lot better compared to what we have in 2.6.10-rc2,
from my user's view.

  I cannot easily reverse the tbtc patch from 2.6.10-rc2 tree,
but applying the tbtc patch over 2.6.7 gives me same behaviour
as on plain 2.6.7 - so only the RNAsubopt application get's
killed.

  The problem must have been introduced between 2.6.7
and 2.6.10-rc2 but is not directly related to tbtc patch in it's
original form:
http://marc.theaimsgroup.com/?l=linux-kernel&m=109122597407401&w=2

Hope this helps.
Martin
  
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
