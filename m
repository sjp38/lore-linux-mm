Date: Sat, 19 Feb 2005 18:27:03 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: [cliffw@osdl.org: Re: 2.6.10-ac12 + kernbench ==  oom-killer: (OSDL)]
Message-ID: <20050219202703.GD4874@dmt.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: andrea@suse.de, akpm@osdl.org, Nick Piggin <piggin@cyberone.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

FYI 

----- Forwarded message from cliff white <cliffw@osdl.org> -----

From: cliff white <cliffw@osdl.org>
Date: Thu, 17 Feb 2005 12:49:16 -0800
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-kernel@vger.kernel.org, alan@lxorguk.ukuu.org.uk
Subject: Re: 2.6.10-ac12 + kernbench ==  oom-killer: (OSDL)

On Wed, 9 Feb 2005 10:12:06 -0200
Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:

> On Tue, Feb 08, 2005 at 02:57:07PM -0800, cliff white wrote:
> > 
> > Running 2.6.10-ac10 on the STP 1-CPU machines, we don't seem to be able to complete
> > a kernbench run without hitting the OOM-killer. ( kernbench is multiple kernel compiles,
> > of course ) Machine is 800 mhz PIII with 1GB memory. We reduce memory for some of the runs.
> 
> Cliff, 
> 
> Please try recent v2.6.11-rc3, they include a series of OOM killer fixes from Andrea et all.
> 

Sorry for the delay in response. Recent -bk runs still show this problem, for example:
http://khack.osdl.org/stp/300713/logs/TestRunFailed.console.log.txt
( patch-2.6.11-rc3-bk4 ) 

cliffw

> Thanks.
> 


-- 
"Ive always gone through periods where I bolt upright at four in the morning; 
now at least theres a reason." -Michael Feldman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
