Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1F0B78D0040
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 12:02:45 -0500 (EST)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p22GbgG4031770
	for <linux-mm@kvack.org>; Wed, 2 Mar 2011 11:37:43 -0500
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 05CF86E8036
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 12:02:23 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p22H2Bf92551912
	for <linux-mm@kvack.org>; Wed, 2 Mar 2011 12:02:12 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p22H2A19028582
	for <linux-mm@kvack.org>; Wed, 2 Mar 2011 12:02:11 -0500
Subject: Re: [RFC PATCH 4/5] mm: Add hit/miss accounting for Page Cache
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110302084542.GA20795@elte.hu>
References: <no> <1299055090-23976-4-git-send-email-namei.unix@gmail.com>
	 <20110302084542.GA20795@elte.hu>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Wed, 02 Mar 2011 09:02:06 -0800
Message-ID: <1299085326.8493.820.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Liu Yuan <namei.unix@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jaxboe@fusionio.com, akpm@linux-foundation.org, fengguang.wu@intel.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, =?ISO-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Arnaldo Carvalho de Melo <acme@redhat.com>

On Wed, 2011-03-02 at 09:45 +0100, Ingo Molnar wrote:
> But, instead of trying to improve those aspects of our existing instrumentation 
> frameworks, mm/* is gradually growing its own special instrumentation hacks, missing 
> the big picture and fragmenting the instrumentation space some more.
> 
> That trend is somewhat sad. 

Go any handy examples of how you'd like to see these done?

We're trying to add a batch of these for transparent huge pages, and
there was a similar set for KSM, so there's certainly no shortage of
potential sites.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
