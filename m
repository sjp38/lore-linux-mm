Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 4665F6B004D
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 06:12:31 -0500 (EST)
Date: Tue, 27 Nov 2012 11:12:25 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] Revert "mm: remove __GFP_NO_KSWAPD"
Message-ID: <20121127111225.GO8218@suse.de>
References: <509C84ED.8090605@linux.vnet.ibm.com>
 <509CB9D1.6060704@redhat.com>
 <20121109090635.GG8218@suse.de>
 <509F6C2A.9060502@redhat.com>
 <20121112113731.GS8218@suse.de>
 <CA+5PVA75XDJjo45YQ7+8chJp9OEhZxgPMBUpHmnq1ihYFfpOaw@mail.gmail.com>
 <20121116200616.GK8218@suse.de>
 <CA+5PVA7__=JcjLAhs5cpVK-WaZbF5bQhp5WojBJsdEt9SnG3cw@mail.gmail.com>
 <50ABC128.80706@leemhuis.info>
 <50AF9450.9020803@leemhuis.info>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <50AF9450.9020803@leemhuis.info>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thorsten Leemhuis <fedora@leemhuis.info>
Cc: Josh Boyer <jwboyer@gmail.com>, Zdenek Kabelac <zkabelac@redhat.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Jiri Slaby <jslaby@suse.cz>, Valdis.Kletnieks@vt.edu, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, bruno@wolff.to

On Fri, Nov 23, 2012 at 04:20:48PM +0100, Thorsten Leemhuis wrote:
> Thorsten Leemhuis wrote on 20.11.2012 18:43:
> > On 20.11.2012 16:38, Josh Boyer wrote:
> > 
> > The short story from my current point of view is:
> 
> Quick update, in case anybody is interested:
> 
> >  * my main machine at home where I initially saw the issue that started
> > this thread seems to be running fine with rc6 and the "safe" patch Mel
> > posted in https://lkml.org/lkml/2012/11/12/113 Before that I ran a rc5
> > kernel with the revert that went into rc6 and the "safe" patch -- that
> > worked fine for a few days, too.
> 
> On this machine I'm running a rc6 kernel + the fix for the accounting
> bug(1) that went into mainline ~40 hours ago + the "riskier" patch Mel
> posted in https://lkml.org/lkml/2012/11/12/151
> 
> Up to now everything works fine.
> 
> (1) https://lkml.org/lkml/2012/11/21/362
> 

That's good news, thanks for the follow up. Maybe 3.7 will not be a complete
disaster with respect to THP after all this.

The riskier patch was not picked up simply because it was riskier and
would still be vunerable to the effective infinite loop Johannes found in
kswapd. It'll all need to be revisisted.

> >  * I have a second machine where I started to use 3.7-rc kernels only
> > yesterday (the machine triggered a bug in the radeon driver that seems
> > to be fixed in rc6) which showed symptoms like the ones Zdenek Kabelac
> > mentions in this thread. I wasn't able to look closer at it, but simply
> > tried rc6 with the safe patch, which didn't help. I'm now running rc6
> > with the "riskier" patch from https://lkml.org/lkml/2012/11/12/151
> > I can't yet tell if it helps. If the problems shows up again I'll try to
> > capture more debugging data via sysrq -- there wasn't any time for that
> > when I was running rc6 with the safe patch, sorry.
> 
> This machine is now also behaving fine with above mentioned rc6 kernel +
> the two patches. It seems the accounting bug was the root cause for the
> problems this machine showed.
> 

For some yes, for others no. Others are getting stuck within effective
infinite loops in kswapd and the trigger cases are different although
the symptoms loop similar.

Thanks again.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
