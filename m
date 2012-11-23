Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 42C236B0071
	for <linux-mm@kvack.org>; Fri, 23 Nov 2012 10:20:52 -0500 (EST)
Message-ID: <50AF9450.9020803@leemhuis.info>
Date: Fri, 23 Nov 2012 16:20:48 +0100
From: Thorsten Leemhuis <fedora@leemhuis.info>
MIME-Version: 1.0
Subject: Re: [PATCH] Revert "mm: remove __GFP_NO_KSWAPD"
References: <20121015110937.GE29125@suse.de> <5093A3F4.8090108@redhat.com> <5093A631.5020209@suse.cz> <509422C3.1000803@suse.cz> <509C84ED.8090605@linux.vnet.ibm.com> <509CB9D1.6060704@redhat.com> <20121109090635.GG8218@suse.de> <509F6C2A.9060502@redhat.com> <20121112113731.GS8218@suse.de> <CA+5PVA75XDJjo45YQ7+8chJp9OEhZxgPMBUpHmnq1ihYFfpOaw@mail.gmail.com> <20121116200616.GK8218@suse.de> <CA+5PVA7__=JcjLAhs5cpVK-WaZbF5bQhp5WojBJsdEt9SnG3cw@mail.gmail.com> <50ABC128.80706@leemhuis.info>
In-Reply-To: <50ABC128.80706@leemhuis.info>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Boyer <jwboyer@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Zdenek Kabelac <zkabelac@redhat.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Jiri Slaby <jslaby@suse.cz>, Valdis.Kletnieks@vt.edu, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, bruno@wolff.to

Thorsten Leemhuis wrote on 20.11.2012 18:43:
> On 20.11.2012 16:38, Josh Boyer wrote:
> 
> The short story from my current point of view is:

Quick update, in case anybody is interested:

>  * my main machine at home where I initially saw the issue that started
> this thread seems to be running fine with rc6 and the "safe" patch Mel
> posted in https://lkml.org/lkml/2012/11/12/113 Before that I ran a rc5
> kernel with the revert that went into rc6 and the "safe" patch -- that
> worked fine for a few days, too.

On this machine I'm running a rc6 kernel + the fix for the accounting
bug(A1) that went into mainline ~40 hours ago + the "riskier" patch Mel
posted in https://lkml.org/lkml/2012/11/12/151

Up to now everything works fine.

(A1) https://lkml.org/lkml/2012/11/21/362

>  * I have a second machine where I started to use 3.7-rc kernels only
> yesterday (the machine triggered a bug in the radeon driver that seems
> to be fixed in rc6) which showed symptoms like the ones Zdenek Kabelac
> mentions in this thread. I wasn't able to look closer at it, but simply
> tried rc6 with the safe patch, which didn't help. I'm now running rc6
> with the "riskier" patch from https://lkml.org/lkml/2012/11/12/151
> I can't yet tell if it helps. If the problems shows up again I'll try to
> capture more debugging data via sysrq -- there wasn't any time for that
> when I was running rc6 with the safe patch, sorry.

This machine is now also behaving fine with above mentioned rc6 kernel +
the two patches. It seems the accounting bug was the root cause for the
problems this machine showed.

CU
 Thorsten

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
