Received: by wx-out-0506.google.com with SMTP id s8so352553wxc
        for <linux-mm@kvack.org>; Thu, 22 Feb 2007 18:31:14 -0800 (PST)
Message-ID: <4df04b840702221831x76626de1rfa70cb653b12f495@mail.gmail.com>
Date: Fri, 23 Feb 2007 10:31:13 +0800
From: "yunfeng zhang" <zyf.zeroos@gmail.com>
Subject: Re: [PATCH 2.6.20-rc5 1/1] MM: enhance Linux swap subsystem
In-Reply-To: <45DCFDBE.50209@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <4df04b840701212309l2a283357jbdaa88794e5208a7@mail.gmail.com>
	 <4df04b840701222021w5e1aaab2if2ba7fc38d06d64b@mail.gmail.com>
	 <4df04b840701222108o6992933bied5fff8a525413@mail.gmail.com>
	 <Pine.LNX.4.64.0701242015090.1770@blonde.wat.veritas.com>
	 <4df04b840701301852i41687edfl1462c4ca3344431c@mail.gmail.com>
	 <Pine.LNX.4.64.0701312022340.26857@blonde.wat.veritas.com>
	 <4df04b840702122152o64b2d59cy53afcd43bb24cb7a@mail.gmail.com>
	 <4df04b840702200106q670ff944k118d218fed17b884@mail.gmail.com>
	 <4df04b840702211758t1906083x78fb53b6283349ca@mail.gmail.com>
	 <45DCFDBE.50209@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Performance improvement should occur when private pages of multiple processes
are messed up, such as SMP. To UP, my previous mail is done by timer, which only
shows a fact, if pages are messed up fully, current readahead will degrade
remarkably, and unused readaheading pages make a burden to memory subsystem.

You should re-test your testcases following the advises on Linux without my
patch, do normal testcases and select a testcase randomly and record
'/proc/vmstat/pswpin', redo the testcase solely, if the results are close, that
is, your testcases doesn't messed up private pages at all as you expected due to
Linux schedule. Thank you!


2007/2/22, Rik van Riel <riel@redhat.com>:
> yunfeng zhang wrote:
> > Any comments or suggestions are always welcomed.
>
> Same question as always: what problem are you trying to solve?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
