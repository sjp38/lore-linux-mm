Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id BDC346B0033
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 14:27:04 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 18 Jun 2013 12:26:24 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 546C41FF001E
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 12:21:03 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5IIQHHA219542
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 12:26:17 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5IISgoP013858
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 12:28:42 -0600
Date: Tue, 18 Jun 2013 11:26:16 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: vmstat kthreads
Message-ID: <20130618182616.GT5146@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20130618152302.GA10702@linux.vnet.ibm.com>
 <0000013f58656ee7-8bb24ac4-72fa-4c0b-b888-7c056f261b6e-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000013f58656ee7-8bb24ac4-72fa-4c0b-b888-7c056f261b6e-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: gilad@benyossef.com, linux-mm@kvack.org, ghaskins@londonstockexchange.com, niv@us.ibm.com, kravetz@us.ibm.com

On Tue, Jun 18, 2013 at 05:46:50PM +0000, Christoph Lameter wrote:
> On Tue, 18 Jun 2013, Paul E. McKenney wrote:
> 
> > I have been digging around the vmstat kthreads a bit, and it appears to
> > me that there is no reason to run a given CPU's vmstat kthread unless
> > that CPU spends some time executing in the kernel.  If correct, this
> > observation indicates that one way to safely reduce OS jitter due to the
> > vmstat kthreads is to prevent them from executing on a given CPU if that
> > CPU has been executing in usermode since the last time that this CPU's
> > vmstat kthread executed.
> 
> Right and we have patches to that effect.

Even better!

> > Does this seem like a sensible course of action, or did I miss something
> > when I went through the code?
> 
> Nope you are right on.
> 
> Gilad Ben-Yossef has been posting patches that address this issue in Feb
> 2012. Ccing him. Can we see your latest work, Gilead?

Is it this one?

https://lkml.org/lkml/2012/5/3/269

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
