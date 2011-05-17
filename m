Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 9E9DC6B0027
	for <linux-mm@kvack.org>; Tue, 17 May 2011 18:17:56 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4HMAjZU018661
	for <linux-mm@kvack.org>; Tue, 17 May 2011 16:10:45 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4HMJ92e091668
	for <linux-mm@kvack.org>; Tue, 17 May 2011 16:19:09 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4HGHN7X008062
	for <linux-mm@kvack.org>; Tue, 17 May 2011 10:17:24 -0600
Subject: Re: [PATCH 2/3] printk: Add %ptc to safely print a task's comm
From: John Stultz <john.stultz@linaro.org>
In-Reply-To: <4DD2EBAB.5080004@gmail.com>
References: <1305665263-20933-1-git-send-email-john.stultz@linaro.org>
	 <1305665263-20933-3-git-send-email-john.stultz@linaro.org>
	 <4DD2EBAB.5080004@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 17 May 2011 15:17:46 -0700
Message-ID: <1305670666.2915.128.camel@work-vm>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jirislaby@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Joe Perches <joe@perches.com>, Michal Nazarewicz <mina86@mina86.com>, Andy Whitcroft <apw@canonical.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, 2011-05-17 at 23:42 +0200, Jiri Slaby wrote:
> On 05/17/2011 10:47 PM, John Stultz wrote:  
> > +static noinline_for_stack
> 
> I still fail to see why this should be slowed down by noinlining it.
> Care to explain?

Just that I was hesitant to change it without consensus and it follows
the convention of other similarly called functions.

> With my setup, the code below inlined will use 32 bytes of stack. The
> same as %pK case. Uninlined it obviously eats "only" 8 bytes for IP.

Maybe could we defer that discussion into a following patch, which maybe
does a similar analysis on the other noinline_for_stack usage in that
case?

(And I may be dropping the whole series here in a bit, so more debate on
it might be moot)

thanks
-john


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
