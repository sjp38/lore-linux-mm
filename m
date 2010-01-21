Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 30AE16B006A
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 15:40:54 -0500 (EST)
Message-ID: <4B58BC31.1040406@crca.org.au>
Date: Fri, 22 Jan 2010 07:42:25 +1100
From: Nigel Cunningham <ncunningham@crca.org.au>
MIME-Version: 1.0
Subject: Re: [linux-pm] [RFC][PATCH] PM: Force GFP_NOIO during	suspend/resume
 (was: Re: Memory allocations in .suspend	became very unreliable)
References: <20100120085053.405A.A69D9226@jp.fujitsu.com>	<201001202221.34804.rjw@sisk.pl>	<20100121091023.3775.A69D9226@jp.fujitsu.com> <201001212121.50272.rjw@sisk.pl>
In-Reply-To: <201001212121.50272.rjw@sisk.pl>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-pm@lists.linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi.

Rafael J. Wysocki wrote:
> On Thursday 21 January 2010, KOSAKI Motohiro wrote:
>>  - Ask all drivers how much they require memory before starting suspend and
>>    Make enough free memory at first?
> 
> That's equivalent to reworking all drivers to allocate memory before suspend
> eg. with the help of PM notifiers.  Which IMHO is unrealistic.

What's unrealistic about it? I can see that it would be a lot of work,
but unrealistic? To me, at this stage, it sounds like the ideal solution.

Regards,

Nigel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
